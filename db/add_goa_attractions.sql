-- Apply this once to an existing local database without resetting the Docker volume.
INSERT INTO attraction(destination_id,category_id,name,description,cost,estimated_minutes,outdoor_flag,embedding)
SELECT 1, category_id, name, description, cost, minutes, outdoor, embedding::vector
FROM (VALUES
  ('Beach','Agonda Beach','Quiet sandy beach with gentle waves, yoga huts and sunset views.',0,150,true,'[0.95,0.12,0.12]'),
  ('Beach','Baga Beach','Lively beach with water sports, shacks and evening activity.',300,180,true,'[0.70,0.10,0.75]'),
  ('Beach','Candolim Beach','Wide beach ideal for swimming, relaxed walks and water sports.',100,150,true,'[0.82,0.12,0.35]'),
  ('Culture','Fort Aguada','Seventeenth-century Portuguese fort with sea views and history.',50,90,true,'[0.35,0.88,0.15]'),
  ('Culture','Chapora Fort','Hilltop fort overlooking the coast, known for history and sunset.',50,90,true,'[0.55,0.78,0.18]'),
  ('Culture','Goa State Museum','Indoor museum displaying Goan art, history and archaeology.',40,100,false,'[0.12,0.95,0.12]'),
  ('Food','Gunpowder Restaurant','Popular Goan restaurant serving regional dishes in a relaxed setting.',850,90,false,'[0.12,0.20,0.92]'),
  ('Food','Cafe Chocolatti','Garden cafe for coffee, desserts and a quiet group break.',450,60,false,'[0.22,0.18,0.82]'),
  ('Nature','Bondla Wildlife Sanctuary','Forest sanctuary with wildlife, nature trails and a small zoo.',200,180,true,'[0.25,0.92,0.42]'),
  ('Nature','Salim Ali Bird Sanctuary','Mangrove sanctuary for birdwatching and calm nature walks.',150,120,true,'[0.32,0.85,0.18]')
) AS new_places(category_name,name,description,cost,minutes,outdoor,embedding)
JOIN category c ON c.category_name=new_places.category_name
WHERE NOT EXISTS (SELECT 1 FROM attraction a WHERE a.name=new_places.name);

INSERT INTO attraction_hours(attraction_id,day_of_week,open_time,close_time)
SELECT attraction_id,0,'09:00','18:00' FROM attraction
ON CONFLICT(attraction_id,day_of_week) DO NOTHING;
