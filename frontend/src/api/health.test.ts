import { describe, expect, it } from "vitest";

import { readHealth } from "./health";

describe("readHealth", () => {
  it("accepts a healthy response", () => {
    expect(readHealth(200, { status: "ok", database: "ok", version: "0.1.0" })).toEqual({
      kind: "ok",
      health: { status: "ok", database: "ok", version: "0.1.0" },
    });
  });

  it("reports the problem-details detail when the API is degraded", () => {
    expect(readHealth(503, { status: 503, detail: "Database is unreachable" })).toEqual({
      kind: "down",
      detail: "Database is unreachable",
    });
  });

  it("rejects a 200 with an unexpected body", () => {
    expect(readHealth(200, { status: "maybe" }).kind).toBe("down");
  });
});
