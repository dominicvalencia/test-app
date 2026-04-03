import Foundation

struct OrderStatusUpdate: Equatable {
    let status: OrderStatus
    let timestamp: Date
}

protocol OrderProviding {
    func fetchOrders() async throws -> [Order]
    func statusUpdates(for order: Order) -> AsyncStream<OrderStatusUpdate>
}
