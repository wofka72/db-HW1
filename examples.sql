-- #1
-- CALL add_worker(2000000, 12, 'Scott Pilgrim');
-- CALL add_worker(2000001, 14, 'Mary Pilgrim');
-- CALL add_worker(2000002, 2000001, 'John Pilgrim');

-- #2
-- CALL move_to_department(3, 1);
-- SELECT * FROM workers WHERE worker_id = 3;
-- CALL move_to_department(3, 2);
-- SELECT * FROM workers WHERE worker_id = 3;

-- #3
-- SELECT * FROM get_department_workers(11);

-- #4
-- SELECT * FROM get_leaves();

-- #5
-- SELECT * FROM get_worker_with_all_chiefs(1);
-- SELECT * FROM get_worker_with_all_chiefs(123);
-- SELECT * FROM get_worker_with_all_chiefs(654321);
-- SELECT * FROM get_worker_with_all_chiefs(2000002);

-- #6
-- SELECT * FROM get_workers_count_in_department(1);
-- SELECT * FROM get_workers_count_in_department(2);
-- SELECT * FROM get_workers_count_in_department(3);
-- SELECT * FROM get_workers_count_in_department(123456);
-- SELECT * FROM get_leaves() WHERE worker_id = 123456;
-- SELECT * FROM get_workers_count_in_department(654321);

-- #8
-- SELECT * FROM get_worker_rank(1);
-- SELECT * FROM get_worker_rank(2);
-- SELECT * FROM get_worker_rank(123);
-- SELECT * FROM get_worker_rank(123456);
-- SELECT * FROM get_worker_rank(654321);

-- #9
-- SELECT * FROM get_hierarhy_of_subordination(82);
-- SELECT * FROM get_hierarhy_of_subordination(1); -- Works few tens of seconds.

-- #10
-- SELECT * FROM get_path_between_workers(33, 135735);
-- SELECT * FROM get_path_between_workers(33, 1);
-- SELECT * FROM get_path_between_workers(33, 2000002);
