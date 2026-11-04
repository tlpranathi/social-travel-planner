import { sql } from "@/lib/db";
import { NextResponse } from "next/server";
export async function POST(request: Request) {
  const { name,email,password }=await request.json();
  if (!name || !email || String(password).length<6) return NextResponse.json({error:"Use a name, valid email and 6+ character password."},{status:400});
  try { const rows=await sql`INSERT INTO app_user(name,email,role,password_hash) VALUES (${String(name)},${String(email)},'MEMBER',crypt(${String(password)},gen_salt('bf'))) RETURNING user_id`; const session=await sql`INSERT INTO user_session(user_id) VALUES (${rows[0].user_id}) RETURNING session_token`; const res=NextResponse.json({ok:true}); res.cookies.set("travel_session",String(session[0].session_token),{httpOnly:true,sameSite:"lax",path:"/",maxAge:604800}); return res; } catch { return NextResponse.json({error:"An account with that email already exists."},{status:409}); }
}
