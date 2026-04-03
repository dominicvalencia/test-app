import SwiftUI

struct OrderListView: View {
    @StateObject private var viewModel: OrderListViewModel
    private let orderProvider: OrderProviding

    init(orderProvider: OrderProviding) {
        self.orderProvider = orderProvider
        _viewModel = StateObject(wrappedValue: OrderListViewModel(orderProvider: orderProvider))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                statusFilter
                content
            }
            .padding(.horizontal)
            .navigationTitle("Orders")
        }
        .task {
            await viewModel.loadOrders()
        }
    }

    private var statusFilter: some View {
        Picker("Status", selection: filterBinding) {
            ForEach(OrderStatus.allCases) { status in
                Text(status.displayName).tag(status)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Filter orders by status")
    }

    private var content: some View {
        switch viewModel.state {
        case .idle:
            return AnyView(loadingView(message: "Ready to load orders"))
        case .loading:
            return AnyView(loadingView(message: "Loading orders"))
        case .empty:
            return AnyView(emptyView)
        case .failed(let message, _):
            return AnyView(errorView(message: message))
        case .loaded(let items, _):
            return AnyView(orderList(items: items))
        }
    }

    private func orderList(items: [OrderRowModel]) -> some View {
        List(items) { item in
            if let order = viewModel.order(for: item.id) {
                NavigationLink {
                    OrderDetailView(viewModel: OrderDetailViewModel(order: order, orderProvider: orderProvider))
                } label: {
                    OrderRowView(item: item)
                }
            }
        }
        .listStyle(.plain)
    }

    private func loadingView(message: String) -> some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Text("No orders")
                .font(.headline)
            Text("There are no orders matching this status.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task {
                    await viewModel.loadOrders()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var filterBinding: Binding<OrderStatus> {
        Binding(
            get: { viewModel.state.filter },
            set: { viewModel.updateFilter($0) }
        )
    }
}

private struct OrderRowView: View {
    let item: OrderRowModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.number)
                    .font(.headline)
                Spacer()
                statusBadge
            }

            Text("Destination: \(item.destination)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("ETA: \(item.etaText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private var statusBadge: some View {
        Text(item.status.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.2))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch item.status {
        case .pending:
            return .orange
        case .inTransit:
            return .blue
        case .delivered:
            return .green
        }
    }
}
