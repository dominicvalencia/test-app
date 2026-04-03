import Foundation

struct OrderRowModel: Identifiable, Equatable {
    let id: UUID
    let number: String
    let status: OrderStatus
    let destination: String
    let etaText: String
}

struct OrderDetailModel: Equatable {
    let number: String
    let destination: String
    let currentStatus: OrderStatus
    let lastUpdatedText: String
}
