CREATE TABLE IF NOT EXISTS workers (worker_id INTEGER PRIMARY KEY UNIQUE, chief_id INTEGER, name TEXT);


CREATE OR REPLACE PROCEDURE add_worker(worker_id INTEGER, chief_id INTEGER, worker_name TEXT)
LANGUAGE SQL
AS $$
INSERT INTO workers VALUES (worker_id, chief_id, worker_name);
$$;

CREATE OR REPLACE PROCEDURE move_to_department(wid INTEGER, new_chief_id INTEGER)
LANGUAGE SQL
AS $$
UPDATE workers SET chief_id = new_chief_id WHERE workers.worker_id = wid;
$$;

CREATE OR REPLACE FUNCTION get_department_workers(wid INTEGER)
RETURNS TABLE(worker_id INTEGER, chief_id INTEGER, name TEXT)
LANGUAGE SQL
AS $$
SELECT * FROM workers WHERE workers.worker_id = wid
UNION ALL
SELECT * FROM workers WHERE workers.chief_id = wid;
$$;

CREATE OR REPLACE FUNCTION get_leaves()
RETURNS TABLE(worker_id INTEGER, chief_id INTEGER, name TEXT)
LANGUAGE SQL
AS $$
WITH chief_ids AS (
	SELECT DISTINCT(chief_id) FROM workers
)

SELECT worker_id, w1.chief_id, name FROM workers w1
LEFT JOIN chief_ids ON w1.worker_id = chief_ids.chief_id
WHERE chief_ids.chief_id IS NULL
ORDER BY worker_id;
$$;

CREATE OR REPLACE FUNCTION get_worker_with_all_chiefs(wid INTEGER)
RETURNS TABLE(worker_id INTEGER, chief_id INTEGER, name TEXT)
LANGUAGE SQL
AS $$
WITH RECURSIVE cte AS (
	SELECT worker_id, chief_id, name, 1 AS level FROM workers
	WHERE worker_id = wid
	UNION ALL
	SELECT w.worker_id, w.chief_id, w.name, c.level + 1 FROM cte c
	JOIN workers w ON w.worker_id = c.chief_id
)
SELECT worker_id, chief_id, name FROM cte;
$$;

DROP FUNCTION get_workers_count_in_department(wid INTEGER);

CREATE OR REPLACE FUNCTION get_workers_count_in_department(wid INTEGER)
RETURNS INTEGER
LANGUAGE SQL
AS $$
WITH RECURSIVE cte AS (
	SELECT worker_id, chief_id, name, 1 AS level FROM workers
	WHERE worker_id = wid
	UNION ALL
	SELECT w.worker_id, w.chief_id, w.name, c.level + 1 FROM cte c
	JOIN workers w ON w.chief_id = c.worker_id
)
SELECT COUNT(*) FROM cte;
$$;

CREATE OR REPLACE FUNCTION get_worker_rank(
	IN wid INTEGER,
	OUT worker_id INTEGER,
	OUT chief_id INTEGER,
	OUT name TEXT, out rank INTEGER
)
LANGUAGE SQL
AS $$
WITH worker_with_chiefs AS (
	WITH RECURSIVE cte AS (
		SELECT worker_id, chief_id, name, 1 AS level FROM workers
		WHERE worker_id = wid
		UNION ALL
		SELECT w.worker_id, w.chief_id, w.name, c.level + 1 FROM cte c
		JOIN workers w ON w.worker_id = c.chief_id
	)
	SELECT * FROM cte
)
SELECT workers.worker_id, workers.chief_id, workers.name, MAX(worker_with_chiefs.level) AS rank
FROM workers, worker_with_chiefs
GROUP BY workers.worker_id, workers.chief_id, workers.name
HAVING workers.worker_id = wid;
$$;

CREATE OR REPLACE FUNCTION get_hierarhy_of_subordination(wid INTEGER)
RETURNS TABLE(name TEXT, worker_id INTEGER, chief_id INTEGER)
LANGUAGE SQL
AS $$
WITH RECURSIVE cte AS (
	SELECT worker_id, chief_id, name, 1 AS level
	FROM workers
	WHERE worker_id = wid
	UNION ALL
	SELECT w.worker_id, w.chief_id, REPEAT('  ', c.level) || w.name, c.level + 1
	FROM cte c
	JOIN workers w ON w.chief_id = c.worker_id
)
SEARCH DEPTH FIRST BY worker_id SET ordercol
SELECT name, worker_id, chief_id FROM cte
ORDER BY ordercol;
$$;

CREATE OR REPLACE FUNCTION get_worker_with_all_chiefs_and_levels(wid INTEGER)
RETURNS TABLE(worker_id INTEGER, chief_id INTEGER, name TEXT, level INTEGER)
LANGUAGE SQL
AS $$
WITH RECURSIVE cte AS (
	SELECT worker_id, chief_id, name, 1 AS level FROM workers
	WHERE worker_id = wid
	UNION ALL
	SELECT w.worker_id, w.chief_id, w.name, c.level + 1 FROM cte c
	JOIN workers w ON w.worker_id = c.chief_id
)
SELECT worker_id, chief_id, name, level FROM cte;
$$;

CREATE OR REPLACE FUNCTION get_path_between_workers(wid1 INTEGER, wid2 INTEGER)
RETURNS TABLE(worker_id INTEGER, chief_id INTEGER, name TEXT)
LANGUAGE SQL
AS $$
WITH min_levels AS
(
	SELECT MIN(first_path.level) AS min_first_level, MIN(second_path.level) AS min_second_level
	FROM get_worker_with_all_chiefs_and_levels(wid1) AS first_path
	JOIN get_worker_with_all_chiefs_and_levels(wid2) AS second_path
	ON first_path.worker_id = second_path.worker_id
)
SELECT worker_id, chief_id, name FROM
(
	SELECT worker_id, chief_id, name, 1 AS path_index, level AS level_first, 0 AS level_second
	FROM get_worker_with_all_chiefs_and_levels(wid1) AS first_path
	JOIN min_levels ON first_path.level <= min_levels.min_first_level
	UNION ALL
	SELECT worker_id, chief_id, name, 2 AS path_index, 0 AS level_first, level AS level_second
	FROM get_worker_with_all_chiefs_and_levels(wid2) as second_path
	JOIN min_levels ON second_path.level < min_levels.min_second_level
	ORDER BY path_index, level_first, level_second DESC
) AS back_forth_path;
$$;
