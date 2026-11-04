import { cookies } from "next/headers";
import { sql } from "@/lib/db";

export type User = { user_id: number; name: string; email: string; role: "ORGANIZER" | "MEMBER" | "ADMIN" };

export async function currentUser(): Promise<User | null> {
  const token = cookies().get("travel_session")?.value;
  if (!token) return null;
  const rows = await sql<User[]>`SELECT u.user_id,u.name,u.email,u.role FROM user_session s JOIN app_user u ON u.user_id=s.user_id WHERE s.session_token=${token} AND s.expires_at>now()`;
  return rows[0] ?? null;
}

export async function isTripMember(userId: number, tripId: number) {
  const rows = await sql`SELECT 1 FROM trip_member WHERE trip_id=${tripId} AND user_id=${userId}`;
  return rows.length > 0;
}
