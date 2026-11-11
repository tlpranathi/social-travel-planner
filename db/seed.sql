INSERT INTO app_user(name,email,role,password_hash) VALUES ('Asha Nair','asha@example.com','ORGANIZER',crypt('demo123',gen_salt('bf'))),('Rahul Menon','rahul@example.com','MEMBER',crypt('demo123',gen_salt('bf'))),('System Admin','admin@example.com','ADMIN',crypt('admin123',gen_salt('bf')));
INSERT INTO destination(name,country,latitude,longitude) VALUES ('Goa','India',15.2993,74.1240);
INSERT INTO category(category_name) VALUES ('Beach'),('Culture'),('Food'),('Nature');
INSERT INTO trip(organizer_id,destination_id,trip_name,start_date,end_date,budget) VALUES (1,1,'Goa Weekend Escape','2026-11-14','2026-11-16',18000);
INSERT INTO trip_member(trip_id,user_id,member_role) VALUES (1,1,'ORGANIZER'),(1,2,'MEMBER');
INSERT INTO attraction(destination_id,category_id,name,description,cost,estimated_minutes,outdoor_flag,embedding) VALUES
 (1,1,'Palolem Beach','A calm south Goa beach for sunset walks and swimming.',0,120,true,'[0.9,0.1,0.2]'),
 (1,2,'Basilica of Bom Jesus','Historic UNESCO church in Old Goa with cultural exhibits.',50,90,false,'[0.2,0.9,0.1]'),
 (1,3,'Fishermans Wharf','Goan seafood restaurant suited to a relaxed group dinner.',900,90,false,'[0.1,0.2,0.9]'),
 (1,4,'Dudhsagar Falls','Scenic waterfall excursion with forest views and trekking.',600,300,true,'[0.7,0.4,0.2]'),
 (1,1,'Agonda Beach','Quiet sandy beach with gentle waves, yoga huts and sunset views.',0,150,true,'[0.95,0.12,0.12]'),
 (1,1,'Baga Beach','Lively beach with water sports, shacks and evening activity.',300,180,true,'[0.70,0.10,0.75]'),
 (1,1,'Candolim Beach','Wide beach ideal for swimming, relaxed walks and water sports.',100,150,true,'[0.82,0.12,0.35]'),
 (1,2,'Fort Aguada','Seventeenth-century Portuguese fort with sea views and history.',50,90,true,'[0.35,0.88,0.15]'),
 (1,2,'Chapora Fort','Hilltop fort overlooking the coast, known for history and sunset.',50,90,true,'[0.55,0.78,0.18]'),
 (1,2,'Goa State Museum','Indoor museum displaying Goan art, history and archaeology.',40,100,false,'[0.12,0.95,0.12]'),
 (1,3,'Gunpowder Restaurant','Popular Goan restaurant serving regional dishes in a relaxed setting.',850,90,false,'[0.12,0.20,0.92]'),
 (1,3,'Cafe Chocolatti','Garden cafe for coffee, desserts and a quiet group break.',450,60,false,'[0.22,0.18,0.82]'),
 (1,4,'Bondla Wildlife Sanctuary','Forest sanctuary with wildlife, nature trails and a small zoo.',200,180,true,'[0.25,0.92,0.42]'),
 (1,4,'Salim Ali Bird Sanctuary','Mangrove sanctuary for birdwatching and calm nature walks.',150,120,true,'[0.32,0.85,0.18]');
INSERT INTO weather_snapshot(destination_id,forecast_date,temperature,precipitation_probability,weather_code) VALUES (1,'2026-11-14',28,10,'Clear');
INSERT INTO trip_expense(trip_id,user_id,amount,category,description) VALUES (1,1,2400,'Stay deposit','Shared hostel booking'),(1,2,600,'Transport','Airport transfer');
INSERT INTO vote(trip_id,attraction_id,user_id,vote_value) VALUES (1,1,2,1),(1,2,2,1),(1,3,1,1);
INSERT INTO itinerary_day(trip_id,day_number,date) VALUES (1,1,'2026-11-14');
INSERT INTO itinerary_item(itinerary_day_id,attraction_id,start_time,end_time,sequence_no) VALUES (1,2,'10:00','11:30',1),(1,3,'19:00','20:30',2);
INSERT INTO user_preference(user_id,category_id,preference_score,budget_limit,pace) VALUES (1,1,5,10000,'RELAXED'),(1,3,4,10000,'RELAXED'),(2,2,5,8000,'BALANCED'),(2,4,4,8000,'BALANCED');
INSERT INTO trip_invitation(trip_id,invited_by,invitee_email) VALUES (1,1,'friend@example.com');
INSERT INTO attraction_hours(attraction_id,day_of_week,open_time,close_time) SELECT attraction_id,0,'09:00','18:00' FROM attraction;
