# Aurora

Aurora is Atlas Studio's regionised Minecraft server. It is a fork of
[CanvasMC](https://github.com/CraftCanvasMC/Canvas), which is a fork of Folia,
which is a fork of Paper.

Minecraft **26.2** · Java **25+** · GPL-3.0

---

## Read this before you install it

Aurora inherits Folia's **region threading**, and that changes what a plugin is
allowed to do. A plugin only loads if its `plugin.yml` declares one of:

```yaml
folia-supported: true
# or
canvas-supported: true
```

Most plugins declare neither, and Aurora will refuse to load them. This is not a
setting you can turn off — the threading model is the reason the check exists. If
you are running a large plugin list, check every one of them before you switch,
or stay on a Paper-family jar.

Region threading also pays off in proportion to how many CPU cores you can give
it. On a small or old machine with few cores it costs memory and gives little
back.

## What Aurora changes

Right now: the branding, and nothing else. Aurora is CanvasMC with Atlas Studio's
identity on it —

| | |
|---|---|
| Server brand (F3, `/version`, client brand packet) | `Aurora`, `atlasstudiomc:aurora` |
| Command | `/aurora` (permissions `aurora.command.*`) |
| Config files | `config/aurora-server.yml`, `config/aurora-worlds.yml`, `aurora-patch.yml` |
| Jar | `aurora-paperclip-<version>.jar` |
| bStats | reports as `Aurora` |

Every performance characteristic you measure is CanvasMC's work, not ours. When
that stops being true, this section will say so — with numbers and the hardware
they came from.

## Building

```bash
./gradlew applyAllPatches
./gradlew :aurora-server:createPaperclipJar
```

The jar lands in `aurora-server/build/libs/`. You need Java 25 and a real git
clone — a downloaded zip will not build.

`scripts/rebrand-from-canvas.sh` is the exact transformation that turns an
upstream CanvasMC checkout into this one. It is checked in so the fork can be
reproduced, and so a future upstream merge can be re-branded the same way.

## Configuration

Aurora's options are CanvasMC's options under different file names, so
[docs.canvasmc.io](https://docs.canvasmc.io/canvas/introduction/) is the
reference for what each one does.

## Upstream

Aurora exists because of work we did not do. In order:

- [CanvasMC](https://github.com/CraftCanvasMC/Canvas) — region-threading fixes and
  the performance work this fork is built on
- [Folia](https://github.com/PaperMC/Folia) — regionised multithreading
- [Paper](https://github.com/PaperMC/Paper) — the server this all descends from

Patch attribution comments in this repository still read `// Canvas - ...` where
CanvasMC wrote the code. That is deliberate; the credit travels with the code.

Please do not report Aurora bugs to CanvasMC, Folia or Paper. Open them
[here](https://github.com/AtlasStudioMC/Aurora/issues) instead.

## Licence

GPL-3.0, the same as CanvasMC. See [LICENSE](LICENSE).
