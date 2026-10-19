import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

// In development the API runs on :8000; /api is proxied so the browser sees one origin.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: { "/api": "http://localhost:8000" },
  },
});
