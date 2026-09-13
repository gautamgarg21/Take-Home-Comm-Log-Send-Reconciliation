# Comm-Log Send Reconciliation

## Reconciliation Bridge

| Step | Description | Result | Reason |
| :--- | :--- | :--- | :--- |
| **0** | Naive count | **30** | Unfiltered total rows in `communication_log`[cite: 1]. |
| **1** | Filter unapproved campaigns | **26** | Excluded logs linked to campaigns with `creation_status = 'approval_awaiting'`. |
| **2** | Retry chain customer deduplication | **22** | Grouped retry chains (A -> B -> C) to count distinct customers reached per underlying communication, while preserving independent multi-sends for standalone campaigns. |

## Running the Query

To verify the reconciliation result, run:
sqlite3 data/comm_log.db < solution.sql
