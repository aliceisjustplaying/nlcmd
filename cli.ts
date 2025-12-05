import { createAnthropic } from "@ai-sdk/anthropic";
import { streamText } from "ai";

const anthropic = createAnthropic({
  ...(process.env.ANTHROPIC_BASE_URL && { baseURL: process.env.ANTHROPIC_BASE_URL }),
});

const input = await Bun.stdin.text();

const { textStream } = streamText({
  model: anthropic("claude-haiku-4-5-20251001"),
  system: "Convert to shell command. Output ONLY the raw command. No markdown, no code fences, no explanation.",
  prompt: input.trim(),
  onError({ error }: { error: any }) {
    const msg = error.statusCode === 401 ? "Invalid API key"
      : error.message?.includes("API key") ? "Missing API key"
      : error.message || "Unknown error";
    console.log(`# Error: ${msg}`);
    process.exit(1);
  },
});

for await (const chunk of textStream) {
  await Bun.write(Bun.stdout, chunk);
}
