# queries

Readable copies of the SQL and JavaScript that run inside n8n and Retool.

| Folder | Where it comes from | Edit here? |
|---|---|---|
| `n8n/` | **Generated** from `workflows/*.json` by `scripts/extract-queries.sh` (also run at the end of `export-workflows.sh`). Named `<workflow>.<node>.sql` or `.js`. | No. Change the workflow in n8n and re-export. |
| `retool/` | **Hand-copied** from the Retool app. Each file's first line names its source query and the date it was copied. | Only to re-sync with Retool. |

The real versions run in n8n and Retool. These files exist so the queries can be
read and reviewed without opening either tool.
