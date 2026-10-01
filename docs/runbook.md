# Runbook

Operational responses for each alert type. Each answers: "I got this alert — what now?"

## 🚨 Backup OVERDUE — no successful backup in 26h

**What it means:** The watchdog (runs hourly) found no `ok` backup report for this
target in the last 26 hours. Either backups are failing silently, or backup.sh
isn't running at all (cron removed, VM rebooted, disk full).

**First checks:**
1. Is there also a recent `Backup FAILED` for this target? If so, start there —
   the job ran but pg_dump failed.
2. If not, the job probably never ran. On the host:
   `crontab -l` (is the job scheduled?) and `grep backup /var/log/syslog | tail`
   (did cron start it?).
3. Is the disk full? `df -h /`

**Fix:** Run backup.sh by hand and confirm a `Backup ok` row appears in the queue.

**Acknowledge:** Once a successful backup is recorded. If you acknowledge before
it's fixed, the watchdog will re-alert within the hour — by design.

> Note: backup.sh is not yet deployed (see README → Status). Until then, both real
> databases will correctly show as overdue, and the host commands above apply once
> the backup job is running on the VM.

## 🚨 Health check FAILED — <target>

**What it means:** A scheduled health check (every 5 min) hit this site and it
either answered with a non-2xx code, took longer than 3s, or didn't answer at all
(DNS failure, connection refused, timeout). The alert fires only on the
*transition* into failure, not every 5 minutes.

**First checks:**
1. Read the alert's message line — it tells you which kind of failure:
   `HTTP 5xx` (site answered with an error), `slow: Nms` (up but too slow), or a
   connection error like `ENOTFOUND` / `ECONNREFUSED` (no answer at all).
2. Reproduce from your own machine: `curl -sI <target>` — does it match what the
   check saw? Check the status code and the `server:` header.
3. If it's a connection error, is it DNS (`ENOTFOUND`) or the service being down
   (`ECONNREFUSED`)? On the host, check whether the service is listening on its
   port and whether the reverse proxy (Caddy) is forwarding correctly.
4. If a target sits behind Cloudflare Access, confirm the check isn't just hitting
   the login page — an auth redirect can read as a misleading "ok". (This is why
   the Access-protected sites were replaced with a directly reachable target.)

**Fix:** Restart the service / fix the proxy config / resolve the DNS issue,
depending on what the checks above revealed.

**Acknowledge:** After confirming the site is back (wait for the ✅ Recovered
alert, or re-run the health-check workflow by hand and see an `ok` row).

## ✅ Health check RECOVERED — <target>

**What it means:** A site that was previously failing answered successfully again.
This is informational, not an emergency — it tells whoever was paged that the
problem has cleared.

**First checks:**
1. Confirm it's genuinely stable, not flapping. Look at the Health overview page:
   is uptime climbing and response time back to normal, or is it bouncing between
   ok and fail?
2. If it's flapping, treat it like an active failure — the recovery is temporary.

**Fix:** None required if stable. If flapping, investigate the underlying
instability (overloaded service, intermittent network).

**Acknowledge:** No action needed — recovery alerts are informational. Acknowledge
the original failure row in the queue if it's still open.

## 🚨 Backup FAILED — <target>

**What it means:** backup.sh ran and sent a report, but pg_dump failed. Unlike
"Backup OVERDUE," the job *did* run — something went wrong during the dump itself
(database unreachable, auth failure, disk full mid-dump). The alert's message line
carries the pg_dump error text.

**First checks:**
1. Read the alert's message — the pg_dump error usually names the cause directly
   (e.g. `connection to server failed`, `permission denied`, `no space left`).
2. Can the backup host reach the database? Test the connection string pg_dump uses.
3. Is the disk full on the host writing the dump? `df -h /`
4. Check the full report in the queue's detail panel — `details` holds the whole
   payload, including duration and size, which can hint at where it broke.

**Fix:** Resolve the specific error (restore connectivity, free disk, fix
credentials), then run backup.sh by hand and confirm an `ok` row is recorded.

**Acknowledge:** Once a successful backup is recorded. Acknowledging a failed
backup without fixing it leaves you exposed — and the watchdog will re-alert as
overdue within 26 hours anyway.

## If the monitoring itself is down

**The gap:** All alerting depends on n8n. If n8n stops (crashed, container down,
host rebooted), nothing fires — no health alerts, no watchdog, no backup alerts.
The watchdog can't warn you it isn't running, because it's the thing that isn't
running.

**How would anyone find out today?** Honestly, they wouldn't — not until someone
noticed the absence of expected alerts, or a real incident went unreported. This
is a real blind spot.

**What would fix it:** An external dead-man's-switch — a service outside this
system that n8n pings on a schedule, and that alerts you when the pings stop. The
watchdog protects backups this way; the monitor itself needs the same protection
from something it doesn't control. See healthchecks.io for this pattern. Listed
under "what I'd add next" in the README.
