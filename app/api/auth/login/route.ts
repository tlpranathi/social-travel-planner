import { sql } from "@/lib/db";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const { email, password } = await request.json();
  const users = await sql`SELECT user_id,role FROM app_user WHERE lower(email)=lower(${String(email)}) AND password_hash=crypt(${String(password)},password_hash)`;
  if (!users[0]) return NextResponse.json({ error:"Invalid email or password" },{status:401});
  const sessions = await sql`INSERT INTO user_session(user_id) VALUES (${users[0].user_id}) RETURNING session_token`;
  const response = NextResponse.json({ role: users[0].role });
  response.cookies.set("travel_session",String(sessions[0].session_token),{httpOnly:true,sameSite:"lax",path:"/",maxAge:60*60*24*7});
  return response;
}
