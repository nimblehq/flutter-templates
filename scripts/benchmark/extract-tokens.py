#!/usr/bin/env python3
"""
Sum token usage from Claude Code session JSONLs for a given worktree.

Usage:
    python3 extract-tokens.py <case_name> <worktree_abs_path>

Output (one CSV row to stdout):
    case,input,output,cache_create,cache_read,total,cost_usd

The encoded project dir is computed from worktree_abs_path:
    /Users/khanh/Desktop/Code/bench-opus-baseline
        -> ~/.claude/projects/-Users-khanh-Desktop-Code-bench-opus-baseline/

Sums message.usage across every assistant message in every JSONL in that dir.
This matches the totals shown by `/cost` (including tool-call usage and any
mid-session compaction overhead — which IS the real cost paid).

Pricing constants below are Claude Opus 4.7 public list prices. Override via
env vars OPUS_IN / OPUS_OUT / OPUS_CW / OPUS_CR ($ per million tokens).
"""
import json
import os
import sys
from pathlib import Path

# Per-million-token list prices for Claude Opus 4.7. Override via env if stale.
# Source: https://platform.claude.com/docs/en/about-claude/pricing
# Note: Claude Code defaults to 1-hour cache writes (ephemeral_1h_input_tokens),
# priced at 2x base input. We split 1h vs 5m and price each correctly.
PRICE_INPUT          = float(os.environ.get("OPUS_IN",   "5.00"))
PRICE_OUTPUT         = float(os.environ.get("OPUS_OUT",  "25.00"))
PRICE_CACHE_WRITE_5M = float(os.environ.get("OPUS_CW5",  "6.25"))   # 1.25x input
PRICE_CACHE_WRITE_1H = float(os.environ.get("OPUS_CW1H", "10.00"))  # 2.00x input
PRICE_CACHE_READ     = float(os.environ.get("OPUS_CR",   "0.50"))   # 0.10x input


def encode_cwd(abs_path: str) -> str:
    # Claude Code stores logs at ~/.claude/projects/<cwd-with-/-as-->/
    return abs_path.replace("/", "-")


def sum_session_tokens(project_dir: Path) -> dict:
    """Sum usage across assistant messages, deduplicating by message.id.

    Claude Code occasionally writes the same assistant message to the JSONL
    twice (likely a streaming-preview + final-accumulated artifact). All
    observed duplicates have identical usage objects, so deduping by id is
    safe and required for the totals to match Anthropic's /cost output.
    """
    totals = {"input": 0, "output": 0, "cw_5m": 0, "cw_1h": 0, "cache_read": 0}
    if not project_dir.exists():
        return totals

    seen_ids: set[str] = set()
    for jsonl in sorted(project_dir.glob("*.jsonl")):
        with jsonl.open() as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    rec = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if rec.get("type") != "assistant":
                    continue
                msg = rec.get("message") or {}
                msg_id = msg.get("id")
                if msg_id and msg_id in seen_ids:
                    continue
                if msg_id:
                    seen_ids.add(msg_id)
                usage = msg.get("usage")
                if not usage:
                    continue
                totals["input"]      += usage.get("input_tokens", 0)
                totals["output"]     += usage.get("output_tokens", 0)
                totals["cache_read"] += usage.get("cache_read_input_tokens", 0)
                cc = usage.get("cache_creation") or {}
                totals["cw_5m"] += cc.get("ephemeral_5m_input_tokens", 0)
                totals["cw_1h"] += cc.get("ephemeral_1h_input_tokens", 0)
    return totals


def estimate_cost(t: dict) -> float:
    return (
        t["input"]      * PRICE_INPUT          / 1_000_000
        + t["output"]   * PRICE_OUTPUT         / 1_000_000
        + t["cw_5m"]    * PRICE_CACHE_WRITE_5M / 1_000_000
        + t["cw_1h"]    * PRICE_CACHE_WRITE_1H / 1_000_000
        + t["cache_read"] * PRICE_CACHE_READ   / 1_000_000
    )


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("usage: extract-tokens.py <case_name> <worktree_abs_path>\n")
        sys.exit(2)

    case = sys.argv[1]
    worktree = sys.argv[2].rstrip("/")
    project_dir = Path.home() / ".claude" / "projects" / encode_cwd(worktree)

    t = sum_session_tokens(project_dir)
    total = sum(t.values())
    cost = estimate_cost(t)

    cache_create = t["cw_5m"] + t["cw_1h"]
    print(f"{case},{t['input']},{t['output']},{cache_create},{t['cache_read']},{total},{cost:.4f}")


if __name__ == "__main__":
    main()
