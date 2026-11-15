# Community screen references

Retrieved from Stitch project `16268822272953913410` on 2026-11-15 using
the connected Stitch MCP download tool. Original HTML and PNG screenshots
are retained as design references, not shipped application assets.

| Screen | Filename stem |
|---|---|
| Community feed | `82978c03ba2c4de2863bb231ace87b7a` |
| Share question | `af86921184e049e98afd81bf1487c15e` |
| Discussion | `f8a2b7ec4cbd48c185bfc304c2a67e08` |
| Community profile | `b9b63173e4db485699f145de6f073d44` |
| Share PDF notes | `bf85cf4df1b54e569db4b6f91638227a` |
| Activity log | `e903eaed40fb40549dd41c483cc7e190` |

Open Home → Preview community, then New Post, or the profile avatar →
Activity log. All content uses the local in-memory repository. Publishing,
votes, bookmarks, subject and profile filters, and activity categories operate
locally. Files, search, notifications, comments, and sharing integrations remain
explicitly unavailable. No live services or uploads were added.

The implementation follows DESIGN.md: English copy, solid surfaces, shared
AppCard/AppButton/AppText components, Phosphor icons, responsive wrapping,
48dp segmented controls, and public-profile privacy copy. Generated upload
verification claims are replaced with sample-document wording.

Regression tests cover initial loading, all six screen designs at 390dp and
320dp with enlarged text, form validation, publishing each post type, activity
creation, filtering, stale feed responses, retry, and closure during requests.
Physical-device profiling, release smoke checks, and live integrations remain
unverified.
