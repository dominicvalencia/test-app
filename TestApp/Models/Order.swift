import Foundation

struct Order: Identifiable, Equatable, Codable {
    let id: UUID
    let number: String
    let status: OrderStatus
    let destination: String
    let eta: Date
}
