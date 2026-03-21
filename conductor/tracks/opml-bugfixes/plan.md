# Implementation Plan: OPML Bugfixes

## Phase 1: Model Hardening
- [x] **Task 1: Add Validations to Feed Model**
  - Add `validates_presence_of :uri, :name, :user`.
  - Updated to allow manual duplicates (removed uniqueness constraint).
  - Update tests.

## Phase 2: Job Fixing
- [x] **Task 2: Fix ImportFeedsJob**
  - Ensure keys are accessed consistently (use symbols or `.with_indifferent_access`).
  - Improved idempotency check to include `uri`, `name`, and `category`.
  - Add regression test for symbol key input.

## Phase 3: Verification
- [x] **Task 3: Idempotency Request Spec**
  - Create a spec that imports the same file twice and ensures no duplicates or empty feeds.

