import { createAnthropic } from "@ai-sdk/anthropic";
import { streamText } from "ai";

const anthropic = createAnthropic({
  baseURL: "http://localhost:4001/v1",
});

const input = await Bun.stdin.text();

const { textStream } = streamText({
  model: anthropic("claude-haiku-4-5-20251001"),
  system: "Convert to shell command. Output ONLY the raw command. No markdown, no code fences, no explanation.",
  prompt: input.trim(),
});

for await (const chunk of textStream) {
  await Bun.write(Bun.stdout, chunk);
}
