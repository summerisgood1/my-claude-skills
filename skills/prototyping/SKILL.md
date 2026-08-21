---
name: prototyping
description: Use when building or changing a UI prototype that must look exactly like a real app but run with no backend, no wallet, and no network — including where mock values belong, why copied files must not be edited, and how prototype work gets back into the real app.
---

# Prototyping against a mirror of the real app

## Overview

**The prototype is a mirror of the app, not a fork of it.**

Screens are not rebuilt to look like the app — real app source is copied in at the
same relative paths and runs unchanged. Fakery is injected underneath it: the
package layer and the network layer are swapped out, and every switchable value
lives in one state object.

This buys two things a hand-built prototype never gets: the fidelity is exact by
construction, and anything new you design here moves into the real app with `cp`
instead of a rewrite.

## Layout

```
<repo>/components/billing/PlanCard.tsx              ← real app
<repo>/apps/proto/src/components/billing/PlanCard.tsx  ← prototype's own copy
                            └──── same trailing path ────┘
```

Two independent files. The bundler aliases `@` to the prototype's own `src`, so
the prototype never reaches into the real app.

Because the trailing paths match, no manifest and no sync script are needed:
`diff` tells you if a copy has drifted, overwriting is the update, and `cp` in
the other direction is the graduation.

## Three kinds of files, three different rules

| Kind | Lives at | Rule |
|---|---|---|
| **Mirror** — copied app source | real app paths | Never edit. Change behaviour via a shim, an alias, or a knob. Drifted? Overwrite the whole file. |
| **New design** — the actual deliverable | real app paths | Write it here; this is why the prototype exists. One limit: it must not import the prototype's state module. |
| **Prototype tooling** | `proto/`, `shims/`, `fixtures/` | Never ships. Write whatever you like. |

The one limit on new design is what keeps it portable. A component that reads
prototype state is welded to the prototype and has to be rewritten later.

## Three layers of fake

| Layer | Intercepts at | Replaces |
|---|---|---|
| Mirror | — | nothing; it is real source |
| `shims/` | import (bundler alias) | npm packages (i18n, image, router, wallet, analytics) and the app's own data hooks |
| `fixtures/` | network (dev-server middleware) | `/api/*` responses, one JSON file per URL |

A shim returns the **same shape as the real module** so the components consuming
it need no changes.

## Where does this fake value go?

Take the first rung that holds:

1. **You want to click between states** → add a knob to the state module and a
   control to the toolbar
2. **Not clickable, just needs a number** → hardcode it inside the shim that
   already serves that data
3. **The component fetches `/api/...`** → add a fixture file
4. **You genuinely need to replace a whole module** → check whether an existing
   shim can cover it first. If not, add one: exact-match alias, one shim per
   module. Prefix-matched aliases collide (`useBalance` swallowing `useBalances`).

## Starting a feature

1. Pick the route; read the real app's page for it.
2. `diff` the files this feature touches against the real app. Overwrite what has
   drifted. Then start.
3. Write new UI at real app paths.
4. Add knobs plus a toolbar group so the states are demonstrable.
5. Leave unbuilt routes to the not-built placeholder.

```bash
# drifted?
diff <(git -C <app-repo> show main:components/billing/PlanCard.tsx) \
     apps/proto/src/components/billing/PlanCard.tsx

# refresh
git -C <app-repo> show main:components/billing/PlanCard.tsx \
  > apps/proto/src/components/billing/PlanCard.tsx
```

## Finishing: leave a graduation list

A prototype's output is a design **and** a handoff note. Before stopping, write down:

- which new files sit at which real app paths
- which shim stands in for which not-yet-built backend
- which knob corresponds to which real-world state

The session that later writes the implementation spec reads this instead of
re-deriving it.

Graduation itself does not happen here. When the backend is settled and real work
starts: `cp` to the real app (the path is already correct), then wire the real
hooks there. The prototype's copy stays for further iteration.

## Common mistakes

| Mistake | Why it hurts |
|---|---|
| Editing a copied file to make it behave | The next refresh silently reverts it. Change the shim or the knob instead. |
| Rebuilding an existing screen "to look like" the app | That is the drift you copied files to avoid. Only *new* design gets written by hand. |
| New component reads prototype state directly | Cannot graduate. Take data as props, or through the real hook's name. |
| A new npm dependency to help with mocking | The prototype has no backend by design; a shim is a file, not a library. |
| One shim serving several unrelated modules | Aliases collide and the fake data blurs. One shim, one module. |

## Red flags

- "I'll just tweak this copied component slightly."
- "Faster to write my own version of this screen."
- "I'll import the state module here, it's only for the demo."
- "I'll add a mock-data library."

All of these mean: stop, and put the change in a shim, a fixture, or a knob.
