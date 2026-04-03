# Delivery Tracking iOS App

A SwiftUI app that lists delivery orders and shows live status updates. 

## Architecture & Data Flow

**Architecture:** MVVM with state enums.

**Layers:**
- **Domain models** (Order, OrderStatus).
- **UI models** (OrderRowModel, OrderDetailModel).
- **Data source** (OrderProviding, MockOrderService).
- **View models** (OrderListViewModel, OrderDetailViewModel, state enums).
- **Views** (OrderListView, OrderDetailView).

**Data flow:**
1. ContentView creates a mocked OrderProviding and passes it into OrderListView.
2. OrderListViewModel.loadOrders() fetches orders from OrderProviding.
3. The view model applies the selected filter and emits an OrderListState (loading, loaded, empty, failed).
4. OrderListView renders the list or the appropriate state view based on OrderListState.
5. Selecting an order creates OrderDetailViewModel, which subscribes to OrderProviding.statusUpdates(for:).
6. Status updates produce an OrderDetailState.active with updated UI model data.

**Why this approach:**
- Separation of concerns.
- Explicit state enums.
- Dependency injection.

## Domain vs UI Models

- **Domain model (Order)** represents raw data (as if from an API).
- **UI models** (OrderRowModel, OrderDetailModel) tailored for display formatted texts

## Testability by Design

**Design choices:**
- OrderProviding protocol enables injecting a mock.
- State enums allow testing state transitions directly.

**Trade-offs:**
- Added boilerplate for models and state enums.
- Some view models need proper mapping domain to UI models.

## Safe Evolution

**Required changes:**
- Add case cancelled to OrderStatus.
- Update filtering UI to include the new case.
- Update mappings.
- Update tests.

**What would break:**
- Switch statements on OrderStatus will fail to compile until updated.

## Testing Strategy

**What is tested:**
- Mock data source behavior for different statuses.
- Different states, filter updates, and error handling.

**What is not tested:**
- Rendering and animations.
- End to end UI tests.

**How tests influenced design:**
- Protocol based data source and state enums were chosen to make unit tests direct.

## Trade-offs

- Only one mock data source is provided.
- Minimal UI styling and no offline support.

## Future Improvements

- Offline caching.
- Retries.
- Networking layer.
- UI styling.
- UI tests.
# test-app
