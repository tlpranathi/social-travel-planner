INSERT INTO app_user(name,email,role,password_hash) VALUES ('Asha Nair','asha@example.com','ORGANIZER',crypt('demo123',gen_salt('bf'))),('Rahul Menon','rahul@example.com','MEMBER',crypt('demo123',gen_salt('bf'))),('System Admin','admin@example.com','ADMIN',crypt('admin123',gen_salt('bf')));
INSERT INTO destination(name,country,latitude,longitude) VALUES ('Goa','India',15.2993,74.1240);
INSERT INTO category(category_name) VALUES ('Beach'),('Culture'),('Food'),('Nature');
INSERT INTO trip(organizer_id,destination_id,trip_name,start_date,end_date,budget) VALUES (1,1,'Goa Weekend Escape','2026-11-14','2026-11-16',18000);
INSERT INTO trip_member(trip_id,user_id,member_role) VALUES (1,1,'ORGANIZER'),(1,2,'MEMBER');
INSERT INTO attraction(destination_id,category_id,name,description,cost,estimated_minutes,outdoor_flag,embedding) VALUES
 (1,1,'Palolem Beach','A calm south Goa beach for sunset walks and swimming.',0,120,true,'[0.9,0.1,0.2]'),
 (1,2,'Basilica of Bom Jesus','Historic UNESCO church in Old Goa with cultural exhibits.',50,90,false,'[0.2,0.9,0.1]'),
 (1,3,'Fishermans Wharf','Goan seafood restaurant suited to a relaxed group dinner.',900,90,false,'[0.1,0.2,0.9]'),
 (1,4,'Dudhsagar Falls','Scenic waterfall excursion with forest views and trekking.',600,300,true,'[0.7,0.4,0.2]');
INSERT INTO weather_snapshot(destination_id,forecast_date,temperature,precipitation_probability,weather_code) VALUES (1,'2026-11-14',28,10,'Clear');
INSERT INTO trip_expense(trip_id,user_id,amount,category,description) VALUES (1,1,2400,'Stay deposit','Shared hostel booking'),(1,2,600,'Transport','Airport transfer');
INSERT INTO vote(trip_id,attraction_id,user_id,vote_value) VALUES (1,1,2,1),(1,2,2,1),(1,3,1,1);
INSERT INTO itinerary_day(trip_id,day_number,date) VALUES (1,1,'2026-11-14');
INSERT INTO itinerary_item(itinerary_day_id,attraction_id,start_time,end_time,sequence_no) VALUES (1,2,'10:00','11:30',1),(1,3,'19:00','20:30',2);
INSERT INTO user_preference(user_id,category_id,preference_score,budget_limit,pace) VALUES (1,1,5,10000,'RELAXED'),(1,3,4,10000,'RELAXED'),(2,2,5,8000,'BALANCED'),(2,4,4,8000,'BALANCED');
INSERT INTO trip_invitation(trip_id,invited_by,invitee_email) VALUES (1,1,'friend@example.com');
INSERT INTO attraction_hours(attraction_id,day_of_week,open_time,close_time) SELECT attraction_id,0,'09:00','18:00' FROM attraction;
