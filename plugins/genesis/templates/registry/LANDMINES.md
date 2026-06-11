# LANDMINES.md — Things That Will Trip You Up

The highest value-per-line file in the project. **G5: every gotcha discovered
the hard way goes here immediately, while the pain is fresh.** If you spent more
than ten minutes confused by something the code could not tell you, it belongs
here.

Qualifying categories: inverted or surprising semantics, false-looking code that
is actually correct, magic constants with non-obvious sources, ordering
requirements, environment quirks, third-party API lies, anything intentionally
hidden or disabled.

Format: bold one-line trap, then the explanation and the rule for handling it.
Cite files.

---

**<The trap in one bold sentence.>**
Why it is this way, what breaks if you assume otherwise, and the rule:
always/never do X. See `path/to/file.ext`.
