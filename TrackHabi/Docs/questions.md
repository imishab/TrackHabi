Interview Questions Based on Your M4Movies Project

Architecture & Design Patterns

1. What architecture pattern did you use in this project?
  - Answer: Clean Architecture — Domain (models + repository protocols), Data (DTOs + repository implementations), Presentation (ViewModels + Views). Separation of concerns so the domain layer has no dependency on UIKit/SwiftUI.
2. Why did you use protocol-based repositories like MovieRepository?
  - Answer: Abstraction — the ViewModel only depends on the protocol, not the concrete implementation. This makes it testable (you can inject a mock) and swappable.
3. What is the difference between a DTO and a Domain Model? Why did you separate them?
  - Answer: DTOs (like MovieDTO) map the raw API JSON. Domain models (Movie) are what the app uses internally. Separation means API changes don't break the whole app.
4. What is the Repository pattern and why did you apply it?
  - Answer: An abstraction layer between the data source (API/CoreData) and the business logic. Your MovieRepositoryImpl handles both networking and mapping.

---
Swift Concurrency (async/await)

5. How did you perform parallel API calls in HomeViewModel?
  - Answer: Used async let for all three fetches (popular, nowPlaying, topRated), then awaited them together with a tuple — so they run concurrently instead of sequentially.
6. What is @MainActor and why do your ViewModels use it?
  - Answer: Ensures all property updates happen on the main thread, since SwiftUI requires UI updates to be on the main thread. Marking the class @MainActor means every method runs on main by default.
7. How did you implement search debouncing?
  - Answer: Each keystroke cancels the previous Task with searchTask?.cancel(), then creates a new one with Task.sleep(for: .milliseconds(350)) before firing the actual request.
8. What does [weak self] do inside the search Task, and why is it needed?
  - Answer: Prevents a retain cycle. The Task captures self; if the ViewModel is deallocated, [weak self] avoids keeping it alive and crashing.

---
SwiftUI & Observation

9. What is @Observable and how is it different from ObservableObject?
  - Answer: @Observable (Swift 5.9 Observation framework) is more efficient — it tracks only the specific properties a view actually reads, vs ObservableObject which triggers a full view re-render on any @Published change.
10. How did you pass FavoritesStore down the view hierarchy?
  - Answer: Injected it via .environment(favoritesStore) at the root, then any child view reads it with @Environment(FavoritesStore.self).
11. How does the shimmer/skeleton loading work?
  - Answer: Custom ViewModifier (ShimmerModifier) overlays a LinearGradient and animates its offset infinitely. It also respects accessibilityReduceMotion to disable animation for accessibility.

---
CoreData

12. Why did you build the CoreData model in code (makeModel()) instead of using a .xcdatamodeld file?
  - Answer: Keeps the schema in code (version-controlled, no binary XML), and allows programmatic setup — especially useful for the inMemory mode used in testing.
13. What does inMemory: Bool in PersistenceController do?
  - Answer: Redirects the store to /dev/null so data is never persisted to disk — ideal for unit tests so tests don't pollute real data.
14. What merge policy did you use and why?
  - Answer: NSMergeByPropertyObjectTrumpMergePolicy — in-memory changes win over persistent store changes, preventing conflicts when background contexts write and the view context needs to merge.

---
Networking

15. How does your generic APIClient.request<T: Decodable> work?
  - Answer: Takes any Endpoint, builds a URL, fires URLSession.data(from:), validates the HTTP status code (200–299), then decodes the response into the generic type T using JSONDecoder.
16. How do you handle errors in the network layer?
  - Answer: Custom NetworkError enum with cases like .invalidURL, .invalidResponse, .decodingError. Thrown up the chain for ViewModels to catch and show user-facing messages.
17. How does pagination / infinite scroll work in search?
  - Answer: prefetchTriggerID is set to the item 5 positions before the end. When that item appears, loadMoreIfNeeded fires and fetches currentPage + 1.

---
General iOS / Swift

18. What is defer and where did you use it?
  - Answer: Code that always runs when the current scope exits. Used in ViewModels to reset isLoading = false even if an error is thrown.
19. Why did you use a Set<Int> for favoriteIDs alongside the [Movie] array?
  - Answer: O(1) lookup for isFavorite(_ id:). The array is for displaying in order; the Set is for fast membership checks.
20. How did you handle the splash screen?
  - Answer: ZIndex layering in ZStack — SplashView sits on top with .zIndex(1), and after 1.8s a .task removes it with an .easeOut opacity transition.

---
Bonus (Be ready for these)

- How would you add unit tests to this project? (Answer: Inject mock repositories via the protocol, use PersistenceController(inMemory: true) for CoreData tests)
- How would you improve offline support? (Cache API responses in CoreData)
- What is the TMDB API and how did you secure the API key? (Config.swift excluded from git via .gitignore; mention the Config.swift.example pattern)

---
Good luck tomorrow! The strongest areas to review are Clean Architecture, async/await + async let concurrency, @Observable vs ObservableObject, and CoreData setup in code.