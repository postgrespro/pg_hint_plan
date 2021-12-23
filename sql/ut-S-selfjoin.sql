LOAD 'pg_hint_plan';
-- We cannot do ALTER USER current_user SET ...
DELETE FROM pg_db_role_setting WHERE setrole = (SELECT oid FROM pg_roles WHERE rolname = current_user);
INSERT INTO pg_db_role_setting (SELECT 0, (SELECT oid FROM pg_roles WHERE rolname = current_user), '{client_min_messages=log,pg_hint_plan.debug_print=on}');
ALTER SYSTEM SET session_preload_libraries TO 'pg_hint_plan';
SELECT pg_reload_conf();
SET pg_hint_plan.enable_hint TO on;
SET pg_hint_plan.debug_print TO on;
SET client_min_messages TO LOG;
SET search_path TO public;
SET max_parallel_workers_per_gather TO 0;
SET enable_self_join_removal TO on;

-- No. S-2-3-4
EXPLAIN (COSTS false) SELECT * FROM s1.v1 v1, s1.v1 v2 WHERE v1.c1 = v2.c1;
/*+BitmapScan(v1t1)*/
EXPLAIN (COSTS false) SELECT * FROM s1.v1 v1, s1.v1 v2 WHERE v1.c1 = v2.c1;

-- No. S-2-3-5
EXPLAIN (COSTS false) SELECT * FROM s1.v1 v1, s1.v1_ v2 WHERE v1.c1 = v2.c1;
/*+SeqScan(v1t1)BitmapScan(v1t1_)*/
EXPLAIN (COSTS false) SELECT * FROM s1.v1 v1, s1.v1_ v2 WHERE v1.c1 = v2.c1;

-- No. S-2-3-6
EXPLAIN (COSTS false) SELECT * FROM s1.r4 t1, s1.r4 t2 WHERE t1.c1 = t2.c1;
/*+BitmapScan(r4t1)*/
EXPLAIN (COSTS false) SELECT * FROM s1.r4 t1, s1.r4 t2 WHERE t1.c1 = t2.c1;

-- No. S-2-3-7
EXPLAIN (COSTS false) SELECT * FROM s1.r4 t1, s1.r5 t2 WHERE t1.c1 = t2.c1;
/*+SeqScan(r4t1)BitmapScan(r5t1)*/
EXPLAIN (COSTS false) SELECT * FROM s1.r4 t1, s1.r5 t2 WHERE t1.c1 = t2.c1;

DELETE FROM pg_db_role_setting WHERE setrole = (SELECT oid FROM pg_roles WHERE rolname = current_user);

ALTER SYSTEM SET session_preload_libraries TO DEFAULT;
SELECT pg_reload_conf();
