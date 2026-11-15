Repairs the Community feature so the feed, profile, and activity log load instead of remaining on their initial spinner. Completes the Discussion, Share Question, and PDF Notes forms using the existing local repository and ChapterNo components.

- Fixes dependency paths, missing exports, typed profile loading, stale feed responses, and recoverable empty subject filters.
- Makes cards and form controls usable at 320dp with enlarged text; restores profile contribution stats and the header-before-tabs layout.
- Keeps publishing, voting, saving, and activity updates local. External uploads, PDFs, comments, notifications, and sharing remain explicitly unavailable.
- Includes all six original Stitch HTML and image references.

Validation of the isolated staged PR snapshot: formatting clean, flutter analyze reports zero issues, and all 77 tests pass. The wider working tree also passes all 84 tests. Physical-device profiling and release smoke testing were not performed.

This branch builds on the already committed profile prerequisite 74b128f, which is not yet on the remote feat/auth-screen branch; that prerequisite therefore appears in this PR's history and diff. Unrelated pending CQ, ranked-quiz, AGENTS.md, and tooling changes are excluded from the Community commit.