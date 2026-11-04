import "./globals.css";

export const metadata = { title: "Social Travel Planner", description: "DBMS mini project" };

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
