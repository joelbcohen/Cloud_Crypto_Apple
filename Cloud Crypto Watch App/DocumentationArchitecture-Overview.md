# Cloud Crypto watchOS - Architecture Overview

This document provides a comprehensive overview of the Cloud Crypto watchOS app architecture, design patterns, and technical decisions.

## Architecture Pattern: MVVM

The app follows the **Model-View-ViewModel (MVVM)** pattern with additional layers for services and repositories.

```
┌─────────────────────────────────────────────────────────────┐
│                         Views Layer                          │
│  (SwiftUI Views - Declarative UI with @StateObject)         │
│                                                              │
│  MainScreenView, RegistrationFormView, AccountSummaryView,  │
│  TransferView, LoadingView, ErrorView                       │
└────────────────────┬─────────────────────────────────────────┘
                     │ Observes
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                      ViewModel Layer                         │
│     (ObservableObject - State Management & Logic)           │
│                                                              │
│              RegistrationViewModel                           │
│  - @Published properties (uiState, serialNumber, etc.)      │
│  - Business logic methods                                   │
│  - Coordinates repository operations                        │
└────────────────────┬─────────────────────────────────────────┘
                     │ Uses
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                    Repository Layer                          │
│          (Data Access & Business Logic)                     │
│                                                              │
│            RegistrationRepository                            │
│  - Coordinates between services                             │
│  - Implements business logic                                │
│  - Manages data flow                                        │
└────────────────────┬─────────────────────────────────────────┘
                     │ Uses
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                     Services Layer                           │
│    (Specialized functionality & external integrations)      │
│                                                              │
│  NetworkService  │  DeviceInfoService  │  AttestationService│
│  KeychainService │  APNsService                             │
│                                                              │
│  Each service is an Actor or @MainActor class               │
└────────────────────┬─────────────────────────────────────────┘
                     │ Stores/Retrieves
                     ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│                                                              │
│  UserDefaults  │  Keychain  │  Network API                  │
└─────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. Views (SwiftUI)

**Purpose**: Present UI and capture user interactions

**Components**:
- `ContentView`: Root view with state switching
- `MainScreenView`: Main screen with action buttons
- `RegistrationFormView`: Device registration input
- `AccountSummaryView`: Display account information
- `TransferView`: Transfer funds interface
- `LoadingView`: Loading state indicator
- `ErrorView`: Error state with retry

**Characteristics**:
- Pure SwiftUI views
- No business logic
- Receive data via parameters
- Communicate via callbacks
- Observe ViewModel via `@StateObject` or `@ObservedObject`

### 2. ViewModel

**Purpose**: Manage UI state and coordinate operations

**Class**: `RegistrationViewModel`

**Responsibilities**:
- Hold UI state (`@Published` properties)
- Coordinate user actions
- Call repository methods
- Handle errors and show messages
- Manage navigation state

**Key Properties**:
```swift
@Published var uiState: RegistrationUiState
@Published var serialNumber: String
@Published var toastMessage: String?
@Published var toAccount: String
@Published var amount: String
@Published var isTransferring: Bool
@Published var showDeregisterConfirmation: Bool
```

**Key Methods**:
- `loadMainScreen()` - Load and display main screen
- `registerDevice()` - Handle registration flow
- `showAccountScreen()` - Fetch and display account
- `executeTransfer()` - Perform transfer operation
- `deregisterDevice()` - Handle deregistration

### 3. Repository

**Purpose**: Abstract data access and business logic

**Class**: `RegistrationRepository`

**Responsibilities**:
- Coordinate between services
- Implement business logic
- Transform data between layers
- Handle data persistence
- Manage registration lifecycle

**Pattern**: Facade pattern for services

**Key Methods**:
```swift
func registerDevice(serialNumber:apnsToken:) async throws -> RegistrationResponse
func deregisterDevice() async throws -> DeregistrationResponse
func getAccountSummary() async throws -> AccountSummaryResponse
func executeTransfer(toAccountId:amount:) async throws -> TransferResponse
```

### 4. Services

**Purpose**: Specialized functionality and external integrations

#### NetworkService (Actor)

**Responsibilities**:
- Make HTTP requests
- Encode/decode JSON
- Handle network errors
- Manage timeouts

**Pattern**: Service pattern with async/await

**API Methods**:
- `registerDevice(_:)` - POST /public/crypto/register
- `deregisterDevice(_:)` - POST /public/crypto/deregister
- `getAccountSummary(_:)` - POST /public/crypto/account_summary
- `executeTransfer(_:)` - POST /public/crypto/transfer

#### DeviceInfoService (Actor)

**Responsibilities**:
- Collect device information
- Generate serial numbers
- Access WKInterfaceDevice APIs

#### AttestationService (Actor)

**Responsibilities**:
- Generate RSA key pairs
- Export keys as Base64
- Generate attestation blobs
- Manage key lifecycle

**Security**: Uses SecKey API with Keychain storage

#### KeychainService (Actor)

**Responsibilities**:
- Store/retrieve sensitive data
- Manage Keychain operations
- Handle security attributes

**Storage**: Uses `kSecClassGenericPassword` with secure accessibility

#### APNsService (@MainActor)

**Responsibilities**:
- Request notification authorization
- Register for remote notifications
- Handle incoming notifications
- Process notification payloads

**Pattern**: Delegate pattern with UNUserNotificationCenter

### 5. Models

**Purpose**: Define data structures

**Categories**:

**Registration Models**:
- `RegistrationRequest` - Device registration payload
- `RegistrationResponse` - Server response
- `DeregistrationRequest` - Deregistration payload
- `DeregistrationResponse` - Server response

**Account Models**:
- `AccountSummaryRequest` - Account query payload
- `AccountSummaryResponse` - Server response
- `AccountSummaryData` - Account details
- `TransferRequest` - Transfer payload
- `TransferResponse` - Server response

**Local Models**:
- `RegistrationStatus` - Local registration state
- `RegistrationUiState` - UI state enum

### 6. Utilities

**Purpose**: Helper functions and extensions

**Components**:
- `UserDefaultsManager` - UserDefaults abstraction
- `NumberFormatter+Extensions` - Number formatting helpers
- `DateFormatter` extensions - Date formatting

## Data Flow

### Registration Flow

```
User taps REGISTER
    ↓
View calls viewModel.registerDevice()
    ↓
ViewModel calls repository.registerDevice()
    ↓
Repository coordinates:
    1. AttestationService.generateKeyPair()
    2. DeviceInfoService.collectDeviceInfo()
    3. AttestationService.generateAttestationBlob()
    4. NetworkService.registerDevice()
    ↓
Repository saves to UserDefaults
    ↓
ViewModel updates uiState
    ↓
View re-renders with new state
```

### Account Summary Flow

```
User taps ACCOUNT
    ↓
View calls viewModel.showAccountScreen()
    ↓
ViewModel sets uiState = .loading
    ↓
ViewModel calls repository.getAccountSummary()
    ↓
Repository loads registration status from UserDefaults
    ↓
Repository calls NetworkService.getAccountSummary()
    ↓
NetworkService makes HTTP request
    ↓
Response decoded and returned
    ↓
ViewModel sets uiState = .accountSummary(data)
    ↓
View displays AccountSummaryView
```

### Transfer Flow

```
User taps SEND
    ↓
View calls viewModel.executeTransfer()
    ↓
ViewModel validates inputs
    ↓
ViewModel sets isTransferring = true
    ↓
ViewModel calls repository.executeTransfer()
    ↓
Repository loads registration status
    ↓
Repository calls NetworkService.executeTransfer()
    ↓
NetworkService makes HTTP request
    ↓
Response received and decoded
    ↓
ViewModel updates toastMessage
    ↓
ViewModel returns to main screen
```

## State Management

### UI State Enum

```swift
enum RegistrationUiState: Equatable {
    case mainScreen(serialNumber: String?, timestamp: TimeInterval)
    case registrationForm
    case accountSummary(data: AccountSummaryData)
    case transferScreen
    case loading
    case error(message: String)
}
```

**Benefits**:
- Type-safe state representation
- Exhaustive switch statements
- Clear state transitions
- Associated values for screen data

### Published Properties

```swift
@Published var uiState: RegistrationUiState
@Published var toastMessage: String?
```

**Benefits**:
- Automatic UI updates via Combine
- SwiftUI observes changes
- Type-safe property access

## Concurrency Model

### Swift Concurrency (async/await)

The app uses modern Swift concurrency:

**Actor Classes**: Services use Actor to ensure thread safety
```swift
actor NetworkService { }
actor DeviceInfoService { }
actor AttestationService { }
```

**@MainActor Classes**: UI-related classes run on main thread
```swift
@MainActor
class RegistrationViewModel: ObservableObject { }

@MainActor
class APNsService: ObservableObject { }
```

**Async Methods**: Network and heavy operations use async
```swift
func registerDevice() async throws -> RegistrationResponse
```

**Task Management**: ViewModel uses Task for async work
```swift
Task {
    uiState = .loading
    let response = try await repository.registerDevice()
    uiState = .mainScreen(...)
}
```

## Security Architecture

### Key Generation

1. **Algorithm**: RSA 2048-bit
2. **Storage**: iOS Keychain
3. **Attributes**:
   - `kSecAttrKeyTypeRSA`
   - `kSecAttrKeySizeInBits: 2048`
   - `kSecAttrIsPermanent: true`
   - `kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock`

### Data Storage

**Sensitive Data** → Keychain
- Private keys
- (Future: Auth tokens)

**Non-Sensitive Data** → UserDefaults
- Registration status
- Serial number
- Public key
- Timestamp

**Transient Data** → Memory only
- APNs device token (could be persisted)
- Network responses

### Attestation

```
Device Registration
    ↓
Generate RSA Key Pair
    ↓
Export Public Key as Base64
    ↓
Create Attestation Blob (public key + metadata)
    ↓
Send to Server
    ↓
Server verifies attestation
```

## Network Architecture

### Base URL

```swift
private let baseURL = "https://fusio.callista.io"
```

### Endpoints

1. **POST /public/crypto/register** - Register device
2. **POST /public/crypto/deregister** - Deregister device
3. **POST /public/crypto/account_summary** - Get account info
4. **POST /public/crypto/transfer** - Transfer funds

### Request Format

All requests use JSON with:
- Content-Type: application/json
- POST method
- 30 second timeout

### Error Handling

```swift
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case timeout
}
```

## Push Notifications

### Architecture

```
APNs Server
    ↓
watchOS Push Service
    ↓
ExtensionDelegate.didRegisterForRemoteNotifications()
    ↓
APNsService.setDeviceToken()
    ↓
Store token for registration
    ↓
User registers device
    ↓
Token sent to backend
    ↓
Backend can now send notifications
    ↓
Notification received
    ↓
UNUserNotificationCenterDelegate methods
    ↓
APNsService.handleNotification()
    ↓
Process payload and update UI
```

### Notification Types

1. **registration_update** - Registration status changed
2. **config_update** - App configuration changed
3. **status_update** - Account status changed

## Complications

### Architecture

```
WidgetKit Timeline Provider
    ↓
CloudCryptoComplicationProvider
    ↓
Read registration status from UserDefaults
    ↓
Create ComplicationEntry
    ↓
Return Timeline with entries
    ↓
WidgetKit renders complication
    ↓
Updates hourly or on demand
```

### Supported Families

- `.accessoryCircular` - Small circular
- `.accessoryCorner` - Corner position
- `.accessoryInline` - Inline text
- `.accessoryRectangular` - Rectangular

### Update Strategy

1. **Hourly**: Automatic updates every hour
2. **On-demand**: Via `WidgetCenter.shared.reloadAllTimelines()`
3. **Notification**: Update when push notification received

## Error Handling Strategy

### Layers of Error Handling

**1. Service Layer**: Throws specific errors
```swift
throw NetworkError.httpError(statusCode: 404, message: "Not found")
```

**2. Repository Layer**: Catches and transforms errors
```swift
catch {
    throw RepositoryError.registrationFailed(error)
}
```

**3. ViewModel Layer**: Catches and presents to user
```swift
catch {
    toastMessage = "Registration failed: \(error.localizedDescription)"
    uiState = .error(message: error.localizedDescription)
}
```

**4. View Layer**: Displays error UI
```swift
case .error(let message):
    ErrorView(message: message, onRetry: { ... })
```

## Testing Strategy

### Unit Tests

**Test**:
- ViewModel business logic
- Service methods
- Data transformations
- Error handling

**Mock**:
- Network service
- Repository
- Services

### Integration Tests

**Test**:
- Full registration flow
- Network requests (with mock server)
- Data persistence
- State transitions

### UI Tests

**Test**:
- Navigation flow
- User interactions
- Error states
- Loading states

## Performance Optimizations

### Network

- 30-second timeouts
- Request cancellation on view disappear
- Async/await for non-blocking operations

### Data Persistence

- UserDefaults for fast access
- Keychain only for sensitive data
- In-memory caching of registration status

### UI

- SwiftUI automatic optimization
- Lazy loading where appropriate
- Minimal view re-renders

### Battery

- No continuous background tasks
- Network requests on-demand only
- Efficient complication updates

## Design Patterns Used

1. **MVVM** - Overall architecture
2. **Repository** - Data access abstraction
3. **Service** - Specialized functionality
4. **Observer** - SwiftUI @Published + Combine
5. **Facade** - Repository hides service complexity
6. **Delegate** - APNs notification handling
7. **Factory** - Date/Number formatters
8. **Singleton** - UserDefaults, WKInterfaceDevice

## Future Enhancements

### Architecture Improvements

- [ ] Implement proper dependency injection
- [ ] Add error logging service
- [ ] Add analytics service
- [ ] Implement offline mode with sync
- [ ] Add database layer (Core Data or Realm)

### Feature Enhancements

- [ ] Multi-account support
- [ ] Transaction history
- [ ] Biometric authentication
- [ ] QR code scanning
- [ ] Rich notifications
- [ ] Live Activities

### Code Quality

- [ ] Unit test coverage > 80%
- [ ] UI test coverage > 60%
- [ ] Documentation coverage > 90%
- [ ] Code review process
- [ ] Continuous integration

## Conclusion

The Cloud Crypto watchOS app is built with:

- **Modern Swift**: Concurrency, actors, async/await
- **Clean Architecture**: MVVM with clear separation
- **Security First**: Keychain, RSA encryption
- **User Experience**: Loading states, error handling
- **Scalability**: Easy to add features and test
- **Maintainability**: Clear structure and documentation

This architecture provides a solid foundation for a production-ready watchOS cryptocurrency app.

---

Last Updated: November 20, 2025
