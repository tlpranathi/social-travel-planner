-- Safe DDL examples for the Level 3 demonstration.
CREATE TABLE IF NOT EXISTS demo_note (note_id SERIAL PRIMARY KEY, note_text TEXT NOT NULL);
ALTER TABLE demo_note ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();
DROP TABLE IF EXISTS demo_note;
