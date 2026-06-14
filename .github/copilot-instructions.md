# Repository Instructions for GitHub Copilot

This repository is a Flutter mental health app for journaling, symptom tracking, weekly trends, and AI-generated insight summaries. Optimize for calm, trustworthy, clinically respectful UX and low-friction daily use. Treat all user mental health data as sensitive.

## Stack And Project Shape

- Use the existing stack already present in this repo: `flutter_bloc` for app state, `go_router` for routing, `hive` for local storage, and `get_it` for dependency injection.
- Keep the feature-first structure under `lib/features` and shared infrastructure under `lib/core`.
- Important locations:
  - `lib/main.dart`: app entry point
  - `lib/app.dart`: app wiring
  - `lib/core/di`: dependency registration
  - `lib/core/router`: centralized router configuration
  - `lib/core/theme`: theme and visual system
  - `test`: unit and widget tests

## Architecture Rules

- Follow Clean Architecture and SOLID consistently.
- Separate presentation, domain, and data layers.
- Domain code must not depend on Flutter widgets, Hive, or networking details.
- Keep responsibilities narrow. Split files and classes once they begin handling multiple concerns.
- Reuse nearby patterns before introducing new abstractions.
- Keep production files between 200 and 300 lines maximum. Refactor before they become large.

## State Management

- Use BLoC or Cubit for app state. Do not introduce Riverpod, Provider-based app state, GetX, or other state frameworks unless explicitly requested.
- Keep one BLoC or Cubit per feature flow or screen slice.
- Keep events, states, and transitions explicit, immutable, and easy to test.
- Put business rules in use cases and domain services, not in widgets.
- Use `BlocListener` for one-off side effects and `BlocBuilder`, `BlocSelector`, or `context.select()` to minimize rebuilds.
- Do not dispatch events from `build()`.
- Keep ephemeral widget-only state local when BLoC is unnecessary.

## Routing

- Use `go_router` exclusively.
- Define routes centrally in `lib/core/router`.
- Keep route builders thin and validate required route data before rendering screens.
- Keep redirect logic deterministic and side-effect free.
- Trigger navigation from state changes through routing logic or `BlocListener`, not ad hoc widget code.

## Persistence And DI

- Use Hive for local persistence and lightweight caching.
- Keep Hive models and adapters in the data layer, then map them to domain entities.
- Do not leak Hive-specific types into presentation or domain code.
- Use `get_it` in `lib/core/di` as the composition root.
- Prefer constructor injection everywhere else.
- Register abstractions to concrete implementations clearly and explicitly.

## UI, UX, And Accessibility

- Build a premium Material 3 interface that feels calm, supportive, and modern, not generic.
- Prefer soft, reassuring colors with strong contrast and clear semantic meaning.
- Reduce cognitive load with strong hierarchy, whitespace, and concise microcopy.
- Avoid alarming language, panic-inducing visuals, or medical certainty in insight text.
- Prefer `StatelessWidget` unless local mutable UI state is truly necessary.
- Minimize rebuilds, use `const` wherever possible, and never do storage, network, or heavy work in `build()`.
- Make all interactive elements accessible with semantic labels, adequate tap targets, and text that remains usable at large accessibility font sizes.
- Do not rely on color alone for status or chart meaning.

## Code Quality And Performance

- Write null-safe Dart and avoid the null assertion operator `!` unless safety is proven locally.
- Prefer `async` and `await`, catch failures explicitly, and surface meaningful domain failures.
- Use `dart:developer` `log()` instead of `print()`.
- Favor immutable models, `final` fields, small methods, and explicit naming.
- Use `ListView.builder` or slivers for dynamic collections.
- Extract widgets and logic early to keep code testable, maintainable, and scalable.

## Testing And Validation

- Write testable code by default using pure use cases and constructor injection.
- Add unit tests for domain logic, `bloc_test` coverage for BLoCs and Cubits, and widget tests for key UI flows and states.
- Prefer fakes over heavy mocking where practical.
- Always run `dart format .` after Dart changes.
- Run `dart fix --apply` when it provides safe cleanups.
- Run `flutter analyze .` before completing non-trivial work.
- Run `flutter test .` when changing logic, state, routing, storage, or widgets.
- If Hive model annotations change, run `dart run build_runner build --delete-conflicting-outputs`.

## Privacy And Safety

- Treat mental health content, journaling data, and symptom history as sensitive.
- Minimize logging of user-entered content.
- Never hardcode API keys or secrets.
- Keep AI provider configuration environment-based.
- Sanitize and shape external AI responses before presenting them in the UI.

Trust these instructions first when working in this repository. Search more broadly only when these instructions and the nearby feature structure are insufficient.