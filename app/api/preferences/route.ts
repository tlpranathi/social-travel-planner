import { sql } from "@/lib/db";
import { currentUser } from "@/lib/auth";
import { NextResponse } from "next/server";

const ALLOWED_PACES = ["RELAXED", "BALANCED", "FAST"] as const;

export async function POST(request: Request) {
  const user = await currentUser();
  if (!user) {
    return NextResponse.json({ error: "Sign in required" }, { status: 401 });
  }

  let body: { categoryId?: unknown; score?: unknown; budgetLimit?: unknown; pace?: unknown };
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "Invalid JSON request body" }, { status: 400 });
  }

  const categoryId = Number(body.categoryId);
  const score = Number(body.score);
  const budgetLimit = Number(body.budgetLimit);
  const pace = typeof body.pace === "string" ? body.pace : "";

  if (!Number.isInteger(categoryId) || categoryId <= 0) {
    return NextResponse.json({ error: "Choose a valid category" }, { status: 400 });
  }
  if (!Number.isInteger(score) || score < 1 || score > 5) {
    return NextResponse.json({ error: "Preference score must be an integer from 1 to 5" }, { status: 400 });
  }
  if (!Number.isFinite(budgetLimit) || budgetLimit < 0) {
    return NextResponse.json({ error: "Budget limit must be a non-negative number" }, { status: 400 });
  }
  if (!ALLOWED_PACES.includes(pace as (typeof ALLOWED_PACES)[number])) {
    return NextResponse.json({ error: "Pace must be RELAXED, BALANCED or FAST" }, { status: 400 });
  }

  try {
    await sql`
      INSERT INTO user_preference (user_id, category_id, preference_score, budget_limit, pace)
      VALUES (${user.user_id}, ${categoryId}, ${score}, ${budgetLimit}, ${pace})
      ON CONFLICT (user_id, category_id)
      DO UPDATE SET
        preference_score = EXCLUDED.preference_score,
        budget_limit = EXCLUDED.budget_limit,
        pace = EXCLUDED.pace
    `;
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ error: "Could not save preference. Check that the category exists." }, { status: 400 });
  }
}
