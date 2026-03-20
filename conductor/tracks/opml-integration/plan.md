# Implementation Plan: OPML Import/Export

## Phase 1: Database & Model Preparation
- [x] **Task 1: Add `category` to Feeds Table**
  - Create migration to add `category` string to `feeds`.
  - Update `Feed` model and permitted parameters.

## Phase 2: Backend Logic (Service Layer)
- [ ] **Task 2: OPML Export Service**
  - Implement `OpmlService.export(user_id)` using Nokogiri.
- [ ] **Task 3: OPML Import & Parsing**
  - Implement `OpmlService.import(xml_content, user_id)`.

## Phase 3: Asynchronous Data Ingestion
- [ ] **Task 4: Background Feed Ingestion Job**
  - Create `ImportFeedsJob` to process imported feeds.

## Phase 4: API Endpoints
- [ ] **Task 5: Export API Endpoint**
  - Add `GET /feeds/export` to `FeedsController`.
- [ ] **Task 6: Import API Endpoint**
  - Add `POST /feeds/import` to `FeedsController`.
