import postgres from "postgres";

if (!process.env.DATABASE_URL) throw new Error("DATABASE_URL is missing. Copy .env.example to .env.local.");
export const sql = postgres(process.env.DATABASE_URL, { prepare: false });
