---
name: decision
description: Record a non-obvious technical choice in docs/registry/DECISIONS.md with the alternatives that were rejected and why. Use when the user types /genesis:decision, says "log this decision", or right after choosing between real alternatives (library, pattern, schema, process model) in a GENESIS project.
---

# /genesis:decision — Record a Decision

Append one entry to `docs/registry/DECISIONS.md`. The file is append-only:
never edit or delete existing entries. A reversed decision gets a new entry
that supersedes and links back to the old one.

## Steps

1. Identify the decision from the argument or the immediate conversation
   context.
2. Write the entry in the file's format:
   - `## YYYY-MM-DD — <decision title>` (today's real date)
   - **Decision:** what was chosen.
   - **Context:** the constraint or problem that forced a choice.
   - **Alternatives rejected:** each one with the specific reason it lost.
     This field is the whole point — a decision without rejected alternatives
     is just a fact. If the conversation does not contain the alternatives,
     ask for them or reconstruct them honestly and say so.
   - **Consequences:** what this commits the project to.
3. Append and confirm in one line.

If the file does not exist, create it from the plugin's
`templates/registry/DECISIONS.md` (at `../../templates/registry/` from this
skill's base directory) and register it in FILES.md (G1).

Quality bar: the entry must answer a future "why didn't they just do X?"
without the author present.
