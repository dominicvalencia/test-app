import Foundation

enum OrderStatus: String, CaseIterable, Codable, Equatable, Identifiable {
    case pending = "PENDING"
    case inTransit = "IN_TRANSIT"
    case delivered = "DELIVERED"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .inTransit:
            return "In Transit"
        case .delivered:
            return "Delivered"
        }
    }
}
