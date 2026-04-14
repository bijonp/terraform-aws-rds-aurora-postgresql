# RDS PostgreSQL Major Version Upgrade

### RDS / Aurora PostgreSQL Major Version Upgrade
This document provides a clear, step-by-step checklist for performing a major version upgrade on AWS RDS PostgreSQL and Aurora PostgreSQL in production environments.

### Pre-Upgrade Checks
•	Verify that AWS supports upgrading from the current PostgreSQL version to the target version using AWS-supported paths only.
•	Create new parameter groups for the target major version (do not reuse older parameter groups).
•	For RDS PostgreSQL: Create a new DB Parameter Group (postgresXX).
•	For Aurora PostgreSQL: Create a new Cluster Parameter Group and Instance Parameter Group (aurora-postgresqlXX).
•	Confirm that the DB instance class is supported for the target PostgreSQL version.
•	Ensure no prepared transactions exist (SELECT count(*) FROM pg_prepared_xacts; result must be 0).
•	Verify no unsupported reg* data types are used (regproc, regprocedure, regoperator, etc.).
•	Check for invalid databases and drop unused or invalid ones.
•	For Aurora: Ensure no logical replication slots exist before upgrade.
•	Verify all extensions are supported and upgraded to the latest compatible versions.
•	Check for unknown or unsupported data types and resolve them.

### Backup Requirement

A manual snapshot must be taken before starting the upgrade:
•	RDS PostgreSQL – Take a DB snapshot
•	Aurora PostgreSQL – Take a cluster snapshot
Recommended snapshot name: pre-major-upgrade-<db-name>-<date>

### Upgrade Execution Options
•	In-place Upgrade – Requires downtime, simple execution, no instant rollback.
•	Blue-Green Deployment – Recommended for production, minimal downtime, allows rollback.

### Post-Upgrade Validation
•	Verify PostgreSQL engine version after upgrade.
•	Confirm new parameter groups are attached.
•	Validate installed extensions.
•	Monitor CPU, memory, connections, and replication metrics.
•	Perform application read/write and batch job validation.

### Rollback Strategy
If issues occur after upgrade:
1.	Stop application traffic.
2.	Restore the pre-upgrade snapshot.
3.	Reattach old parameter groups.
4.	Resume application traffic.

### Important Notes
•	Major version upgrades are irreversible.
•	Always test the upgrade process in lower environments first.
•	Parameter group mismatch is the most common cause of failure.
•	Prepared transactions and logical replication slots are hard blockers.
