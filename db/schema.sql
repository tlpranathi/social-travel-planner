CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE app_user (
  user_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(150) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL DEFAULT 'demo-not-for-production', role VARCHAR(20) NOT NULL CHECK (role IN ('ORGANIZER','MEMBER','ADMIN')), created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE destination (destination_id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL, country VARCHAR(100) NOT NULL, latitude NUMERIC(9,6), longitude NUMERIC(9,6));
CREATE TABLE category (category_id SERIAL PRIMARY KEY, category_name VARCHAR(50) UNIQUE NOT NULL);
CREATE TABLE trip (
  trip_id SERIAL PRIMARY KEY, organizer_id INT NOT NULL REFERENCES app_user(user_id), destination_id INT NOT NULL REFERENCES destination(destination_id),
  trip_name VARCHAR(120) NOT NULL, start_date DATE NOT NULL, end_date DATE NOT NULL, budget NUMERIC(10,2) NOT NULL CHECK (budget >= 0), status VARCHAR(20) NOT NULL DEFAULT 'PLANNING' CHECK (status IN ('PLANNING','FINALIZED','COMPLETED')),
  CHECK (end_date >= start_date)
);
CREATE TABLE trip_member (trip_id INT REFERENCES trip(trip_id) ON DELETE CASCADE, user_id INT REFERENCES app_user(user_id) ON DELETE CASCADE, member_role VARCHAR(20) NOT NULL DEFAULT 'MEMBER', PRIMARY KEY (trip_id,user_id));
CREATE TABLE attraction (
  attraction_id SERIAL PRIMARY KEY, destination_id INT NOT NULL REFERENCES destination(destination_id), category_id INT NOT NULL REFERENCES category(category_id), name VARCHAR(120) NOT NULL,
  description TEXT NOT NULL, cost NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (cost >= 0), estimated_minutes INT NOT NULL CHECK (estimated_minutes BETWEEN 15 AND 720), outdoor_flag BOOLEAN NOT NULL DEFAULT true,
  embedding vector(3)
);
CREATE TABLE vote (
  vote_id SERIAL PRIMARY KEY, trip_id INT NOT NULL, attraction_id INT NOT NULL REFERENCES attraction(attraction_id), user_id INT NOT NULL, vote_value SMALLINT NOT NULL CHECK (vote_value IN (-1,1)), created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  FOREIGN KEY (trip_id,user_id) REFERENCES trip_member(trip_id,user_id), UNIQUE (trip_id,attraction_id,user_id)
);
CREATE TABLE itinerary_day (itinerary_day_id SERIAL PRIMARY KEY, trip_id INT NOT NULL REFERENCES trip(trip_id) ON DELETE CASCADE, day_number INT NOT NULL CHECK (day_number > 0), date DATE NOT NULL, UNIQUE(trip_id,day_number));
CREATE TABLE itinerary_item (item_id SERIAL PRIMARY KEY, itinerary_day_id INT NOT NULL REFERENCES itinerary_day(itinerary_day_id) ON DELETE CASCADE, attraction_id INT NOT NULL REFERENCES attraction(attraction_id), start_time TIME NOT NULL, end_time TIME NOT NULL, sequence_no INT NOT NULL CHECK(sequence_no > 0), CHECK(end_time > start_time), UNIQUE(itinerary_day_id,sequence_no));
CREATE TABLE trip_expense (expense_id SERIAL PRIMARY KEY, trip_id INT NOT NULL REFERENCES trip(trip_id) ON DELETE CASCADE, user_id INT NOT NULL REFERENCES app_user(user_id), amount NUMERIC(10,2) NOT NULL CHECK(amount > 0), category VARCHAR(40) NOT NULL, description TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE weather_snapshot (weather_id SERIAL PRIMARY KEY, destination_id INT NOT NULL REFERENCES destination(destination_id), forecast_date DATE NOT NULL, temperature NUMERIC(4,1), precipitation_probability INT CHECK(precipitation_probability BETWEEN 0 AND 100), weather_code VARCHAR(50), UNIQUE(destination_id,forecast_date));
CREATE TABLE user_preference (preference_id SERIAL PRIMARY KEY, user_id INT NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE, category_id INT REFERENCES category(category_id), preference_score INT NOT NULL CHECK(preference_score BETWEEN 1 AND 5), budget_limit NUMERIC(10,2) CHECK(budget_limit>=0), pace VARCHAR(20) CHECK(pace IN ('RELAXED','BALANCED','FAST')), UNIQUE(user_id,category_id));
CREATE TABLE trip_invitation (invitation_id SERIAL PRIMARY KEY, trip_id INT NOT NULL REFERENCES trip(trip_id) ON DELETE CASCADE, invited_by INT NOT NULL REFERENCES app_user(user_id), invitee_email VARCHAR(150) NOT NULL, invitation_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK(invitation_status IN ('PENDING','ACCEPTED','DECLINED')), created_at TIMESTAMPTZ DEFAULT now(), UNIQUE(trip_id,invitee_email));
CREATE TABLE user_session (session_token UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id INT NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE, expires_at TIMESTAMPTZ NOT NULL DEFAULT now() + interval '7 days');
CREATE TABLE attraction_hours (hours_id SERIAL PRIMARY KEY, attraction_id INT NOT NULL REFERENCES attraction(attraction_id) ON DELETE CASCADE, day_of_week SMALLINT NOT NULL CHECK(day_of_week BETWEEN 0 AND 6), open_time TIME NOT NULL, close_time TIME NOT NULL, CHECK(close_time>open_time), UNIQUE(attraction_id,day_of_week));

CREATE INDEX attraction_destination_category_idx ON attraction(destination_id, category_id);
CREATE INDEX vote_trip_attraction_idx ON vote(trip_id, attraction_id);
CREATE INDEX attraction_embedding_idx ON attraction USING ivfflat (embedding vector_l2_ops) WITH (lists = 10);
CREATE INDEX session_token_idx ON user_session(session_token);
CREATE INDEX preference_user_idx ON user_preference(user_id);

CREATE OR REPLACE VIEW vote_summary_view AS
SELECT trip_id, attraction_id, SUM(vote_value)::int AS vote_score, COUNT(*)::int AS vote_count FROM vote GROUP BY trip_id, attraction_id;
CREATE OR REPLACE VIEW trip_dashboard_view AS
SELECT t.trip_id,t.trip_name,t.start_date,t.end_date,t.budget,d.name AS destination_name,d.country,
  COUNT(DISTINCT tm.user_id)::int AS member_count,COALESCE(SUM(DISTINCT e.amount),0) AS total_expense,
  CONCAT(COALESCE(w.temperature::text,'?'),' C, ',COALESCE(w.weather_code,'No forecast')) AS weather_summary
FROM trip t JOIN destination d ON d.destination_id=t.destination_id LEFT JOIN trip_member tm ON tm.trip_id=t.trip_id LEFT JOIN trip_expense e ON e.trip_id=t.trip_id LEFT JOIN weather_snapshot w ON w.destination_id=d.destination_id AND w.forecast_date=t.start_date
GROUP BY t.trip_id,d.name,d.country,w.temperature,w.weather_code;

CREATE OR REPLACE FUNCTION check_itinerary_conflicts(day_id INT) RETURNS TABLE(item_id INT, conflict_with INT) LANGUAGE sql AS $$
 SELECT a.item_id,b.item_id FROM itinerary_item a JOIN itinerary_item b ON a.itinerary_day_id=b.itinerary_day_id AND a.item_id<b.item_id AND a.start_time<b.end_time AND b.start_time<a.end_time WHERE a.itinerary_day_id=day_id;
$$;
CREATE OR REPLACE FUNCTION validate_itinerary_item() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM itinerary_item WHERE itinerary_day_id=NEW.itinerary_day_id AND item_id<>COALESCE(NEW.item_id,0) AND NEW.start_time<end_time AND start_time<NEW.end_time) THEN RAISE EXCEPTION 'Itinerary time overlaps an existing item'; END IF;
  RETURN NEW;
END; $$;
CREATE TRIGGER itinerary_overlap_guard BEFORE INSERT OR UPDATE ON itinerary_item FOR EACH ROW EXECUTE FUNCTION validate_itinerary_item();

-- Vector similarity example (the demo stores compact three-value vectors).
CREATE OR REPLACE FUNCTION search_attractions(query_vector vector(3), limit_count INT DEFAULT 5) RETURNS TABLE(attraction_id INT, name VARCHAR, distance REAL) LANGUAGE sql AS $$
 SELECT attraction_id,name,(embedding <-> query_vector)::real FROM attraction WHERE embedding IS NOT NULL ORDER BY embedding <-> query_vector LIMIT limit_count;
$$;

CREATE OR REPLACE FUNCTION refresh_trip_status() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE trip SET status='FINALIZED' WHERE trip_id=NEW.trip_id AND status='PLANNING' AND (SELECT COUNT(*) FROM itinerary_day WHERE trip_id=NEW.trip_id)>0;
  RETURN NEW;
END; $$;
CREATE TRIGGER finalize_trip_when_scheduled AFTER INSERT ON itinerary_day FOR EACH ROW EXECUTE FUNCTION refresh_trip_status();
