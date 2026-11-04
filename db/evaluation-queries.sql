-- 1. JOIN + ORDER BY: the trip schedule with attraction/category data.
SELECT d.date, i.start_time, a.name AS attraction, c.category_name
FROM itinerary_item i
JOIN itinerary_day d ON d.itinerary_day_id = i.itinerary_day_id
JOIN attraction a ON a.attraction_id = i.attraction_id
JOIN category c ON c.category_id = a.category_id
WHERE d.trip_id = 1
ORDER BY d.date, i.start_time;

-- 2. GROUP BY + HAVING: only attractions with a positive group decision.
SELECT a.name, SUM(v.vote_value) AS vote_score, COUNT(*) AS total_votes
FROM vote v
JOIN attraction a ON a.attraction_id = v.attraction_id
WHERE v.trip_id = 1
GROUP BY a.attraction_id, a.name
HAVING SUM(v.vote_value) > 0
ORDER BY vote_score DESC;

-- 3. Aggregate: spending against the planned group budget.
SELECT t.trip_name, t.budget, COALESCE(SUM(e.amount), 0) AS spent,
       t.budget - COALESCE(SUM(e.amount), 0) AS remaining_budget
FROM trip t
LEFT JOIN trip_expense e ON e.trip_id = t.trip_id
WHERE t.trip_id = 1
GROUP BY t.trip_id, t.trip_name, t.budget;

-- 4. Nested subquery: attractions voted on by a member of this trip.
SELECT name
FROM attraction
WHERE attraction_id IN (
  SELECT attraction_id FROM vote
  WHERE trip_id = 1 AND user_id IN (
    SELECT user_id FROM trip_member WHERE trip_id = 1
  )
);

-- 5. Correlated subquery: attractions costing at least their own category average.
SELECT a.name, a.cost, c.category_name
FROM attraction a
JOIN category c ON c.category_id = a.category_id
WHERE a.cost >= (
  SELECT AVG(other_a.cost)
  FROM attraction other_a
  WHERE other_a.category_id = a.category_id
);

-- 6. UPDATE and DELETE demonstration. ROLLBACK preserves the dataset.
BEGIN;
UPDATE trip SET status = 'COMPLETED' WHERE trip_id = 1;
SELECT trip_name, status FROM trip WHERE trip_id = 1;
DELETE FROM trip_expense WHERE trip_id = 1 AND description = 'Temporary evaluation expense';
ROLLBACK;

-- 7. View, stored function, trigger and vector search.
SELECT * FROM trip_dashboard_view WHERE trip_id = 1;
SELECT * FROM check_itinerary_conflicts(1);
SELECT * FROM search_attractions('[0.9,0.1,0.2]'::vector, 3);

-- Trigger proof: this overlaps 10:00-11:30. PostgreSQL rejects it; ROLLBACK cleans up.
BEGIN;
INSERT INTO itinerary_item(itinerary_day_id, attraction_id, start_time, end_time, sequence_no)
VALUES (1, 1, '10:30', '11:00', 99);
ROLLBACK;
