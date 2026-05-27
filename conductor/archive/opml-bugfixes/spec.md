# Track Specification: OPML Bugfixes

## Goal
Fix bugs identified in OPML import/export functionality, specifically related to idempotency and empty feed creation.

## Requirements
- Fix `ImportFeedsJob` to correctly handle symbol/string keys.
- Add validations to the `Feed` model to prevent empty feeds.
- Ensure duplicate URIs for the same user are rejected during import.
