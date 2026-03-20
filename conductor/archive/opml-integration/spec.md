# Track Specification: OPML Import/Export

## Goal
Implement robust, standards-based OPML 2.0 import and export functionality.

## Requirements
- OPML Export: Generate valid OPML 2.0 XML of user's feeds, grouped by category.
- OPML Import: Parse XML file upload, extracting URLs and folder structures.
- Data Ingestion: Async ingestion of new feeds using background jobs.
- Category Support: Update schema to store category/folder names.
