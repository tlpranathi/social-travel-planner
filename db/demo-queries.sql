-- JOIN + ORDER BY: show selected schedule items.
SELECT d.date, i.start_time, a.name, c.category_name FROM itinerary_item i JOIN itinerary_day d ON d.itinerary_day_id=i.itinerary_day_id JOIN attraction a ON a.attraction_id=i.attraction_id JOIN category c ON c.category_id=a.category_id WHERE d.trip_id=1 ORDER BY d.date,i.start_time;
-- GROUP BY + HAVING: attractions with one or more positive votes.
SELECT a.name,SUM(v.vote_value) AS score FROM vote v JOIN attraction a ON a.attraction_id=v.attraction_id WHERE v.trip_id=1 GROUP BY a.name HAVING SUM(v.vote_value)>0 ORDER BY score DESC;
-- Aggregate + subquery: attractions cheaper than the average attraction cost.
SELECT name,cost FROM attraction WHERE cost < (SELECT AVG(cost) FROM attraction WHERE destination_id=1);
-- UPDATE and DELETE demonstration (run only on a disposable copy).
UPDATE trip SET status='FINALIZED' WHERE trip_id=1;
DELETE FROM trip_expense WHERE description='Temporary test expense';
-- Semantic similarity search.
SELECT * FROM search_attractions('[0.9,0.1,0.2]'::vector, 3);
