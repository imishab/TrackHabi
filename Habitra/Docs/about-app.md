# Habitra
### iOS App Overview · July 2026

---

## What is Habitra?

Habitra is a native iOS habit-tracking app built entirely with **SwiftUI** and **Swift Concurrency**. It lets users create daily/weekly habits, check them off, and track streaks — all locally, with a polished dark-mode UI.

> Zero third-party dependencies. 100% Apple frameworks. No network layer — everything is stored on-device.

---

## Feature Walkthrough

| # | Feature | What it does |
|---|---------|-------------|
| 1 | **Splash Screen** | Animated logo fade-in on launch (~1.8s) |
| 2 | **Habits (Today)** | List of habits scheduled for today with one-tap check-off |
| 3 | **Add Habit** | Create a habit with a name, icon, color, and repeat days |
| 4 | **Habit Detail** | Current streak, best streak, total completions, 5-week completion calendar |
| 5 | **Settings** | Delete all habits, view app version |

---

## Architecture : Clean Architecture + MVVM

The app is split into **3 clear layers**. Each layer only talks to the one below it.

```
┌─────────────────────────────────────────────┐
│              PRESENTATION LAYER             │
│   SwiftUI Views  +  @Observable ViewModels  │
└─────────────────────┬───────────────────────┘
                      │  calls protocols
┌─────────────────────▼───────────────────────┐
│                DOMAIN LAYER                 │
│   Models (Habit, HabitCompletion…)          │
│   Protocols (HabitRepository)               │
└─────────────────────┬───────────────────────┘
                      │  implemented by
┌─────────────────────▼───────────────────────┐
│                 DATA LAYER                  │
│   CoreData (code-defined model)             │
│   Repository Implementation                 │
└─────────────────────────────────────────────┘
```

### Why this structure?
- **Domain layer has zero framework imports** : pure Swift, fully testable
- **Swapping the persistence layer** (e.g. to CloudKit sync) only changes the Data layer
- **ViewModels never touch CoreData directly** : they call the `HabitRepository` protocol

---

## File Structure

```
Habitra/
│
├── App/
│   └── HabitraApp.swift         ← @main entry point, dark mode, splash logic
│
├── Core/
│   └── Persistence/
│       ├── PersistenceController.swift   ← CoreData stack (code-defined, no .xcdatamodeld)
│       ├── HabitEntity.swift             ← CoreData entity: habits
│       └── HabitCompletionEntity.swift   ← CoreData entity: per-day check-ins
│
├── Domain/                        ← Pure Swift no framework imports
│   ├── Models/
│   │   ├── Habit.swift             ← Core habit value type (title, icon, color, schedule)
│   │   ├── HabitCompletion.swift   ← A single day's check-in
│   │   ├── HabitStats.swift        ← Streak/best-streak/total calculation
│   │   └── Weekday.swift           ← Enum + bitmask helpers for scheduled days
│   └── Repositories/
│       └── HabitRepository.swift   ← Protocol only, no implementation here
│
├── Data/
│   └── Repositories/
│       └── HabitRepositoryImpl.swift  ← Reads/writes CoreData
│
└── Screens/
    ├── Main/
    │   ├── MainTabView.swift      ← Root TabView (Habits, Settings)
    │   ├── AppTab.swift           ← Tab enum with icons/labels
    │   └── SplashView.swift       ← Animated logo splash
    ├── Habits/
    │   ├── HabitsListView.swift   ← Today's habits, check-off, add/delete
    │   ├── HabitsViewModel.swift  ← Loads habits + today's completions
    │   └── HabitRow.swift         ← Reusable habit row component
    ├── AddHabit/
    │   ├── AddHabitView.swift     ← Name, icon, color, repeat-day picker
    │   └── AddHabitViewModel.swift
    ├── HabitDetail/
    │   ├── HabitDetailView.swift      ← Stats tiles + 5-week completion calendar
    │   └── HabitDetailViewModel.swift ← Streak calculation, toggle completion
    ├── Settings/
    │   └── SettingsView.swift     ← Delete all habits, app version
    └── Common/
        ├── HabitPalette.swift     ← Shared icon/color palette
        └── Shimmer.swift          ← Shimmer animation ViewModifier (reusable)
```

---

## Core Technologies

### SwiftUI
Every screen is built with SwiftUI, no UIKit at all:
- `NavigationStack` + `NavigationLink(value:)` for type-safe navigation
- `.navigationDestination(for:)` for declarative routing
- `TabView` with custom `AppTab` enum
- `ContentUnavailableView` for the empty-habits state

### @Observable Macro (Swift 5.9)
ViewModels use the `@Observable` macro instead of `ObservableObject` + `@Published`.

```swift
@Observable
@MainActor
final class HabitsViewModel {
    private(set) var habits: [Habit] = []
    private(set) var completedHabitIDs: Set<UUID> = []
    // ...
}
```

### CoreData (Code-Defined Model)
Habits and their daily completions are stored locally using CoreData. The data model is defined entirely in Swift code, no `.xcdatamodeld` file — fully diff-able in git.

```
HabitEntity               HabitCompletionEntity
────────────              ──────────────────────
id (String/UUID)          id (String/UUID)
title (String)            habitID (String/UUID)
icon (String)             date (Date, day-normalized)
colorName (String)        completedAt (Date)
scheduledDaysMask (Int16)
createdAt (Date)
isArchived (Bool)
```

Key CoreData features used:
- **Uniqueness constraint** on `HabitEntity.id` prevents duplicates
- **Composite uniqueness constraint** on `HabitCompletionEntity.[habitID, date]` prevents double check-ins on the same day
- **In-memory store** mode available for testing

### Streak Calculation
`HabitStats.calculate` walks backward day-by-day from today (respecting each habit's scheduled weekdays) to compute the current streak, and scans all completions to find the best historical streak — implemented as a pure function in the Domain layer with no CoreData dependency.

---

## Navigation Architecture

```
MainTabView (TabView)
│
├── Tab 1: Habits NavigationStack
│   └── HabitsListView → [tap row] → HabitDetailView
│                       → [tap +]   → AddHabitView (sheet)
│
└── Tab 2: Settings NavigationStack
    └── SettingsView
```

**Each tab has its own independent `NavigationStack`** — switching tabs preserves each tab's navigation state.

---

## Key Design Patterns

| Pattern | Where used | Why |
|---------|-----------|-----|
| **Repository pattern** | Domain + Data layers | Decouples ViewModels from CoreData |
| **Protocol-oriented programming** | `HabitRepository` | Enables unit testing with mock implementations |
| **Value types for domain models** | All `Domain/Models/` are structs | Thread safety, predictable state |
| **Bitmask encoding** | `Weekday.mask(from:)` / `Weekday.set(fromMask:)` | Compact CoreData storage for scheduled days |
| **Pure function streak calc** | `HabitStats.calculate` | Testable without touching persistence |

---

## Tech Stack Summary

```
Language        Swift 5.9+
UI Framework    SwiftUI (100% no UIKit)
State Mgmt      @Observable macro + @MainActor
Concurrency     async/await + structured concurrency
Local Storage   CoreData (code-defined model)
Architecture    Clean Architecture + MVVM
Navigation      NavigationStack (value-based)
Dependencies    None (zero third-party packages)
Min Target      iOS 18
```

---
