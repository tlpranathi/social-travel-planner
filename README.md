# Social Travel Planner

A collaborative trip-planning web app where a group can pick a destination, browse attractions, vote on what to do, build a day-wise itinerary and keep an eye on the shared budget, all in one place.

The project is built around a relational schema in **PostgreSQL**, with **pgvector** as a second data paradigm for semantic attraction search. The seed data is a three-day Goa trip.

## Team

| Name | SRN |
|---|---|
| Lakshmi Pranathi | PES2UG24CS249 |
| Naija Hodigere | PES2UG24CS296 |

## Features

- **Accounts and roles:** register and sign in with hashed passwords (`crypt` + bcrypt via pgcrypto) and database-backed sessions in an HTTP-only cookie. Three roles: `ORGANIZER`, `MEMBER`, `ADMIN`, with role-based navigation and page access.
- **Trips:** create a trip with destination, dates and group budget. The creator is automatically added as organizer.
- **Invitations:** organizers can invite people to a trip by email.
- **Explore attractions:** search by keyword, filter by category, maximum cost and outdoor/indoor, or switch on **semantic search** to rank attractions by vector similarity to a natural-language query such as "quiet sunset by the sea".
- **Group voting:** members upvote or downvote attractions. One vote per member per attraction per trip, and changing your vote updates it instead of duplicating it.
- **Itinerary builder:** schedule attractions into days with start and end times. A database trigger rejects overlapping slots.
- **Budget tracking:** each trip shows expenses against the planned budget.
- **Preferences:** each user can set category scores (1 to 5), a personal budget limit and a preferred pace (`RELAXED`, `BALANCED`, `FAST`).
- **Admin view:** read-only review of the attraction catalogue.

## Tech stack

| Layer | Technology |
|---|---|
| Frontend and API | Next.js 14 (App Router, Route Handlers), React 18, TypeScript |
| Database | PostgreSQL 16 with the `pgvector` and `pgcrypto` extensions |
| DB client | [`postgres`](https://github.com/porsager/postgres) (postgres.js) |
| Infrastructure | Docker Compose (`pgvector/pgvector:pg16` image) |

## Architecture

```text
Browser -> Next.js pages / Route Handlers -> PostgreSQL + pgvector
                                          -> Docker seed data
```

## Database design

### Tables

| Table | Purpose |
|---|---|
| `app_user`, `user_session` | accounts, roles, hashed passwords, 7-day sessions |
| `trip`, `trip_member`, `trip_invitation` | trips, membership and invitations |
| `destination`, `category`, `attraction`, `attraction_hours` | destination catalogue; `attraction.embedding` is a `vector(3)` |
| `vote` | one vote per (trip, attraction, user), restricted to trip members |
| `itinerary_day`, `itinerary_item` | day-wise schedule |
| `trip_expense`, `weather_snapshot` | budget and dashboard context |
| `user_preference` | per-user category scores, budget limit and pace |

### ER diagram

```mermaid
erDiagram
  APP_USER ||--o{ TRIP : organizes
  APP_USER ||--o{ TRIP_MEMBER : joins
  TRIP ||--o{ TRIP_MEMBER : has
  DESTINATION ||--o{ TRIP : hosts
  DESTINATION ||--o{ ATTRACTION : contains
  CATEGORY ||--o{ ATTRACTION : classifies
  TRIP ||--o{ VOTE : receives
  APP_USER ||--o{ VOTE : casts
  ATTRACTION ||--o{ VOTE : receives
  TRIP ||--o{ ITINERARY_DAY : contains
  ITINERARY_DAY ||--o{ ITINERARY_ITEM : contains
  ATTRACTION ||--o{ ITINERARY_ITEM : schedules
  TRIP ||--o{ TRIP_EXPENSE : tracks
```

### Advanced database features

1. **Views:** `vote_summary_view` and `trip_dashboard_view` avoid repeating common dashboard joins.
2. **Stored function:** `check_itinerary_conflicts(day_id)` lists overlapping itinerary items for a day.
3. **Triggers:** `itinerary_overlap_guard` blocks overlapping itinerary times, and `finalize_trip_when_scheduled` moves a trip from `PLANNING` to `FINALIZED` once a day is scheduled.
4. **Vector search:** `search_attractions(query_vector, limit_count)` ranks attractions by L2 distance, backed by an `ivfflat` index.
5. **Indexes:** on attraction destination/category, votes per trip and attraction, session tokens and user preferences.
6. **Transactions:** the vote, trip-creation and itinerary APIs run inside database transactions.
7. **Constraints:** `CHECK`, `UNIQUE` and composite foreign keys enforce rules such as valid dates, non-negative budgets and members-only voting.

### Why PostgreSQL + pgvector

PostgreSQL suits the related, constrained trip data (members, votes, schedules, budgets). pgvector is the second paradigm: each attraction stores a compact embedding and similar places are ranked by vector distance. The demo uses **three-value placeholder embeddings** (roughly beach, culture/nature, food/activity) and a keyword-based query embedder in `lib/semantic.ts`, so everything runs offline. A production version would generate real embeddings with a documented model.

## Getting started

### Prerequisites

- [Node.js](https://nodejs.org/) 18 or newer
- [Docker](https://www.docker.com/) with Docker Compose

### 1. Clone and install

```bash
git clone <repository-url>
cd social-travel-planner
npm install
```

### 2. Start the database

```bash
docker compose up -d
```

This starts PostgreSQL with pgvector on **port 5433** and automatically runs `db/schema.sql` and `db/seed.sql` on first start.

### 3. Configure the environment

```bash
cp .env.example .env.local
```

The default value already matches the Docker setup:

```env
DATABASE_URL=postgresql://travel_user:travel_password@localhost:5433/social_travel
```

### 4. Run the app

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000). You will be redirected to the login page.

### Demo accounts

| Role | Email | Password |
|---|---|---|
| Organizer | `asha@example.com` | `demo123` |
| Member | `rahul@example.com` | `demo123` |
| Admin | `admin@example.com` | `admin123` |

> These credentials are for local demonstration only.

### Resetting the database

The seed scripts only run when the Docker volume is first created. To start fresh:

```bash
docker compose down -v
docker compose up -d
```

If you already have a running database and only need the extra Goa attractions, apply `db/add_goa_attractions.sql` once instead of resetting.

## Available scripts

| Command | Description |
|---|---|
| `npm run dev` | Start the development server |
| `npm run build` | Create a production build |
| `npm start` | Run the production build |
| `npm run lint` | Run linting |

## Project structure

```text
social-travel-planner/
├── app/
│   ├── page.tsx               # Dashboard: trips, preferences, create trip
│   ├── login/                 # Sign in / register
│   ├── explore/               # Attraction search, filters, semantic search, voting
│   ├── trips/[id]/            # Trip workspace: members, invites, itinerary, budget
│   ├── preferences/           # Travel preferences
│   ├── admin/                 # Admin catalogue review
│   └── api/                   # Route Handlers: auth, trips, votes, itinerary,
│                              #   invitations, preferences
├── components/                # Nav, forms, vote button
├── lib/
│   ├── db.ts                  # PostgreSQL connection
│   ├── auth.ts                # Session lookup and trip-membership check
│   └── semantic.ts            # Offline query-to-vector helper
├── db/
│   ├── schema.sql             # Tables, indexes, views, functions, triggers
│   ├── seed.sql               # Goa demo data
│   ├── add_goa_attractions.sql# Extra attractions for an existing database
│   ├── demo-queries.sql       # Demo SQL queries
│   ├── evaluation-queries.sql # Evaluation queries (join, group by, subqueries, ...)
│   └── ddl-demonstration.sql  # CREATE / ALTER / DROP demonstration
├── docs/PROJECT_DOCUMENTATION.md
├── docker-compose.yml
└── .env.example
```

## Trying the database features

Connect to the database inside the container:

```bash
docker exec -it social-travel-db psql -U travel_user -d social_travel
```

Then run the files in `db/` (for example, paste in `db/evaluation-queries.sql`) or try these directly:

```sql
-- Vector similarity search
SELECT * FROM search_attractions('[0.9,0.1,0.2]'::vector, 3);

-- Dashboard view
SELECT * FROM trip_dashboard_view WHERE trip_id = 1;

-- Conflict check for a day's itinerary
SELECT * FROM check_itinerary_conflicts(1);

-- Trigger proof: overlaps the 10:00-11:30 slot, so it is rejected
BEGIN;
INSERT INTO itinerary_item(itinerary_day_id, attraction_id, start_time, end_time, sequence_no)
VALUES (1, 1, '10:30', '11:00', 99);
ROLLBACK;
```

## Test checklist

| Test | Expected result |
|---|---|
| Start the Docker database | Schema and seeded Goa data appear |
| Log in as organizer, member and admin | Role-based navigation and page access apply; only admins see the Admin page |
| Load the dashboard | Trip summary, spend against budget and preferences display |
| Search `beach` on Explore | Beach attractions such as Palolem Beach are listed |
| Turn on semantic search for "quiet sunset" | Results are ordered by vector distance |
| Vote on an attraction, then vote again | The vote is saved, and the second vote updates the first |
| Add an itinerary item overlapping an existing slot | The trigger rejects it |
| Register a new user | A hashed password and a database-backed session are created |
| Create a trip, send an invitation, save a preference | The dashboard updates after each successful API transaction |
| Run `SELECT * FROM search_attractions('[0.9,0.1,0.2]', 3)` | Related attractions are returned ordered by distance |

## Scope and limitations

This is a classroom project with a deliberately small scope:

- One seeded destination (Goa) with a small attraction catalogue.
- No payments or bookings, and weather comes from a stored snapshot rather than a live API.
- Embeddings are placeholder three-value vectors, not model-generated.
- Invitations are recorded for the organizer but are not emailed or accepted through the UI.
- Authentication is intended for local demonstration, not production use.

## Further documentation

See [`docs/PROJECT_DOCUMENTATION.md`](docs/PROJECT_DOCUMENTATION.md) for the problem statement, architecture notes and database justification.
