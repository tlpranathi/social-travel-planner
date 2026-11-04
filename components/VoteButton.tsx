"use client";
import { useState } from "react";
export default function VoteButton({ attractionId }: { attractionId: number }) {
  const [message, setMessage] = useState("");
  async function vote(value: number) { const r = await fetch("/api/votes", { method:"POST", headers:{"Content-Type":"application/json"}, body:JSON.stringify({ attractionId, value }) }); setMessage(r.ok ? "Saved" : "Already voted"); }
  return <><button onClick={() => vote(1)}>Vote +</button>{message && <small> {message}</small>}</>;
}
