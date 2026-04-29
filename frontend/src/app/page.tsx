"use client";

import { useState } from "react";

type FormState = { name: string; email: string; message: string };
type Status = "idle" | "loading" | "success" | "error";

const inputClass =
  "w-full px-3.5 py-3 border border-gray-200 rounded-lg text-sm text-gray-700 outline-none focus:border-gray-400 focus:ring-1 focus:ring-gray-400 transition";

function FormField({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block mb-1.5 text-xs font-semibold text-gray-500 uppercase tracking-wide">
        {label}
      </label>
      {children}
    </div>
  );
}

export default function Home() {
  const [form, setForm] = useState<FormState>({ name: "", email: "", message: "" });
  const [status, setStatus] = useState<Status>("idle");
  const [pingResponse, setPingResponse] = useState<string | null>(null);

  const handlePing = async () => {
    setPingResponse("Loading...");
    try {
      const res = await fetch("/api/hello");
      setPingResponse(await res.text());
    } catch {
      setPingResponse("Failed to reach backend.");
    }
  };

  const handleSubmit = async (e: React.SyntheticEvent<HTMLFormElement>) => {
    e.preventDefault();
    setStatus("loading");
    try {
      const res = await fetch("/api/contacts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      if (res.ok) {
        setStatus("success");
        setForm({ name: "", email: "", message: "" });
      } else {
        setStatus("error");
      }
    } catch {
      setStatus("error");
    }
  };

  return (
    <main className="min-h-screen bg-gray-100 flex flex-col items-center justify-center px-5 py-10 font-sans">
      <div className="mb-4 flex items-center gap-3">
        <button
          onClick={handlePing}
          className="px-5 py-2.5 bg-black text-white text-sm font-semibold rounded-lg hover:bg-gray-800 transition cursor-pointer"
        >
          Get a Response
        </button>
        {pingResponse && <span className="text-sm text-gray-500">{pingResponse}</span>}
      </div>

      <div className="bg-white rounded-2xl px-10 py-12 w-full max-w-md shadow-2xl">
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Get in Touch</h1>
        <p className="text-sm text-gray-500 mb-8">
          Fill out the form below and we&apos;ll get back to you.
        </p>

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <FormField label="Name">
            <input
              type="text"
              placeholder="Your name"
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              required
              className={inputClass}
            />
          </FormField>

          <FormField label="Email">
            <input
              type="email"
              placeholder="your@email.com"
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              required
              className={inputClass}
            />
          </FormField>

          <FormField label="Message">
            <textarea
              placeholder="Write your message..."
              value={form.message}
              onChange={(e) => setForm({ ...form, message: e.target.value })}
              required
              rows={4}
              className={`${inputClass} resize-y`}
            />
          </FormField>

          <button
            type="submit"
            disabled={status === "loading"}
            className="mt-2 py-3.5 bg-black text-white text-base font-semibold rounded-lg hover:bg-gray-800 disabled:opacity-60 disabled:cursor-not-allowed transition cursor-pointer"
          >
            {status === "loading" ? "Sending..." : "Send Message"}
          </button>
        </form>

        {status === "success" && (
          <div className="mt-5 px-4 py-3 bg-green-50 rounded-lg text-green-700 font-medium text-sm">
            Message sent successfully!
          </div>
        )}
        {status === "error" && (
          <div className="mt-5 px-4 py-3 bg-red-50 rounded-lg text-red-600 font-medium text-sm">
            Something went wrong. Please try again.
          </div>
        )}
      </div>
    </main>
  );
}
