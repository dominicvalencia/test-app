import Foundation

@MainActor
final class OrderDetailViewModel: ObservableObject {
    @Published private(set) var state: OrderDetailState = .loading

    private let order: Order
    private let orderProvider: OrderProviding
    private let dateProvider: () -> Date
    private var updatesTask: Task<Void, Never>?

    init(
        order: Order,
        orderProvider: OrderProviding,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.order = order
        self.orderProvider = orderProvider
        self.dateProvider = dateProvider
    }

    func startUpdates() {
        updatesTask?.cancel()
        state = .loading
        state = .active(makeModel(status: order.status, timestamp: dateProvider()))

        updatesTask = Task { [orderProvider, order] in
            for await update in orderProvider.statusUpdates(for: order) {
                if Task.isCancelled { return }
                await MainActor.run {
                    self.state = .active(self.makeModel(status: update.status, timestamp: update.timestamp))
                }
            }
        }
    }

    func stopUpdates() {
        updatesTask?.cancel()
        updatesTask = nil
    }

    private func makeModel(status: OrderStatus, timestamp: Date) -> OrderDetailModel {
        OrderDetailModel(
            number: order.number,
            destination: order.destination,
            currentStatus: status,
            lastUpdatedText: Self.formatTimestamp(timestamp)
        )
    }

    private static func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
