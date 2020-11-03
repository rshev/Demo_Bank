#  Starling test exercise by Roman Shevtsov

Please see original requirements in [pdf](Starling_Bank_Engineering__Technical_Challenge_.pdf)

## How to run
- Xcode 11.3.1
- Please insert your `apiAccessToken` in `Configuration.swift` 

## Project highlights

### UI
- barebones logger-style
- autolayout with safe areas
- dark mode support

### Architecture
- Separation of concerns (`BankManager` and `ViewModel`)
- Dependency injection
- MVVM with passing `ViewData` via delegate pattern
- API wrapper around `URLSession` utilising generics
- API consumes `Endpoint` encapsulating strongly-typed request and response 

### What could be improved given more time
- Chaining of API calls done via Operations/ProcedureKit/RxSwift. Considering that I needed to chain 2 API calls at most, I've chosen the simplest solution possible
- Round up extracted out into a separate object and tested more thoroughly
- More tests. Everything is made testable, but due to repetetive nature of tests and time constraints, I did not cover API helpers and all possible scenarios in business logic
- Better UI obviously
