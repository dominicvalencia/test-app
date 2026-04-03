import SwiftUI

struct OrderDetailView: View {
    @StateObject var viewModel: OrderDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            content
            Spacer()
        }
        .padding()
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.startUpdates()
        }
        .onDisappear {
            viewModel.stopUpdates()
        }
    }

    private var content: some View {
        switch viewModel.state {
        case .loading:
            return AnyView(loadingView)
        case .failed(let message):
            return AnyView(errorView(message: message))
        case .active(let model):
            return AnyView(detailView(model: model))
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading status updates")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func detailView(model: OrderDetailModel) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(model.number)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Destination: \(model.destination)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            statusCard(model: model)

            Text("Last updated: \(model.lastUpdatedText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusCard(model: OrderDetailModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Status")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(model.currentStatus.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            Spacer()
            Image(systemName: iconName(for: model.currentStatus))
                .font(.system(size: 32))
                .foregroundStyle(statusColor(for: model.currentStatus))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(statusColor(for: model.currentStatus).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.easeInOut, value: model.currentStatus)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("Unable to load updates")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .inTransit:
            return .blue
        case .delivered:
            return .green
        }
    }

    private func iconName(for status: OrderStatus) -> String {
        switch status {
        case .pending:
            return "hourglass"
        case .inTransit:
            return "truck.box"
        case .delivered:
            return "checkmark.seal"
        }
    }
}
