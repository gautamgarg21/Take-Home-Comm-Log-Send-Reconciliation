# Comm-Log Send Reconciliation

## Reconciliation Bridge
| Step | Description | Result | Reason |
| :--- | :--- | :--- | :--- |
| 0 | Naive count | 30 | Unfiltered total rows in communication_log |
| 1 | Filter unapproved campaigns | 26 | Excluded logs linked to campaigns with creation_status = 'approval_awaiting' |
| 2 | Retry chain customer deduplication | 22 | Grouped retry chains to count distinct customers reached |

## Running the Query
sqlite3 data/comm_log.db < sql/solution.sql
