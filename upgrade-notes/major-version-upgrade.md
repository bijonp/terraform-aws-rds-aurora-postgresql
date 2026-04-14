# RDS PostgreSQL Major Version Upgrade

RDS PostgreSQL Major Version Upgrade
This document describes mandatory checks and steps for performing a major version upgrade on AWS RDS PostgreSQL and Aurora PostgreSQL in production environments.

Pre‑Upgrade Checks
Check Supported Upgrade Path
Verify that AWS supports upgrading from the current PostgreSQL version to the target version.
Only AWS‑supported upgrade paths are allowed.
Example command:
aws rds describe-db-engine-versions --engine postgres --engine-version <current_version>

Check Parameter Group Compatibility
Create new parameter groups before starting the upgrade.
For RDS PostgreSQL
Create a new DB Parameter Group for the target major version (postgresXX).
For Aurora PostgreSQL
Create a new Cluster Parameter Group (aurora-postgresqlXX).
Create a new Instance Parameter Group (aurora-postgresqlXX).
Never reuse parameter groups from an older major version.

Check Instance Class Compatibility
Confirm that the current DB instance class is supported for the target PostgreSQL version.
If unsupported, change the instance class before upgrading the engine.

Check Prepared Transactions (Critical)
Major version upgrades will fail if prepared transactions exist.
Run:
SELECT count(*) FROM pg_catalog.pg_prepared_xacts;
The result must be 0.
If transactions exist, identify them:
SELECT gid, database, owner, prepared FROM pg_prepared_xacts;
Resolution:
Commit prepared transactions if valid.
Roll back prepared transactions if stale.
Always confirm with the application team before committing or rolling back.

Check Unsupported reg* Data Types
Major PostgreSQL upgrades do not support regproc, regprocedure, regoper, regoperator, regconfig, or regdictionary.
Check all databases for usage of these data types.
If found, convert columns to text or drop unused columns.
Re‑run the check after fixing.

Check Invalid Databases
Identify invalid databases using:
SELECT datname FROM pg_database WHERE datconnlimit = -2;
Drop invalid or unused databases before upgrading.

Check Logical Replication Slots (Aurora Only)
Aurora PostgreSQL upgrades cannot proceed if logical replication slots exist.
Check:
SELECT * FROM pg_replication_slots WHERE slot_type != 'physical';
Drop unused logical replication slots before upgrade.

Check Extensions
List installed extensions:
SELECT * FROM pg_extension;
Upgrade extensions to the latest supported versions.
Drop extensions that are not supported in the target major version.

Check Unknown or Unsupported Data Types
Run:
SELECT DISTINCT data_type FROM information_schema.columns WHERE data_type ILIKE 'unknown';
Fix or remove affected columns before proceeding.

Backup Requirement
Always take a manual snapshot before starting the upgrade.
For RDS PostgreSQL
Take a DB snapshot.
For Aurora PostgreSQL
Take a cluster snapshot.
Recommended snapshot naming format:
pre-major-upgrade--

Upgrade Execution Options
In‑Place Upgrade
Requires downtime.
Simple execution.
No immediate rollback once started.
Blue‑Green Deployment (Recommended for Production)
Minimal or zero downtime.
Allows application validation before cutover.
Instant rollback option available.

Post‑Upgrade Validation
Verify PostgreSQL version:
SHOW server_version;
Verify parameter groups are updated and attached correctly.
Validate extensions:
SELECT * FROM pg_extension;
Monitor database performance metrics:
CPU utilization
Freeable memory
Database connections
Replication lag
Performance Insights
Perform application sanity testing:
Read operations
Write operations
Batch jobs
Reporting queries
CDC or replication if applicable

Rollback Strategy
If issues occur after upgrade:
Stop application traffic.
Restore the pre‑upgrade snapshot.
Reattach old parameter groups.
Resume application traffic.

Important Notes
Major version upgrades are irreversible.
Always test the upgrade process in lower environments first.
Parameter group mismatch is the most common cause of upgrade failure.
Prepared transactions and logical replication slots are hard blockers.
