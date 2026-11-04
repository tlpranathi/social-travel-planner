"use client";
import Link from "next/link";
import { useRouter } from "next/navigation";
export default function Nav({name,role}:{name:string;role:string}){const router=useRouter(); return <nav><Link href="/">Dashboard</Link><Link href="/explore">Explore</Link><Link href="/trips">My trips</Link>{role==="ADMIN"&&<Link href="/admin">Admin</Link>}<span>{name} · {role}</span><button onClick={async()=>{await fetch("/api/auth/logout",{method:"POST"});router.push("/login")}}>Sign out</button></nav>}
