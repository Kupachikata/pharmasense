import { useEffect, useState } from "react";

import { fetchHealth, type HealthState } from "./api/health";

// Navigation groups follow Section 4.6 of the specification; screens arrive milestone by milestone.
const NAV_GROUPS = [
  { title: "Dispensing", items: ["Point of sale", "Patients"] },
  { title: "Supply", items: ["Inventory and batches", "Stocktake", "Purchase orders", "Transfers"] },
  { title: "Intelligence", items: ["Dashboard", "Demand forecast", "Smart reports", "Interaction rules"] },
];

function StatusBadge({ state }: { state: HealthState }) {
  if (state.kind === "loading") return <span className="badge">Checking…</span>;
  if (state.kind === "ok") return <span className="badge ok">Online · API {state.health.version}</span>;
  return <span className="badge down">Offline · {state.detail}</span>;
}

export function App() {
  const [health, setHealth] = useState<HealthState>({ kind: "loading" });

  useEffect(() => {
    void fetchHealth().then(setHealth);
  }, []);

  return (
    <div className="shell">
      <nav className="sidebar" aria-label="Main">
        <h1>PharmaSense</h1>
        {NAV_GROUPS.map((group) => (
          <section key={group.title}>
            <h2>{group.title}</h2>
            <ul>
              {group.items.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </section>
        ))}
      </nav>
      <main>
        <header>
          <StatusBadge state={health} />
        </header>
        <p>Scaffold (milestone M0). Screens are added from milestone M2.</p>
      </main>
    </div>
  );
}
