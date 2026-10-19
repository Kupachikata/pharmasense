import { z } from "zod";

const healthSchema = z.object({
  status: z.literal("ok"),
  database: z.literal("ok"),
  version: z.string(),
});

export type Health = z.infer<typeof healthSchema>;

export type HealthState =
  | { kind: "loading" }
  | { kind: "ok"; health: Health }
  | { kind: "down"; detail: string };

/** Interprets a /api/v1/health response; non-2xx bodies are RFC 9457 problem details. */
export function readHealth(status: number, body: unknown): HealthState {
  if (status >= 200 && status < 300) {
    const parsed = healthSchema.safeParse(body);
    return parsed.success
      ? { kind: "ok", health: parsed.data }
      : { kind: "down", detail: "Unexpected health response" };
  }
  const detail = z.object({ detail: z.string() }).safeParse(body);
  return { kind: "down", detail: detail.success ? detail.data.detail : `HTTP ${status}` };
}

export async function fetchHealth(): Promise<HealthState> {
  try {
    const response = await fetch("/api/v1/health");
    return readHealth(response.status, await response.json());
  } catch {
    return { kind: "down", detail: "API unreachable" };
  }
}
