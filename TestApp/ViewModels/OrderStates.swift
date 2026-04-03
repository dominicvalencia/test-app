import Foundation

enum OrderListState: Equatable {
    case idle(filter: OrderStatus)
    case loading(filter: OrderStatus)
    case loaded(items: [OrderRowModel], filter: OrderStatus)
    case empty(filter: OrderStatus)
    case failed(message: String, filter: OrderStatus)

    var filter: OrderStatus {
        switch self {
        case .idle(let filter), .loading(let filter), .loaded(_, let filter), .empty(let filter), .failed(_, let filter):
            return filter
        }
    }
}

enum OrderDetailState: Equatable {
    case loading
    case active(OrderDetailModel)
    case failed(message: String)
}
