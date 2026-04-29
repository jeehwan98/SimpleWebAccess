"use client";

import { useEffect, useState } from "react";

interface Contact {
  name: string;
  email: string;
  message: string;
}

function ContactCard({ contact }: { contact: Contact }) {
  return (
    <div className="bg-white rounded-xl px-6 py-5 mb-4 shadow-sm">
      <p className="text-base font-semibold text-gray-900 mb-1">{contact.name}</p>
      <p className="text-xs text-gray-400 mb-3">{contact.email}</p>
      <p className="text-sm text-gray-600 leading-relaxed">{contact.message}</p>
    </div>
  );
}

export default function Contacts() {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [loading, setLoading] = useState(true);

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
    <main className="min-h-screen bg-gray-100 flex justify-center px-5 py-16 font-sans">
      <div className="w-full max-w-xl">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Submissions</h1>
        <p className="text-sm text-gray-500 mb-8">Contact form submissions.</p>

        {loading && <p className="text-sm text-gray-400">Loading...</p>}
        {!loading && contacts.length === 0 && (
          <p className="text-sm text-gray-400">No submissions yet.</p>
        )}

        {contacts.map((c, i) => (
          <ContactCard key={i} contact={c} />
        ))}
      </div>
    </main>
  );
}
