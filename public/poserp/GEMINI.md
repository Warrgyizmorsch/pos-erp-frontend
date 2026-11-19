# GEMINI.md — POSERP Development Instructions

## Project

This repository contains the Flutter implementation of POSERP.

The application uses:

* Flutter
* Dart
* GetX
* Repository/Service architecture
* REST backend APIs
* Centralized logging
* Responsive desktop/mobile layouts

## Mandatory Files to Read

Before implementing, modifying, debugging, or reviewing any POSERP module, always read:

1. `design.md`
2. `pos-erp-api-curl-guide.md`

These files exist in the project root.

Do not start module implementation without checking both files.

---

## Source-of-Truth Rules

### `design.md`

Use `design.md` as the source of truth for:

* Flutter architecture
* Folder structure
* UI and design system
* GetX patterns
* Controllers
* Bindings
* Repositories
* Services
* Models
* Navigation
* Responsive behavior
* Module scope
* Implementation phases
* Acceptance criteria

### `pos-erp-api-curl-guide.md`

Use `pos-erp-api-curl-guide.md` as the source of truth for:

* Backend endpoint paths
* HTTP methods
* API base URL
* Path parameters
* Authentication requirements
* Available operations
* Request payloads when fully documented

If the two files conflict about an API endpoint or HTTP method:

`pos-erp-api-curl-guide.md` wins.

---

## Do Not Guess APIs

Never infer backend APIs from:

* Flutter routes
* screen names
* controller names
* repository names
* module names

For example:

Flutter:

```text
/purchases/return
```

does not mean the API is:

```text
/api/purchases/return
```

Always verify the actual endpoint in `pos-erp-api-curl-guide.md`.

---

## API Base URL

Use:

```text
https://pos-erp-backend.onrender.com/api
```

through centralized configuration.

Never hardcode complete API URLs across individual feature files.

Use relative paths through `ApiEndpoints`.

---

## Architecture Rule

All backend-connected features must follow:

```text
View
  ↓
Controller
  ↓
Repository
  ↓
Service / ApiClient
  ↓
Backend
```

### Views

Views must contain:

* UI
* widget composition
* observable bindings
* callbacks to controllers

Views must NOT contain:

* direct HTTP requests
* API URL construction
* backend payload creation
* complex business logic

### Controllers

Controllers handle:

* UI state
* form state
* validation
* repository calls
* loading/error/success state
* navigation
* refreshing displayed data

### Repositories

Repositories handle:

* domain-facing data access
* model conversion
* response normalization
* service calls

### Services

Services handle:

* GET
* POST
* PUT
* DELETE
* headers
* API requests
* low-level response handling

---

## Endpoint Workflow

Before coding each module, create a mental or written API checklist:

```text
Operation
HTTP Method
Endpoint
Path Parameters
Query Parameters
Request Payload
Response Structure
Flutter Service Method
Flutter Repository Method
Flutter Controller Action
```

Verify every required operation against the API guide before implementation.

---

## Payload Rule

If the API guide contains:

```json
{
  "sampleKey": "value"
}
```

or another obvious placeholder, do not treat it as the real backend payload.

Instead:

1. Inspect the equivalent existing Next.js implementation.
2. Find the actual API call.
3. Match its request fields exactly.
4. Match query parameters exactly.
5. Match response parsing exactly.
6. If necessary, inspect the backend controller/schema.

Never invent fields merely to make Flutter compile.

---

## Existing Code First

Before creating a new:

* service
* repository
* model
* widget
* endpoint constant
* formatter
* helper

search the project for an existing reusable implementation.

Do not create duplicate architecture unnecessarily.

---

## ApiEndpoints Rule

Backend paths belong in the centralized endpoint file.

Preferred:

```dart
static const purchaseReturns = '/purchase-returns';

static String purchaseReturn(String id) =>
    '/purchase-returns/$id';
```

Avoid:

```dart
apiClient.get('/purchase-returns');
```

scattered throughout feature files unless the existing project architecture intentionally works differently.

Never put the complete domain URL inside a feature repository or controller.

---

## Authentication

Authenticated requests must use the application's existing bearer-token mechanism.

Do not manually duplicate token-header logic in each repository.

Use the central API client/interceptor.

On `401`, follow the existing application session-expiration behavior.

---

## Logging

Use the existing centralized `logger` implementation.

Log important API failures with enough information to debug:

* module
* operation
* method
* endpoint
* status code
* server message

Do not log:

* passwords
* JWT tokens
* sensitive authentication values

Avoid unnecessary `print()` calls.

---

## Models and JSON

Use strongly typed Dart models where appropriate.

Models should:

* support null safety
* parse real backend field names
* tolerate optional fields where backend responses permit them
* avoid silently renaming API fields without explicit mapping

Do not design a model solely from UI assumptions.

Verify it against the actual API response or existing working frontend.

---

## Error Handling

Every API-connected screen must properly handle:

* initial loading
* refresh loading
* successful response
* empty response
* validation errors
* network errors
* unauthorized responses
* backend/server errors

Do not swallow exceptions.

Do not mark a request successful merely because no Dart exception was thrown.

---

## Mutation Refresh Rule

After successful:

* create
* update
* delete
* cancel
* reverse
* adjustment
* payment

refresh all relevant list/detail state so the UI reflects backend state immediately.

---

## Module Completion Rule

Never report:

> Fully implemented

based only on compilation or static analysis.

A module can be reported as complete only after:

1. Required screens are implemented.
2. Required endpoints are verified.
3. Requests reach the expected backend endpoints.
4. Request payloads are correct.
5. Responses parse correctly.
6. Main user workflow works at runtime.
7. Errors are handled.
8. Relevant lists refresh after changes.
9. No known runtime API issue remains.
10. `flutter analyze` passes.

If runtime behavior was not tested, clearly state:

> Implementation complete; runtime verification still required.

Do not claim runtime success without evidence.

---

## Working Module-by-Module

Work only on the requested module/submodule.

Do not begin the next module automatically when instructed to stop for review.

When a module is completed, provide:

```text
Module:
Files changed:
Endpoints used:
Main functionality implemented:
flutter analyze:
Runtime verification:
Known issues:
Ready for next module: Yes/No
```

If a module is intentionally skipped because of a known issue, preserve that issue for later instead of silently marking it complete.

---

## Debugging Existing Modules

When the user says a module "does not work":

Do not immediately rewrite the UI.

Debug in this order:

1. Verify base URL.
2. Verify endpoint.
3. Verify HTTP method.
4. Verify authorization header.
5. Verify path/query parameters.
6. Verify request payload.
7. Inspect raw response/status code.
8. Verify response parsing.
9. Verify repository mapping.
10. Verify controller state.
11. Finally inspect UI rendering.

Prioritize finding the actual failure rather than making unrelated refactors.

---

## Code Change Discipline

When fixing one module:

* Keep changes scoped.
* Avoid unrelated refactoring.
* Preserve existing working functionality.
* Do not rename public project APIs unnecessarily.
* Do not restructure the entire project unless explicitly requested.

Prefer the smallest correct fix.

---

## Verification

After code changes:

Run:

```bash
flutter analyze
```

Also run relevant tests if they exist.

Resolve errors introduced by the change before reporting completion.

Warnings unrelated to the modified module should be reported separately rather than hidden.

---

## Current Project Principle

`design.md` tells you WHAT and HOW to build.

`pos-erp-api-curl-guide.md` tells you WHICH backend API to call.

The existing Next.js/backend implementation is the fallback source for exact payload and response schemas when the API guide is incomplete.

Never guess backend behavior.
