import Foundation

@MainActor
final class OrderListViewModel: ObservableObject {
    @Published private(set) var state: OrderListState

    private let orderProvider: OrderProviding
    private var allOrders: [Order] = []
    private var hasLoaded = false

    init(
        initialFilter: OrderStatus = .pending,
        orderProvider: OrderProviding
    ) {
        self.state = .idle(filter: initialFilter)
        self.orderProvider = orderProvider
    }

    func loadOrders() async {
        let filter = state.filter
        state = .loading(filter: filter)

        do {
            let orders = try await orderProvider.fetchOrders()
            hasLoaded = true
            allOrders = orders
            applyFilter(filter)
        } catch {
            state = .failed(message: error.localizedDescription, filter: filter)
        }
    }

    func updateFilter(_ newFilter: OrderStatus) {
        if hasLoaded {
            applyFilter(newFilter)
        } else {
            state = .idle(filter: newFilter)
        }
    }

    private func applyFilter(_ filter: OrderStatus) {
        let filtered = allOrders.filter { $0.status == filter }
        if filtered.isEmpty {
            state = .empty(filter: filter)
        } else {
            let items = filtered.map { OrderRowModel(id: $0.id, number: $0.number, status: $0.status, destination: $0.destination, etaText: Self.formatEta($0.eta)) }
            state = .loaded(items: items, filter: filter)
        }
    }

    private static func formatEta(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
