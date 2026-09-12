# Contributing

Aurora is a fork of [CanvasMC](https://github.com/CraftCanvasMC/Canvas). Before
you open anything here, work out which project the change belongs to.

**If it is a server behaviour, a crash, or a performance problem**, it is almost
certainly upstream. Reproduce it on a stock CanvasMC jar first. If it reproduces,
report it to CanvasMC — they will fix it for everyone, and Aurora picks the fix up
on the next upstream merge. Note that CanvasMC has its own
[AI policy](https://github.com/CraftCanvasMC/Canvas/blob/HEAD/AI_POLICY.md) for
issues and pull requests; read it before you file anything there.

**If it is Aurora's own branding, build, or documentation**, it belongs here.

## Working on the source

```bash
./gradlew applyAllPatches               # reconstruct the source
./gradlew :aurora-server:createPaperclipJar
./gradlew rebuildAllServerPatches       # turn your edits back into patch files
```

Commit the rebuilt patch files, not the generated trees — `paper-server/`,
`paper-api/` and `aurora-server/src/minecraft/` are all ignored.

Two things that will waste your afternoon if you do not know them:

- The Weaver fork name in `aurora-server/build.gradle.kts.patch` decides where the
  *minecraft* patch directories are looked up. Rename the module directory without
  renaming the fork and the build silently applies zero minecraft patches.
- Editing a `.patch` file by hand is fine as long as you only substitute within a
  line. Add or remove a line and the hunk header stops matching.
