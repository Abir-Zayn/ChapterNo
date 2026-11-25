---
version: 1
name: "ChapterNo — Design System"
updated: 2026-11-12
---

# ChapterNo — Design System

Shared visual rules for all design and coding agents. Stitch contains evolving screen references, not final designs that must be copied exactly; engineering rules live in `AGENTS.md`; business rules live in `CHAPTERNO_PROJECT_GUIDE.md`.

## 1. Design References and Improvement Authority

- Use **Stitch MCP** to inspect the relevant screen's preview and available design/export details before implementation.
- Project: **ChapterNo SSC Learning App**, ID `16268822272953913410`.
- Project URL: https://stitch.google.com/u/4/projects/16268822272953913410
- **Stitch designs are work in progress.** Use them to understand intent and visual direction; improve their weaknesses rather than reproducing every detail.
- Follow the owner's latest feedback, business requirements, and this shared system when refining screens. Do not assume a generated screen is approved or complete.
- Within the requested task, improve hierarchy, spacing, alignment, content density, typography, component proportions, interactions, and responsive behavior when useful. Routine refinements do not require repeated approval.
- Preserve working behavior and unrelated screens. A necessary shared-component improvement should be checked across its affected usages; do not revert previous refinements.
- Keep ChapterNo's identity and product boundaries consistent. Ask before material changes to business rules, feature scope, or core navigation.
- For missing screens/states, derive a coherent solution from this system and related references; avoid unrelated generic templates.
- If Stitch MCP is unavailable, report the limitation and use available references without claiming live inspection.

## 2. Visual Direction

ChapterNo is a Bangladesh-first SSC learning companion for budget to midrange mobile devices. Keep the experience warm, calm, academic, readable, and focused on learning.

- Light-first; dark mode is secondary and uses shared semantic tokens.
- Solid surfaces, subtle borders, soft corners, and restrained elevation.
- **No glassmorphism, backdrop blur, decorative blur, or frosted panels.**
- Avoid heavy shadows, large decorative gradients, cluttered dashboards, and excessive illustrations.
- Use one clear primary action per section and concise supporting copy.

## 3. Color Tokens

| Token | Light | Dark |
|---|---|---|
| background | `#FCFCFB` | `#111113` |
| surface | `#FFFFFF` | `#18181B` |
| surface-alt | `#F7F7F5` | `#222226` |
| surface-sunken | `#F4F4F5` | `#27272A` |
| primary | `#FF5A5F` | `#FF6B70` |
| primary-pressed | `#FA4F54` | `#FF5A5F` |
| primary-soft | `#FFE9EA` | `#3A2426` |
| text-primary | `#18181B` | `#FAFAFA` |
| text-secondary | `#71717A` | `#D4D4D8` |
| text-muted | `#A1A1AA` | `#A1A1AA` |
| border | `#E4E4E7` | `#2F2F35` |

| Semantic role | Foreground/base | Soft background |
|---|---|---|
| success | `#16A34A` | `#DCFCE7` |
| warning | `#D97706` | `#FEF3C7` |
| error | `#DC2626` | `#FEE2E2` |
| info | `#2563EB` | `#DBEAFE` |

- Illustration accents: moss `#708D81`, amber `#F4D35E`, clay `#D98363`. Use sparingly; never substitute them for action or correctness colors.
- Semantic colors above are light-theme defaults; adapt accessible pairs for dark mode.
- Check actual text/background contrast. White on brand coral and muted text on light surfaces are not automatically accessible. Use a centralized accessible foreground or approved darker action variant when needed.
- Never communicate correctness, selection, or availability through color alone.

## 4. Typography and Language

- **Current design phase: English only**, using Inter, weights 400/500/600/700.
- Keep strings localization-ready. Future Bangla uses Hind Siliguri with Noto Sans Bengali fallback.
- Do not mix locales, clip Bengali vowel marks, or apply letter spacing to Bengali script.
- Establish a clear hierarchy suited to the content. These semantic styles are starting values, not fixed requirements for every screen:

| Role | Size / weight |
|---|---|
| Hero | 28sp / 700 |
| Screen title | 24sp / 700 |
| Section title | 20sp / 600 |
| Card title | 18sp / 600 |
| Body / learning content | 16sp / 400 |
| Supporting text | 14sp / 400 |
| Control label | 14sp / 600 |
| Secondary caption | 12sp / 500 |

- Use comfortable line heights, approximately 1.4–1.6 for reading content.
- Support system text scaling. Do not shrink essential text to force a layout to fit.

## 5. Layout and Components

The dimensions below are **baseline tokens**, not mandatory measurements for every component or device. Refine them when the content, available space, or usability requires it; keep repeated patterns consistent through shared tokens/components.

- Spacing scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64dp.
- Default horizontal gutter: 20dp; 16dp on narrow layouts when needed.
- Section gaps: 24–32dp; card padding: 16–20dp.
- Radii: cards 16dp, featured cards 20dp, buttons/inputs 12dp, sheet top corners 24dp.
- Default border: 1dp. Use soft shadows only for genuinely floating elements.
- Minimum touch target: 48×48dp. Primary buttons generally start at 52dp high and grow when content/text scaling requires it.
- Use available layout constraints, flexible widths, content-driven heights, natural scrolling, safe areas, and keyboard insets. Never hard-code a screenshot-sized layout.
- Adapt gutters, arrangement, and grid columns for the available space. On larger displays, use sensible reading-width limits or additional columns; on smaller displays, reflow rather than shrinking the entire UI.
- Verify small/large phones, supported tablets, landscape, and enlarged text. Keep touch targets accessible and avoid arbitrary proportional scaling of all fonts/icons/spacing.
- Root navigation remains **Home, Practice, Community, Profile**. AI is contextual, not a fifth tab. Refine nested navigation for clarity without silently changing product flows.
- Prefer reusable buttons, fields, cards, headers, selectors, sheets, and feedback components. Improve unsuitable shared components rather than preserving their defects or duplicating them.
- Extract meaningful widget sections; keep pages focused on composition. Follow `AGENTS.md` for architecture, file splitting, imports, and size limits.
- Define applicable default, pressed, focused, selected, disabled, loading, success, and error states. Include useful empty/offline/retry states where needed.

## 6. Icons, Motion, and Accessibility

- Use **Phosphor** icons consistently: regular by default, filled for selected navigation when appropriate; typical size 20–24dp.
- Use original or rights-cleared educational assets. Avoid unnecessary stock imagery.
- Keep motion functional: about 150–250ms for interactions and 250–400ms for transitions. Respect reduced motion; avoid continuous decoration.
- Text contrast: at least 4.5:1 for normal text and 3:1 for large text.
- Provide semantic labels, logical reading order, visible focus/selection, and text/icon feedback beyond color.
- Check long questions, formulas, large text, and narrow layouts for overflow and truncation.

## 7. Trust and Delivery

- Stitch sample names, statistics, prices, quotas, coin amounts, and generated benefits are fixtures, not approved production rules.
- Show real state honestly; do not fabricate progress, endorsements, AI accuracy, processing estimates, or purchase success.
- Label AI feedback and estimated marks appropriately. Keep student uploads and private content private by default.
- Preserve entered work during recoverable errors; explain what is saved and offer a clear next action.
- Translate Stitch references into reusable Flutter components and centralized theme tokens; exported code is not automatically production-ready.
- Evaluate the result against the student's task, latest owner feedback, consistency, accessibility, and responsive usability—not pixel similarity alone. Inspect the rendered UI and briefly explain meaningful departures from Stitch.
- Follow `AGENTS.md` for tests, lifecycle cleanup, and real-device performance checks; report anything unverified.
