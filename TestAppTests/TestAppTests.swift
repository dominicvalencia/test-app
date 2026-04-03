import Foundation
import Testing
@testable import TestApp

struct TestAppTests {
    @Test
    func mockServiceSuccessFetchReturnsOrders() async throws {
        let orders = MockOrderService.sampleOrders(baseDate: Date(timeIntervalSince1970: 0))
        let service = MockOrderService(scenario: .success(orders), fetchDelaySeconds: 0)

        let fetched = try await service.fetchOrders()

        #expect(fetched.count == orders.count)
        #expect(fetched == orders)
    }

    @Test
    func mockServiceEmptyFetchReturnsEmpty() async throws {
        let service = MockOrderService(scenario: .empty, fetchDelaySeconds: 0)

        let fetched = try await service.fetchOrders()

        #expect(fetched.isEmpty)
    }

    @Test
    func mockServiceFailureFetchThrows() async {
        let service = MockOrderService(scenario: .failure(message: "Network down"), fetchDelaySeconds: 0)

        await #expect(throws: MockOrderServiceError.self) {
            _ = try await service.fetchOrders()
        }
    }

    @Test
    func mockServiceStatusUpdatesFollowPlan() async {
        let order = Order(id: UUID(), number: "ORD-2001", status: .pending, destination: "Austin, TX", eta: Date())
        let fixedDate = Date(timeIntervalSince1970: 1234)
        let service = MockOrderService(
            scenario: .success([order]),
            fetchDelaySeconds: 0,
            statusPlan: MockOrderService.StatusPlan(statuses: [.pending, .inTransit, .delivered], intervalSeconds: 0),
            dateProvider: { fixedDate }
        )

        var updates: [OrderStatusUpdate] = []
        for await update in service.statusUpdates(for: order) {
            updates.append(update)
        }

        #expect(updates.map(\.status) == [.pending, .inTransit, .delivered])
        #expect(updates.allSatisfy { $0.timestamp == fixedDate })
    }

    @Test
    func orderListViewModelLoadsAndFilters() async {
        let orders = [
            Order(id: UUID(), number: "ORD-1", status: .pending, destination: "Seattle, WA", eta: Date()),
            Order(id: UUID(), number: "ORD-2", status: .inTransit, destination: "Portland, OR", eta: Date())
        ]
        let service = MockOrderService(scenario: .success(orders), fetchDelaySeconds: 0)
        let viewModel = await OrderListViewModel(initialFilter: .pending, orderProvider: service)

        await viewModel.loadOrders()

        switch await viewModel.state {
        case .loaded(let items, let filter):
            #expect(filter == .pending)
            #expect(items.count == 1)
            #expect(items.first?.status == .pending)
        default:
            Issue.record("Expected loaded state")
        }

        await viewModel.updateFilter(.delivered)

        switch await viewModel.state {
        case .empty(let filter):
            #expect(filter == .delivered)
        default:
            Issue.record("Expected empty state after filtering")
        }
    }

    @Test
    func orderListViewModelFailureState() async {
        let service = MockOrderService(scenario: .failure(message: "Timeout"), fetchDelaySeconds: 0)
        let viewModel = await OrderListViewModel(initialFilter: .pending, orderProvider: service)

        await viewModel.loadOrders()

        switch await viewModel.state {
        case .failed(let message, let filter):
            #expect(filter == .pending)
            #expect(message.contains("Timeout"))
        default:
            Issue.record("Expected failed state")
        }
    }

    @Test
    func orderDetailViewModelUpdatesState() async {
        let order = Order(id: UUID(), number: "ORD-3", status: .pending, destination: "Dallas, TX", eta: Date())
        let fixedDate = Date(timeIntervalSince1970: 555)
        let service = MockOrderService(
            scenario: .success([order]),
            fetchDelaySeconds: 0,
            statusPlan: MockOrderService.StatusPlan(statuses: [.inTransit, .delivered], intervalSeconds: 0),
            dateProvider: { fixedDate }
        )
        let viewModel = await OrderDetailViewModel(order: order, orderProvider: service, dateProvider: { fixedDate })

        await viewModel.startUpdates()
        try? await Task.sleep(nanoseconds: 1_000_000)

        switch await viewModel.state {
        case .active(let model):
            #expect([OrderStatus.inTransit, .delivered].contains(model.currentStatus))
            #expect(model.lastUpdatedText.contains("1970"))
        default:
            Issue.record("Expected active state")
        }
    }
}
