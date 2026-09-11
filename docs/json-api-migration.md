# SOAP to JSON API Migration Tracker

## Purpose

This document tracks the migration from the SOAP/WSDL API to the REST/JSON API in this repository. Update the status and validation notes whenever a JSON operation is added, changed, or verified against Microsoft Advertising.

The tracker describes **repository coverage**, not the complete Microsoft Advertising API. SOAP exposes all operations declared by the local WSDL through the generic `Services::Base#call` method, while JSON currently exposes selected Campaign Management helpers plus generic `post`, `put`, and `delete` methods.

## Status definitions

- **Migrated**: A dedicated JSON helper exists, has focused unit coverage, and has been verified against the REST contract.
- **Partial**: A related JSON operation exists, but the SOAP behavior is not equivalent or the JSON path still requires a generic method.
- **Pending**: No JSON helper or registered JSON service exists.
- **Blocked**: Migration depends on an API contract, account capability, or Microsoft behavior that must be resolved first.

## Current transport entry points

| Transport | Client | Service registration | Request model |
| --- | --- | --- | --- |
| SOAP | `BingAdsRubySdk::Api` | Six WSDL-backed services | `call` with WSDL ordering and XML |
| REST/JSON | `BingAdsRubySdk::JsonApi` | Campaign Management only | `post`, `put`, and `delete` with JSON |

JSON payload keys are supplied in snake_case and recursively camelized before serialization. JSON responses are symbolized while retaining Microsoft response key casing. JSON error arrays are raised as `Services::Json::ApiError`.

## Campaign Management

### Campaign lifecycle

| SOAP operation | REST operation | JSON helper | Status | Notes |
| --- | --- | --- | --- | --- |
| `GetCampaignsByAccountId` | `POST /Campaigns/QueryByAccountId` | `get_campaigns_by_account_id(payload)` | Migrated | Dedicated helper and live read validation are complete. |
| `AddCampaigns` | `POST /Campaigns` | `add_campaigns(payload)` | Migrated | Supports up to 100 campaign objects per request. |
| `UpdateCampaigns` | `PUT /Campaigns` | `update_campaigns(payload)` | Migrated | Supports up to 100 campaign objects per request. |
| `DeleteCampaigns` | `DELETE /Campaigns` | `delete_campaigns(payload)` | Migrated | Used to clean up live test campaigns. |
| `GetCampaignsByIds` | `POST /Campaigns/QueryByIds` | `get_campaigns_by_ids(payload)` | Migrated | Dedicated helper is covered by unit tests; live validation requires a known campaign ID. |

### Shared entities and associations

| SOAP operation | JSON coverage | Status | Remaining work |
| --- | --- | --- | --- |
| `AddSharedEntity` | `add_shared_entity(payload)` using `POST /SharedEntity` | Migrated | Supports negative keyword lists and website exclusion lists; response may include per-item `PartialErrors`. |
| `GetSharedEntities` | `get_shared_entities(payload)` using `POST /SharedEntities/Query` | Migrated | Supports shared entity type and scope for account or customer libraries. |
| `GetSharedEntitiesByAccountId` | `get_shared_entities_by_account_id(payload)` using `POST /SharedEntities/QueryByAccountId` | Migrated | SOAP-compatible account-scoped route; Microsoft marks this operation deprecated in favor of `GetSharedEntities`. |
| `SetSharedEntityAssociations` | `set_shared_entity_associations(payload)` using `POST /SharedEntityAssociations/Set` | Migrated | Supports up to 10,000 associations per request; live mutation requires an approved test association. |
| `GetSharedEntityAssociationsByEntityIds` | `get_shared_entity_associations_by_entity_ids(payload)` using `POST /SharedEntityAssociations/QueryByEntityIds` | Migrated | Read-only live validation can use account or campaign entity IDs. |
| `GetListItemsBySharedList` | `get_list_items_by_shared_list(payload)` using `POST /ListItems/QueryBySharedList` | Migrated | Requires a shared list ID and returns an empty list when no items exist. |
| `AddListItemsToSharedList` | `add_list_items_to_shared_list(payload)` using `POST /ListItems` | Migrated | Supports per-item `PartialErrors`; list ownership and scope permissions apply. |
| `DeleteListItemsFromSharedList` | `delete_list_items_from_shared_list(payload)` using `DELETE /ListItems` | Migrated | Supports per-item `PartialErrors`; list ownership and scope permissions apply. |

### Ad extensions

| SOAP operation | JSON helper | Status |
| --- | --- | --- |
| `AddAdExtensions` | `add_ad_extensions(payload)` using `POST /AdExtensions` | Migrated |
| `GetAdExtensionIdsByAccountId` | `get_ad_extension_ids_by_account_id(payload)` using `POST /AdExtensionIds/QueryByAccountId` | Migrated |
| `GetAdExtensionsByIds` | `get_ad_extensions_by_ids(payload)` using `POST /AdExtensions/QueryByIds` | Migrated |
| `GetAdExtensionsAssociations` | `get_ad_extensions_associations(payload)` using `POST /AdExtensionsAssociations/Query` | Migrated |
| `SetAdExtensionsAssociations` | `set_ad_extensions_associations(payload)` using `POST /AdExtensionsAssociations/Set` | Migrated |
| `DeleteAdExtensionsAssociations` | `delete_ad_extensions_associations(payload)` using `DELETE /AdExtensionsAssociations` | Migrated |
| `DeleteAdExtensions` | `delete_ad_extensions(payload)` using `DELETE /AdExtensions` | Migrated | Cleanup helper for live Ad Extension tests. |

### Conversion goals

| SOAP operation | JSON helper | Status |
| --- | --- | --- |
| `AddConversionGoals` | `add_conversion_goals(payload)` using `POST /ConversionGoals` | Migrated |
| `GetConversionGoalsByIds` | `get_conversion_goals_by_ids(payload)` using `POST /ConversionGoals/QueryByIds` | Migrated |
| `UpdateConversionGoals` | `update_conversion_goals(payload)` using `PUT /ConversionGoals` | Migrated |

Microsoft does not expose a `DeleteConversionGoals` operation. Live tests must use existing goals for read/update validation or obtain an explicit approval to leave a controlled inactive test goal in the account. Although Microsoft documents an empty `ConversionGoalIds` array as an all-goals query, the live REST endpoint rejects an explicitly empty array with error 206; omit the field instead.

### UET tags

| SOAP operation | JSON helper | Status |
| --- | --- | --- |
| `AddUetTags` | `add_uet_tags(payload)` using `POST /UetTags` | Migrated |
| `GetUetTagsByIds` | `get_uet_tags_by_ids(payload)` using `POST /UetTags/QueryByIds` | Migrated |
| `UpdateUetTags` | `update_uet_tags(payload)` using `PUT /UetTags` | Migrated |

### Campaign hierarchy and targeting

| SOAP operation | JSON helper | Status |
| --- | --- | --- |
| `GetAdGroupsByIds` | `get_ad_groups_by_ids(payload)` using `POST /AdGroups/QueryByIds` | Migrated |
| `GetAdGroupsByCampaignId` | `get_ad_groups_by_campaign_id(payload)` using `POST /AdGroups/QueryByCampaignId` | Migrated |
| `AddAds` | `add_responsive_search_ads(...)` using `POST /Ads` | Migrated | Builds the typed `ResponsiveSearch` JSON shape observed on the account; live creation uses the same type discriminator as existing REST responses. |
| `GetAdsByAdGroupId` | `get_ads_by_ad_group_id(payload)` using `POST /Ads/QueryByAdGroupId` | Migrated |
| `GetBudgetsByIds` | `get_budgets_by_ids(payload)` using `POST /Budgets/QueryByIds` | Migrated |
| `GetCampaignCriterionsByIds` | `get_campaign_criterions_by_ids(payload)` using `POST /CampaignCriterions/QueryByIds` | Migrated |
| `AddCampaignCriterions` | `add_campaign_criterions(payload)` using `POST /CampaignCriterions` | Migrated |
| `DeleteCampaignCriterions` | `delete_campaign_criterions(payload)` using `DELETE /CampaignCriterions` | Migrated |
| `GetKeywordsByAdGroupId` | `get_keywords_by_ad_group_id(payload)` using `POST /Keywords/QueryByAdGroupId` | Migrated |
| `GetKeywordsByEditorialStatus` | `get_keywords_by_editorial_status(payload)` using `POST /Keywords/QueryByEditorialStatus` | Migrated |
| `GetKeywordsByIds` | `get_keywords_by_ids(payload)` using `POST /Keywords/QueryByIds` | Migrated |

## Other SOAP services

These services are registered in `BingAdsRubySdk::Api` but have no JSON service registration in `BingAdsRubySdk::JsonApi`.

### Bulk

| SOAP operation | JSON status | Priority | Notes |
| --- | --- | --- | --- |
| `DownloadCampaignsByAccountIds` | `bulk.download_campaigns_by_account_ids(payload)` using `POST /Campaigns/DownloadByAccountIds` | Migrated | Bulk workflows are operationally important and have different payload/file behavior. |
| `GetBulkDownloadStatus` | `bulk.get_bulk_download_status(payload)` using `POST /BulkDownloadStatus/Query` | Migrated | Requires polling behavior and response contract. |
| `GetBulkUploadUrl` | `bulk.get_bulk_upload_url(payload)` using `POST /BulkUploadUrl/Query` | Migrated | Returns a short-lived upload request ID and URL. |
| `GetBulkUploadStatus` | `bulk.get_bulk_upload_status(payload)` using `POST /BulkUploadStatus/Query` | Migrated | Requires polling behavior and response contract. |
| Bulk file upload | `bulk.upload_file(upload_url:, content:, filename:)` | Migrated | Sends the builder output as multipart/form-data. |
| Bulk result download and parsing | `bulk.download_file(url:)` plus `BulkFileReader#to_csv` | Migrated | Handles plain CSV, GZIP, and ZIP result content. |

### Customer Management

| SOAP operation | JSON status | Priority | Notes |
| --- | --- | --- | --- |
| `GetAccount` | `customer_management.get_account(payload)` using `POST /Account/Query` | Migrated | Needed for account metadata and migration discovery. |
| `FindAccounts` | `customer_management.find_accounts(payload)` using `POST /Accounts/Find` | Migrated | Covered by live VCR integration using the configured customer. |
| `GetCustomer` | `customer_management.get_customer(payload)` using `POST /Customer/Query` | Migrated | Covered by live VCR integration. |
| `GetCustomersInfo` | `customer_management.get_customers_info(payload)` using `POST /CustomersInfo/Query` | Migrated | Covered by live VCR integration. |
| `UpdateAccount` | `customer_management.update_account(payload)` using `PUT /Account` | Migrated | Full timestamped account overwrite; live mutation requires explicit approval. |
| `UpdateCustomer` | `customer_management.update_customer(payload)` using `PUT /Customer` | Migrated | Full timestamped customer overwrite; requires customer-level update permissions. |
| `FindAccountsOrCustomersInfo` | `customer_management.find_accounts_or_customers_info(payload)` using `POST /AccountsOrCustomersInfo/Find` | Migrated | Useful for discovering customer/account identifiers. |
| `SignupCustomer` | `customer_management.signup_customer(payload)` using `POST /Customer/Signup` | Migrated | First live signup succeeded and is recorded in `customer_signup_creates_one_customer_and_account.yml`; Microsoft exposes no delete operation, so the created controlled customer/account is retained. |

### Reporting

The JSON Reporting service exposes the common asynchronous workflow:

1. `SubmitGenerateReport`
2. `PollGenerateReport`
3. Download the returned report URL

| SOAP operation | JSON status | Priority | Notes |
| --- | --- | --- | --- |
| `SubmitGenerateReport` | `reporting.submit_generate_report(payload)` using `POST /GenerateReport/Submit` | Migrated | Accepts a nested `report_request` payload and returns the report request ID. |
| `PollGenerateReport` | `reporting.poll_generate_report(payload)` using `POST /GenerateReport/Poll` | Migrated | Call repeatedly until the returned status is `Success` or an error state. |
| Report download | `reporting.download_file(url:)` | Migrated | Uses the raw HTTP client for the short-lived URL returned by polling. |

Migration status: **Migrated with conditional download**. Report files are ZIP-compressed by Microsoft and can be parsed with `BulkFileReader` when a download URL is returned. Microsoft documents that `ReportDownloadUrl` may be nil even when `Status` is `Success` if no data is available for the submitted parameters.

### Ad Insight

The v13 API does not expose a dedicated REST/JSON Ad Insight service. The SDK's existing Ad Insight implementation is SOAP-only, so migration status: **Blocked by API availability**. Keep this area on the SOAP transport unless Microsoft publishes a REST equivalent.

### Customer Billing

The JSON Customer Billing service is registered at `CustomerBilling/v13/` and provides the documented query and insertion-order operations. Migration status: **Migrated**. Microsoft documents sandbox billing limitations, and insertion-order mutations require explicit billing permissions.

| REST operation | JSON helper | HTTP route |
| --- | --- | --- |
| `GetBillingDocumentsInfo` | `customer_billing.get_billing_documents_info(payload)` | `POST /BillingDocumentsInfo/Query` |
| `GetBillingDocuments` | `customer_billing.get_billing_documents(payload)` | `POST /BillingDocuments/Query` |
| `AddInsertionOrder` | `customer_billing.add_insertion_order(payload)` | `POST /InsertionOrder` |
| `UpdateInsertionOrder` | `customer_billing.update_insertion_order(payload)` | `PUT /InsertionOrder` |
| `SearchInsertionOrders` | `customer_billing.search_insertion_orders(payload)` | `POST /InsertionOrders/Search` |
| `GetAccountMonthlySpend` | `customer_billing.get_account_monthly_spend(payload)` | `POST /AccountMonthlySpend/Query` |

## Recommended migration order

1. **Campaign reads and writes**: finish dedicated campaign query and verify the existing CRUD helpers with fixture and live read/write/cleanup checks.
2. **Campaign hierarchy**: migrate ad groups, ads, budgets, keywords, and criteria because these form the core campaign workflow.
3. **Conversion goals and UET tags**: migrate tracking entities used by campaign automation.
4. **Ad extensions and shared entity associations**: migrate association-heavy operations with explicit partial-error coverage.
5. **Customer Management**: migrate account discovery before higher-level onboarding tools.
6. **Bulk**: migrate upload/download workflows with file-size, polling, and retry tests.
7. **Reporting**: design and test asynchronous submit/poll/download behavior.
8. **Ad Insight and Customer Billing**: migrate only after confirming endpoint availability and business need.

## Per-operation migration checklist

For each pending operation:

- [ ] Confirm the Microsoft REST endpoint, HTTP verb, request JSON, response JSON, and supported environments.
- [ ] Decide whether a dedicated helper adds value over the generic JSON escape hatch.
- [ ] Add a focused RSpec example for method routing and payload camelization.
- [ ] Add response and API error coverage, including partial errors where applicable.
- [ ] Add or update the JSON service registration if this is a new service.
- [ ] Document the helper and any operation-specific constraints.
- [ ] Run `bundle exec standardrb`.
- [ ] Run the focused unit specs and then `bundle exec rspec`.
- [ ] Load `.env` into the current shell before any live API call:

```shell
set -a
. ./.env
set +a
```

- [ ] Run a real call against the approved test account when credentials are available.
- [ ] Delete entities created by the live test using the corresponding cleanup operation.
- [ ] Record the live validation result without committing credentials, tokens, or request logs.

For campaign cleanup, verify deletion through `get_campaigns_by_account_id`. Microsoft may return a partial error when querying deleted campaign IDs directly because their deleted status is invalid for that operation.

## Current validation record

| Date | Area | Validation | Result |
| --- | --- | --- | --- |
| 2026-09-03 | Campaign Management REST | Created, updated, queried, and deleted a paused test campaign using the JSON client | Passed; cleanup confirmed |
| 2026-09-03 | Campaign Management REST | Queried campaigns with `POST /Campaigns/QueryByAccountId` | Passed; empty campaign list returned before live creation |
| 2026-09-03 | Campaign Management REST | Queried campaigns with `get_campaigns_by_account_id` and attempted the ID-specific read | Account query passed with zero campaigns; ID-specific call skipped because no campaign ID was available |
| 2026-09-03 | Shared Entity Associations REST | Queried `get_shared_entity_associations_by_entity_ids` for the configured account | Passed; zero associations and zero partial errors returned |
| 2026-09-03 | Shared Entity REST | Added the SOAP-compatible `get_shared_entities_by_account_id` helper and verified all shared entity/list-item routes against Microsoft REST documentation | Both `QueryByAccountId` and `Query` live reads succeeded with zero lists; mutation validation remains subject to shared-list ownership and cleanup constraints |
| 2026-09-03 | Ad Extensions REST | Created, read, and deleted a short Callout Ad Extension using the new JSON helpers | Passed; extension `7559423504252` cleaned up; an earlier long-text attempt correctly returned `ValueTooLong` |
| 2026-09-03 | Conversion Goals REST | Queried Event goals with `get_conversion_goals_by_ids` | Passed when `conversion_goal_ids` was omitted; zero goals returned; no write performed |
| 2026-09-03 | Conversion Goals REST | Created a uniquely named paused Event goal, then read it by ID and UET tag ID | Passed; UET tag `211077200` and conversion goal `172211608` intentionally left in the production test account because no delete operation is available |
| 2026-09-03 | UET Tags REST | Read and updated UET tag `211077200` using the new JSON helpers | Passed; update returned zero partial errors and the description was verified |
| 2026-09-03 | Campaign Hierarchy REST | Queried campaigns and shared budgets using the new JSON helpers | Passed; zero campaigns and zero budgets returned; deeper reads skipped because no hierarchy IDs were available |
| 2026-09-03 | Customer Management REST | Retrieved account details and searched accounts/customers using the new JSON service | Passed; account was Active and five records were returned; no mutating call performed |
| 2026-09-03 | Customer Management REST | Sent the fetched account back through `update_account` unchanged, then retried with recursively snakeized keys | Initial direct response hash returned API error 509 because `TimeStamp` became `Timestamp`; snake_case retry passed and account remained Active |
| 2026-09-03 | JSON integration cassettes | Added meaningful Budget CRUD plus UET tag and conversion goal create/read/update workflows | Live recordings succeeded; disposable budgets were deleted, while UET and conversion goal resources were intentionally retained because no delete operation is available |
| 2026-09-03 | Shared Entities REST | Created an account-scoped negative keyword list, added/read/deleted a list item, read the list, and deleted the list | Passed live with all resources cleaned up |
| 2026-09-03 | Ad Extensions REST | Created, read, listed, associated, queried, disassociated, and deleted a Callout extension | Passed live with the disposable campaign and extension cleaned up |
| 2026-09-03 | UET Tags REST | Created a uniquely named UET tag and recorded the returned tag data | Passed live; the tag is intentionally retained because Microsoft provides no UET tag delete operation |
| 2026-09-03 | Customer Management REST | Attempted `signup_customer` for `Ai created` with France/French/EUR/Paris settings | Initial payload returned error 506 (`The request message is null`) twice; later corrected REST payload succeeded once and is recorded in `customer_signup_creates_one_customer_and_account.yml` |
| 2026-09-03 | Bulk REST | Requested an upload URL and polled its status using the new JSON Bulk service | Passed; request entered `PendingFileUpload` at 0%; no file uploaded |
| 2026-09-03 | Bulk REST | Submitted an account campaign download, polled to completion, and downloaded the result archive | Passed; completed at 100% and downloaded a 3,555-byte archive |
| 2026-09-03 | Bulk REST | Built and uploaded a one-row paused campaign, polled to `Completed`, then removed it with REST cleanup | Passed; upload reached 100%, campaign was found through an account query, and cleanup returned zero partial errors |
| 2026-09-03 | Bulk REST | Uploaded a one-row paused campaign, downloaded the compressed result, parsed its CSV content, extracted the campaign ID, and cleaned it up | Passed; `BulkFileReader` parsed 2 result rows and account-level cleanup was confirmed |
| 2026-09-03 | Reporting REST | Submitted and polled an Account Performance report for the previous day using `Daily` aggregation | Submit and poll reached `Success`; the test account returned no usable `ReportDownloadUrl`, so file download parsing remains deferred |
| 2026-09-03 | Customer Billing REST | Reached all six JSON routes against the production test account | Monthly spend succeeded with amount `0`; billing document metadata succeeded with zero records; insertion-order search succeeded with 24 records; document retrieval correctly rejected an empty list with error 312; add/update reached the API but returned authorization error 1001 without changing resources |
| 2026-09-03 | Unit suite | `bundle exec rspec` | Passed; 97 examples, 0 failures, 2 existing pending |

## References

- [Microsoft Advertising API overview](https://learn.microsoft.com/en-us/advertising/guides/?view=bingads-13)
- [Campaign Management API](https://learn.microsoft.com/en-us/advertising/campaign-management-service/?view=bingads-13)
- [AddCampaigns](https://learn.microsoft.com/en-us/advertising/campaign-management-service/addcampaigns?view=bingads-13)
- [UpdateCampaigns](https://learn.microsoft.com/en-us/advertising/campaign-management-service/updatecampaigns?view=bingads-13)
- [DeleteCampaigns](https://learn.microsoft.com/en-us/advertising/campaign-management-service/deletecampaigns?view=bingads-13)
- [Request and download a report](https://learn.microsoft.com/en-us/advertising/guides/request-download-report?view=bingads-13)
- [Account Performance Report Request](https://learn.microsoft.com/en-us/advertising/reporting-service/accountperformancereportrequest?view=bingads-13)
- [Microsoft Advertising sandbox](https://learn.microsoft.com/en-us/advertising/guides/sandbox?view=bingads-13)
