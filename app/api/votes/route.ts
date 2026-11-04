import { sql } from "@/lib/db";
import { NextResponse } from "next/server";
import { currentUser, isTripMember } from "@/lib/auth";

export async function POST(request: Request) {
  const { attractionId, tripId, value } = await request.json();
  const user=await currentUser();
  if (!user) return NextResponse.json({error:"Please sign in"},{status:401});
  if (!Number.isInteger(attractionId) || !Number.isInteger(tripId) || ![-1, 1].includes(value) || !await isTripMember(user.user_id,tripId)) return NextResponse.json({ error: "Invalid vote or trip access" }, { status: 400 });
  try {
    await sql.begin(async transaction => {
      await transaction`INSERT INTO vote (trip_id, attraction_id, user_id, vote_value) VALUES (${tripId}, ${attractionId}, ${user.user_id}, ${value}) ON CONFLICT(trip_id,attraction_id,user_id) DO UPDATE SET vote_value=EXCLUDED.vote_value,created_at=now()`;
    });
    return NextResponse.json({ ok: true });
  } catch { return NextResponse.json({ error: "Vote could not be saved." }, { status: 409 }); }
}
