import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
    },
    alias: {
      "@": "/mnt/ai-knowledge/workspaces/flow-social/NoteAgents/packages",
      "~": "/mnt/ai-knowledge/workspaces/flow-social/NoteAgents/apps",
    },
  },
});