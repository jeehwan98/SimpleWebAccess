"use client";

import { useEffect, useState } from "react";

interface Contact {
  name: string;
  email: string;
  message: string;
}

export default function Contacts() {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    fetch("/api/contacts")
      .then((res) => res.json())
      .then((data) => {
        setContacts(data);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  return (
    <main style={{
      minHeight: "100vh",
      background: "#f5f5f5",
      display: "flex",
      justifyContent: "center",
      fontFamily: "'Segoe UI', sans-serif",
      padding: "60px 20px",
    }}>
      <div style={{ width: "100%", maxWidth: 640 }}>
        <h1 style={{ fontSize: 28, color: "#1a1a2e", marginBottom: 8 }}>Submissions</h1>
        <p style={{ color: "#666", fontSize: 15, marginBottom: 32 }}>
          Contact form submissions saved in S3.
        </p>

        {loading && <p style={{ color: "#888" }}>Loading...</p>}
        {!loading && contacts.length === 0 && (
          <p style={{ color: "#888" }}>No submissions yet.</p>
        )}

        {contacts.map((c, i) => (
          <div key={i} style={{
            background: "white",
            borderRadius: 12,
            padding: "20px 24px",
            marginBottom: 16,
            boxShadow: "0 2px 12px rgba(0,0,0,0.06)",
          }}>
            <p style={{ margin: "0 0 6px", fontSize: 16, fontWeight: 600, color: "#1a1a2e" }}>{c.name}</p>
            <p style={{ margin: "0 0 10px", fontSize: 13, color: "#888" }}>{c.email}</p>
            <p style={{ margin: 0, fontSize: 14, color: "#444", lineHeight: 1.6 }}>{c.message}</p>
          </div>
        ))}
      </div>
    </main>
  );
}
