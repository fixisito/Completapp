# Quality Baseline

This document establishes the current quality baseline and the immediate test gaps for CompletApp.

## Static Analysis and Tests

- `flutter analyze`: command executed in the current environment, but it timed out before producing analyzer output.
- `flutter test`: command executed in the current environment, but it timed out before producing test output.
- Current verifiable automated test inventory:
  - `test/widget_test.dart`: one smoke test for app boot.

## Observed Quality Risks

1. Low automated coverage for critical business logic.
2. Domain logic mixed with UI widgets in feature screens.
3. Persistence concerns centralized in a single broad service class.
4. Silent exception handling in storage code paths.

## Test Gap Map (Priority)

- **High**
  - Calculator cost and package selection calculations.
  - Pet progression and level-up rules.
  - Mini-game scoring rules and penalties.
- **Medium**
  - Persistence adapters for calculator, pet, and game domains.
  - API contract parsing/fallback behavior for future remote prices.
- **Low**
  - Snapshot/widget coverage for visual regressions.

## Next Actions

1. Add unit tests for calculator and pet progression rules.
2. Extract domain logic from screens into pure, testable classes.
3. Split persistence by domain and remove silent catches.
