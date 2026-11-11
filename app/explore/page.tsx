import { sql } from "@/lib/db";
import { currentUser } from "@/lib/auth";
import { redirect } from "next/navigation";
import Nav from "@/components/Nav";
import { VoteButton } from "@/components/Forms";
import { queryEmbedding } from "@/lib/semantic";
export const dynamic = "force-dynamic";
export default async function Explore({
  searchParams,
}: {
  searchParams: {
    q?: string;
    category?: string;
    max?: string;
    outdoor?: string;
    semantic?: string;
  };
}) {
  const u = await currentUser();
  if (!u) redirect("/login");
  const q = searchParams.q || "";
  const category = searchParams.category || "All";
  const max = Number(searchParams.max || 100000);
  const outdoor = searchParams.outdoor === "yes";
  const semantic = searchParams.semantic === "yes" && q.trim().length > 0;
  const vector = queryEmbedding(q);
  const categories =
    await sql`SELECT category_name FROM category ORDER BY category_name`;
  const rows = semantic
    ? await sql`SELECT a.attraction_id,a.name,a.description,a.cost,a.estimated_minutes,a.outdoor_flag,c.category_name,(a.embedding <-> ${vector}::vector)::numeric(4,2) distance FROM attraction a JOIN category c ON c.category_id=a.category_id WHERE a.cost<=${max} ORDER BY a.embedding <-> ${vector}::vector`
    : await sql`SELECT a.attraction_id,a.name,a.description,a.cost,a.estimated_minutes,a.outdoor_flag,c.category_name,NULL::numeric distance FROM attraction a JOIN category c ON c.category_id=a.category_id WHERE (${category}='All' OR c.category_name=${category}) AND a.cost<=${max} AND (${outdoor}=false OR a.outdoor_flag=true) AND (${q}='' OR a.name ILIKE ${"%" + q + "%"} OR a.description ILIKE ${"%" + q + "%"}) ORDER BY a.name`;
  return (
    <main>
      <Nav name={u.name} role={u.role} />
      <h1>Explore attractions</h1>
      <form className="controls">
        <input
          name="q"
          defaultValue={q}
          placeholder="Try peaceful beach, historic church, seafood..."
        />
        <select name="category" defaultValue={category}>
          <option>All</option>
          {categories.map((c: any) => (
            <option key={c.category_name}>{c.category_name}</option>
          ))}
        </select>
        <input
          name="max"
          type="number"
          defaultValue={max}
          placeholder="Maximum cost"
        />
        <label>
          <input
            name="outdoor"
            type="checkbox"
            value="yes"
            defaultChecked={outdoor}
          />{" "}
          Outdoor only
        </label>
        <button>Filter</button>
        <button name="semantic" value="yes">
          Semantic search
        </button>
      </form>
      {searchParams.semantic === "yes" && !semantic && (
        <p className="notice">
          Enter a natural-language request before using semantic search.
        </p>
      )}
      {semantic && (
        <p className="muted">
          Semantic results for “{q}” using derived vector {vector}.
        </p>
      )}
      <table>
        <thead>
          <tr>
            <th>Place</th>
            <th>Details</th>
            <th>Cost</th>
            <th>Duration</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((a: any) => (
            <tr key={a.attraction_id}>
              <td>
                <strong>{a.name}</strong>
                <br />
                <span className="pill">{a.category_name}</span>
              </td>
              <td>
                {a.description}
                {a.distance !== null && (
                  <small> · semantic distance {a.distance}</small>
                )}
              </td>
              <td>₹{a.cost}</td>
              <td>{a.estimated_minutes} min</td>
              <td>
                <VoteButton attractionId={a.attraction_id} tripId={1} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
