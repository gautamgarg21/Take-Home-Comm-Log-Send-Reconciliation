# Xeno Data Analyst Take-Home Assignment: Comm-Log Send Reconciliation

## Overview & Objective
Finance tracks a metric called **target_base**, representing the total number of qualifying sends for a merchant's campaigns. For **Merchant 501** in **October 2026** across all Diwali campaigns, Finance reported a true target base of **22**.

The objective of this assessment is to reproduce the count of 22 from raw database logs (`data/comm_log.db`) and document the analytical investigation explaining the gap between a naive SQL count (30) and the final verified metric.

## Key Business Rules & Discoveries
Through exploratory querying of `campaign` and `communication_log`, two core business logic adjustments were identified:

1. **Campaign Approval Status Filtering:** A campaign is included in official reporting only if its creation workflow has cleared (`creation_status != 'approval_awaiting'`) and its send pipeline has finished (`processing_status = 'processed'`). Logs associated with unapproved campaigns are filtered out.
2. **Retry Chain Deduplication:** Campaigns created as retries point to an original campaign via `parent_id`. A campaign and its full retry tree (e.g., A -> B -> C) represent a single underlying communication. Finance counts the number of **distinct customers reached** across the entire chain. Conversely, standalone campaigns (no retry lineage) count every valid send attempt independently.

## Reconciliation Bridge

| Step | Description | Result | Reason |
| :--- | :--- | :--- | :--- |
| **0** | Naive count | **30** | Unfiltered total rows in `communication_log`. |
| **1** | Filter unapproved campaigns | **26** | Excluded 4 logs linked to campaigns with `creation_status = 'approval_awaiting'`. |
| **2** | Retry chain deduplication | **22** | Deduplicated repeat customer sends within retry chains to root campaign level, while preserving independent multi-sends for standalone campaigns. |

## Technical Approach & SQL Logic
The reconciliation is achieved using a recursive Common Table Expression (CTE) in `sql/solution.sql`:
* **`campaign_tree` CTE:** Recursively maps every retry campaign back to its parent root campaign ID.
* **`chain_counts` CTE:** Measures the size of each campaign lineage to differentiate multi-level retry chains from standalone campaigns.
* **`valid_logs` CTE:** Filters out `approval_awaiting` records and joins send attempts with root campaign metadata.
* **Final Selection:** Sums distinct customer IDs for retry chains (`chain_size > 1`) and individual log events for standalone campaigns (`chain_size = 1`).

## Repository Structure
```text
Take-Home-Comm-Log-Send-Reconciliation/
├── .gitignore
├── README.md
├── data/
│   ├── campaign.csv
│   ├── comm_log.db
│   ├── communication_log.csv
│   └── generate_dataset.py
└── sql/
    └── solution.sql
```

## How to Run
To execute the reconciliation query against the SQLite database, run:
```bash
sqlite3 data/comm_log.db < sql/solution.sql
```
