# RDS PostgreSQL Major Version Upgrade

RDS / Aurora PostgreSQL Major Version Upgrade – Simple Checklist
Purpose
This document lists mandatory checks and steps for performing a major version upgrade on AWS RDS PostgreSQL and Aurora PostgreSQL in production environments.



Pre‑Upgrade Checks (Mandatory)


Supported upgrade path
Verify that AWS supports upgrading from the current PostgreSQL version to the target version.
Only AWS-supported upgrade paths are allowed.


Command (example):
aws rds describe-db-engine-versions --engine postgres --engine-version <current_version>


Parameter group compatibility
Create new parameter groups before upgrade.

For RDS PostgreSQL

Create a new DB Parameter Group for the target major version (postgresXX)

For Aurora PostgreSQL

Create a new Cluster Parameter Group (aurora-postgresqlXX)
Create a new Instance Parameter Group (aurora-postgresqlXX)

Never reuse parameter groups from an older major version.


Instance class compatibility
Confirm that the existing DB instance class is supported for the target PostgreSQL version.

If the instance class is not supported, upgrade or change the instance class before upgrading PostgreSQL.


Prepared transactions (Critical blocker)
Major upgrades will fail if prepared transactions exist.

Check:
SELECT count(*) FROM pg_catalog.pg_prepared_xacts;
Result must be 0.
If not zero, identify them:
SELECT gid, database, owner, prepared FROM pg_prepared_xacts;
Resolution:

Commit prepared transaction if valid
Roll back prepared transaction if stale

Always coordinate with the application team before committing or rolling back.


Unsupported reg* data types
Major PostgreSQL upgrades do not support regproc, regprocedure, regoper, regoperator, regconfig, regdictionary.

Check each database for usage.
If found:

Convert column to text
Or drop column if unused

Recheck after fixes.


Invalid databases
Check for invalid databases:

SELECT datname FROM pg_database WHERE datconnlimit = -2;
Drop unused or invalid databases before upgrade.


Logical replication slots (Aurora only)
Aurora PostgreSQL cannot upgrade if logical replication slots exist.

Check:
SELECT * FROM pg_replication_slots WHERE slot_type != 'physical';
Drop unused logical slots before upgrade.


Extensions compatibility
List installed extensions:

SELECT * FROM pg_extension;
Upgrade extensions to latest supported versions.
Drop extensions that are not supported in the target major version.


Unknown or unsupported data types
Check for unknown data types:

SELECT DISTINCT data_type FROM information_schema.columns WHERE data_type ILIKE 'unknown';
Fix or remove affected columns before upgrade.



Backup Strategy (Mandatory)


Take a manual snapshot before upgrade.


For RDS PostgreSQL

Take a DB snapshot

For Aurora PostgreSQL

Take a cluster snapshot

Recommended snapshot name format:
pre-major-upgrade--


Upgrade Execution Options

Option 1: In-place upgrade

Requires downtime
Simple execution
No instant rollback

Option 2: Blue/Green deployment (Recommended)

Minimal or zero downtime
Allows testing before cutover
Instant rollback possible




Post‑Upgrade Validation


Verify PostgreSQL version
SHOW server_version;


Verify parameter groups
Ensure new parameter groups are attached.


Validate extensions
SELECT * FROM pg_extension;


Monitor performance



CPU utilization
Freeable memory
DB connections
Replication lag
Performance Insights metrics


Application testing


Read/write operations
Batch jobs
Reports
CDC or replication (if used)



Rollback Strategy

If issues occur after upgrade:

Stop application traffic
Restore pre-upgrade snapshot
Reattach old parameter groups
Resume application traffic


Key Notes

Major version upgrades are irreversible
Always test in lower environments first
Parameter group mismatch is the most common failure reason
Prepared transactions and logical replication slots are hard blockers
