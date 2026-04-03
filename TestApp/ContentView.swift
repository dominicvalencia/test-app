import SwiftUI

struct ContentView: View {
    private let orderProvider: OrderProviding = MockOrderService(
        scenario: .success(MockOrderService.sampleOrders())
    )

    var body: some View {
        OrderListView(orderProvider: orderProvider)
    }
}

#Preview {
    ContentView()
}
