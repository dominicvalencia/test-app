import Foundation

final class MockOrderService: OrderProviding {
    enum FetchScenario: Equatable {
        case success([Order])
        case empty
        case failure(message: String)
    }

    struct StatusPlan: Equatable {
        let statuses: [OrderStatus]
        let intervalSeconds: TimeInterval
    }

    private let scenario: FetchScenario
    private let fetchDelaySeconds: TimeInterval
    private let statusPlan: StatusPlan
    private let dateProvider: () -> Date

    init(
        scenario: FetchScenario,
        fetchDelaySeconds: TimeInterval = 0.8,
        statusPlan: StatusPlan = StatusPlan(statuses: [.pending, .inTransit, .delivered], intervalSeconds: 2.0),
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.scenario = scenario
        self.fetchDelaySeconds = fetchDelaySeconds
        self.statusPlan = statusPlan
        self.dateProvider = dateProvider
    }

    func fetchOrders() async throws -> [Order] {
        if fetchDelaySeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(fetchDelaySeconds * 1_000_000_000))
        }

        switch scenario {
        case .success(let orders):
            return orders
        case .empty:
            return []
        case .failure(let message):
            throw MockOrderServiceError(message: message)
        }
    }

    func statusUpdates(for order: Order) -> AsyncStream<OrderStatusUpdate> {
        let plan = statusPlan
        let now = dateProvider

        return AsyncStream { continuation in
            Task {
                for status in plan.statuses {
                    if plan.intervalSeconds > 0 {
                        try? await Task.sleep(nanoseconds: UInt64(plan.intervalSeconds * 1_000_000_000))
                    }
                    continuation.yield(OrderStatusUpdate(status: status, timestamp: now()))
                }
                continuation.finish()
            }
        }
    }
}

struct MockOrderServiceError: Error, LocalizedError, Equatable {
    let message: String

    var errorDescription: String? { message }
}

extension MockOrderService {
    static func sampleOrders(baseDate: Date = Date()) -> [Order] {
        let eta1 = baseDate.addingTimeInterval(60 * 60 * 5)
        let eta2 = baseDate.addingTimeInterval(60 * 60 * 24)
        let eta3 = baseDate.addingTimeInterval(60 * 60 * 48)

        return [
            Order(id: UUID(), number: "ORD-1001", status: .pending, destination: "San Francisco, CA", eta: eta1),
            Order(id: UUID(), number: "ORD-1002", status: .inTransit, destination: "Oakland, CA", eta: eta2),
            Order(id: UUID(), number: "ORD-1003", status: .delivered, destination: "San Jose, CA", eta: eta3)
        ]
    }
}
