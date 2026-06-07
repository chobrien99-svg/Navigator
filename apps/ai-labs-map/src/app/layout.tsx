import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "France's 81 AI Research Laboratories",
  description:
    "An interactive map of public and private AI research labs in France, built from MESR open data by French Tech Journal.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body style={{ margin: 0, padding: 0, height: "100vh", width: "100vw" }}>
        {children}
      </body>
    </html>
  );
}
