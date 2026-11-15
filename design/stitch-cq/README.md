# CQ screen references

Source: Stitch project `16268822272953913410`, retrieved 2026-11-15 using the
connected Stitch MCP server. Each screen has its original HTML export and
screenshot saved alongside this file. These are design references, not app assets.

| Screen | Export filename stem |
|---|---|
| Timed CQ examination | `036f9607cb8442e2a3a9c7c861791a5c` |
| Submit answer sheets | `a8ba31d033fb435d8af3eaf61df51dcd` |
| Submission and AI processing | `5380fcad304440829a5c5d2b589bd280` |
| Review and organize pages | `590ccc0f72a04353b083cc0abcc31f93` |

The Flutter preview is available at `/practice/cq` and through the Home
placeholder's **Preview CQ examination** button. It reuses AppCard, AppButton,
the application theme, and Phosphor icons. No dependencies were added.

The implementation follows DESIGN.md over inconsistent generated HTML:
English text, solid surfaces, responsive reading width, no blur, and explicit
mock status. The exam timer runs locally and is disposed when leaving. Sample
pages can be added, rotated, removed, reassigned, and moved earlier. Submission
freezes editing; evaluation progress advances manually. Camera, gallery,
crop, notifications, persistence, and actual AI evaluation are not connected.

All session data is disposable. The exported HTML may contain external resource
links and generated sample claims; it is retained unmodified as reference only.
