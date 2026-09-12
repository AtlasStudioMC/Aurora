#!/usr/bin/env bash
#
# Rebrand an upstream CanvasMC checkout as Aurora (Atlas Studio).
#
# Run from the repository root. The transformation is deliberately narrow:
# it changes the things a server operator sees and nothing else.
#
#   changed : brand name/id, jar manifest, /aurora command, permission nodes,
#             config file names, bStats identity, Gradle project names, links
#   kept    : the io.canvasmc.canvas Java package, "// Canvas - " patch
#             attribution comments, the Weaver plugin id, maven.canvasmc.io
#
# The package stays because it is invisible to operators and renaming it would
# touch ~800 sites across 162 patch files, breaking every future upstream merge.
# The attribution comments stay because CanvasMC wrote that code and the GPL
# expects the credit to travel with it.
#
# Patch files are only ever edited by substitution within a line, never by
# adding or removing lines, so every hunk header stays valid.

set -euo pipefail

die() { echo "error: $*" >&2; exit 1; }
[[ -d .git ]] || die "run this from the repository root"

sub() { # sub <file> <perl-expr>
  local f=$1; shift
  [[ -f $f ]] || die "missing file: $f"
  perl -pi -e "$@" "$f"
}

count() { grep -rIoi 'canvas' "$@" 2>/dev/null | wc -l | tr -d ' '; }

echo "==> before: $(count . --exclude-dir=.git) case-insensitive 'canvas' occurrences"

# ---------------------------------------------------------------------------
# 1. Gradle project identity
# ---------------------------------------------------------------------------
echo "==> gradle project identity"

sub settings.gradle.kts 's/rootProject\.name = "Canvas"/rootProject.name = "Aurora"/'
sub settings.gradle.kts 's/listOf\("canvas-api", "canvas-server"\)/listOf("aurora-api", "aurora-server")/'
sub settings.gradle.kts 's/The Canvas project directory/The Aurora project directory/'
sub settings.gradle.kts 's/clone the Canvas repository/clone the Aurora repository/'
sub settings.gradle.kts 's/In order to build Canvas from source/In order to build Aurora from source/'
sub settings.gradle.kts 's|Built Canvas jars are available for download at|Aurora is built from source; see the README at|'
sub settings.gradle.kts 's|https://canvasmc.io/downloads|https://github.com/AtlasStudioMC/Aurora|'
sub settings.gradle.kts 's|https://github.com/CraftCanvasMC/Canvas/blob/HEAD/CONTRIBUTING.md|https://github.com/AtlasStudioMC/Aurora/blob/HEAD/README.md|'
sub settings.gradle.kts 's/for further information on building and modifying Canvas\./for further information on building and modifying Aurora./'
sub settings.gradle.kts 's/\bcanvasChannel\b/auroraChannel/g'
sub settings.gradle.kts 's/\bcanvasBuildNumber\b/auroraBuildNumber/g'

sub gradle.properties 's/^group = io\.canvasmc\.canvas$/group = io.atlasstudiomc.aurora/'

sub build.gradle.kts 's|file\("canvas-server/|file("aurora-server/|g'
sub build.gradle.kts 's|file\("canvas-api/|file("aurora-api/|g'
sub build.gradle.kts 's|outputFile = file\("canvas-server/build\.gradle\.kts"\)|outputFile = file("aurora-server/build.gradle.kts")|'
sub build.gradle.kts 's|outputFile = file\("canvas-api/build\.gradle\.kts"\)|outputFile = file("aurora-api/build.gradle.kts")|'
sub build.gradle.kts 's/rootProject\.projects\.canvasServer/rootProject.projects.auroraServer/'
sub build.gradle.kts 's/authors = listOf\("CanvasMC"\)/authors = listOf("Atlas Studio")/'

# ---------------------------------------------------------------------------
# 2. Module directories
# ---------------------------------------------------------------------------
echo "==> module directories"
[[ -d canvas-api    ]] && git mv canvas-api    aurora-api
[[ -d canvas-server ]] && git mv canvas-server aurora-server

# ---------------------------------------------------------------------------
# 3. Jar manifest — this is what ServerBuildInfoImpl reads first, so it is the
#    authoritative source of the F3 brand, /version and the client brand packet.
# ---------------------------------------------------------------------------
echo "==> jar manifest"
B=aurora-server/build.gradle.kts.patch

sub "$B" 's/val canvasContributors = listOf\(/val auroraContributors = listOf(/'
sub "$B" 's/"VeguiDev",/"Atlas Studio",/'
sub "$B" 's/"BaconCat1",/"CanvasMC (upstream)",/'
sub "$B" 's/"Euphillya",/"Folia (upstream)",/'
sub "$B" 's/"Jsinco",/"Paper (upstream)",/'
sub "$B" 's/"Biquaternions"/"Mojang"/'
sub "$B" 's/"Implementation-Title" to "Canvas"/"Implementation-Title" to "Aurora"/'
sub "$B" 's/"Specification-Title" to "Canvas"/"Specification-Title" to "Aurora"/'
sub "$B" 's/"Specification-Vendor" to "Canvas Team"/"Specification-Vendor" to "Atlas Studio"/'
sub "$B" 's/"Brand-Id" to "canvasmc:canvas"/"Brand-Id" to "atlasstudiomc:aurora"/'
sub "$B" 's/"Brand-Name" to "Canvas"/"Brand-Name" to "Aurora"/'
sub "$B" 's/"Brand-Vendor" to "Canvas Team"/"Brand-Vendor" to "Atlas Studio"/'
sub "$B" 's|"Brand-Website" to "https://canvasmc.io"|"Brand-Website" to "https://atlasstudio.c0m.to"|'
sub "$B" 's/"Contributors" to canvasContributors,/"Contributors" to auroraContributors,/'

# ---------------------------------------------------------------------------
# 4. Brand constants and bStats identity
# ---------------------------------------------------------------------------
echo "==> brand constants"
A=aurora-api/paper-patches/base/0001-Rebrand.patch
S=aurora-server/paper-patches/base/0001-Rebrand.patch

sub "$A" 's/Key BRAND_CANVAS_ID = Key\.key\("canvasmc", "canvas"\);/Key BRAND_CANVAS_ID = Key.key("atlasstudiomc", "aurora");/'
sub "$S" 's/private static final String BRAND_CANVAS_NAME = "Canvas";/private static final String BRAND_CANVAS_NAME = "Aurora";/'
sub "$S" 's/Key\.key\("canvasmc", "canvas"\)/Key.key("atlasstudiomc", "aurora")/'

# bStats: report as Aurora, not as Canvas. The service still has to be
# registered with bStats before the data lands anywhere useful.
sub "$S" 's/new Metrics\("Canvas", serverUUID/new Metrics("Aurora", serverUUID/'
sub "$S" 's/paperVersion = "Canvas-V3-" \+/paperVersion = "Aurora-" +/'
sub "$S" 's/new Metrics\.SimplePie\("canvas_version"/new Metrics.SimplePie("aurora_version"/'

# ---------------------------------------------------------------------------
# 5. The /canvas command becomes /aurora, with matching permission nodes
# ---------------------------------------------------------------------------
echo "==> commands and permissions"
M=aurora-server/minecraft-patches/base/0001-Rebrand.patch

sub "$M" 's/"canvas\.command\."/"aurora.command."/g'
sub "$M" 's/literal\("canvas"\)/literal("aurora")/'
sub "$M" 's/literal\("canvas:" \+ name\)/literal("aurora:" + name)/'
sub "$M" 's/performCommand\("canvas help"\)/performCommand("aurora help")/'
sub "$M" 's/"canvas-logo\.png"/"aurora-logo.png"/'

# The six links in /aurora about. Same count, same shape, real destinations.
sub "$M" 's|getLink\("Discord", "https://canvasmc.io/discord/", "Click to open the discord server invite"\)|getLink("Website", "https://atlasstudio.c0m.to/", "Click to open the Atlas Studio website")|'
sub "$M" 's|getLink\("Website", "https://canvasmc.io/", "Click to open our website"\)|getLink("Downloads", "https://atlasstudio.c0m.to/downloads", "Click to open the Aurora downloads page")|'
sub "$M" 's|getLink\("Source", "https://github.com/CraftCanvasMC/Canvas/", "Click to open the CanvasMC source repository"\)|getLink("Source", "https://github.com/AtlasStudioMC/Aurora/", "Click to open the Aurora source repository")|'
sub "$M" 's|getLink\("Issues", "https://github.com/CraftCanvasMC/Canvas/issues/", "Click to open our issues page on our repository"\)|getLink("Issues", "https://github.com/AtlasStudioMC/Aurora/issues/", "Click to open the Aurora issue tracker")|'
sub "$M" 's|getLink\("Docs", "https://docs.canvasmc.io/canvas/introduction/", "Click to open Canvas. documentation"\)|getLink("Config docs", "https://docs.canvasmc.io/canvas/introduction/", "Aurora inherits CanvasMC configuration; click for the upstream docs")|'
sub "$M" 's|getLink\("Modrinth", "https://modrinth.com/organization/canvasmc/", "Click to open Canvas. Modrinth org"\)|getLink("Upstream", "https://github.com/CraftCanvasMC/Canvas/", "Aurora is a fork of CanvasMC; click to open upstream")|'

# ---------------------------------------------------------------------------
# 6. Configuration file names (plain sources, not patches)
# ---------------------------------------------------------------------------
echo "==> configuration file names"
while IFS= read -r f; do
  perl -pi -e '
    s{config/canvas-server\.yml}{config/aurora-server.yml}g;
    s{config/canvas-worlds\.yml}{config/aurora-worlds.yml}g;
    s{"canvas-server\.yml"}{"aurora-server.yml"}g;
    s{"canvas-worlds\.yml"}{"aurora-worlds.yml"}g;
    s{"canvas-patch\.yml"}{"aurora-patch.yml"}g;
    s{resolve\("canvas-patch\.yml"\)}{resolve("aurora-patch.yml")}g;
    s{/config/canvas-worlds\.yml}{/config/aurora-worlds.yml}g;
    s{/canvas reload}{/aurora reload}g;
    s{https://canvasmc\.io/discord}{https://atlasstudio.c0m.to}g;
  ' "$f"
done < <(grep -rIl 'canvas-server\.yml\|canvas-worlds\.yml\|canvas-patch\.yml\|/canvas reload\|canvasmc\.io/discord' aurora-server/src aurora-api 2>/dev/null || true)

# ---------------------------------------------------------------------------
# 7. Update checks. Aurora has no build API, so never ask CanvasMC's about a
#    build number that does not exist in their history.
# ---------------------------------------------------------------------------
echo "==> update checks"
V=aurora-server/src/main/java/io/canvasmc/canvas/util/version/CanvasVersionFetcher.java
G=aurora-server/src/main/java/io/canvasmc/canvas/GlobalConfiguration.java

sub "$V" 's/^        if \(buildNumber\.isEmpty\(\)\) \{$/        if (true || buildNumber.isEmpty()) { \/\/ Aurora - no build API of our own, so never compare against CanvasMC build numbers/'
sub "$G" 's/^                        if \(buildNum == -1\) \{$/                        if (true || buildNum == -1) { \/\/ Aurora - see CanvasVersionFetcher#computeStatus/'

grep -q 'true || buildNumber.isEmpty()' "$V" || die "version fetcher guard not rewritten"
grep -q 'true || buildNum == -1'        "$G" || die "global configuration guard not rewritten"

# ---------------------------------------------------------------------------
# 8. Server GUI icon
# ---------------------------------------------------------------------------
echo "==> server GUI icon"
if [[ -f aurora-server/src/main/resources/canvas-logo.png ]]; then
  git mv aurora-server/src/main/resources/canvas-logo.png \
         aurora-server/src/main/resources/aurora-logo.png
fi

echo "==> after:  $(count . --exclude-dir=.git) case-insensitive 'canvas' occurrences"
echo "    (the remainder is upstream attribution, the Java package, the Weaver"
echo "     plugin id and maven.canvasmc.io — all deliberately kept)"

# ---------------------------------------------------------------------------
# 9. Remaining references to the old module directory names.
#    These live in the build patches, the ignore/editor config and the
#    upstream maintenance scripts. All are path references, never code.
# ---------------------------------------------------------------------------
echo "==> module path references"
for f in .editorconfig .gitignore build.gradle.kts pre_update.sh prepare_for_patch_roulette.sh rbp.sh \
         aurora-server/build.gradle.kts.patch aurora-api/build.gradle.kts.patch \
         aurora-server/minecraft-patches/base/0004-Region-Threading.patch \
         aurora-server/paper-patches/base/0002-Region-Threading.patch; do
  [[ -f $f ]] || continue
  perl -pi -e 's{canvas-server/}{aurora-server/}g; s{canvas-api/}{aurora-api/}g;
               s{/canvas-server\b}{/aurora-server}g; s{/canvas-api\b}{/aurora-api}g;
               s{:canvas-server:}{:aurora-server:}g; s{:canvas-api:}{:aurora-api:}g;
               s{"canvas-server\.}{"aurora-server.}g;
               s{name\.set\("canvas-api"\)}{name.set("aurora-api")}g;
               s{name\.set\("canvas-server"\)}{name.set("aurora-server")}g;
               s{projects\.canvasApi}{projects.auroraApi}g;
               s{projects\.canvasServer}{projects.auroraServer}g;' "$f"
done

# The generated build files are reproduced from the patches above; drop the
# stale copies so applyAllPatches writes them out under the new names.
rm -f canvas-server/build.gradle.kts canvas-api/build.gradle.kts \
      aurora-server/build.gradle.kts aurora-api/build.gradle.kts

echo "==> remaining old-module references in tracked files:"
git grep -nI 'canvasApi\|canvasServer\|canvas-server\|canvas-api' -- . \
  | grep -v '^aurora-server/src/minecraft' | grep -v '^README\.md' || echo "    none"

# ---------------------------------------------------------------------------
# 10. The Weaver fork name.
#
#     Weaver resolves the *minecraft* patch directories by convention from the
#     registered fork name — <forkName>-server/minecraft-patches/... — while
#     the paper-patches directory is configured explicitly. Renaming the module
#     directory without renaming the fork therefore silently applies zero
#     minecraft source patches ("Applied 0 patches" instead of 128) and the
#     build then fails on missing io.canvasmc.canvas.commands.
#
#     The fork name also picks the access-transformer file, build-data/<name>.at.
# ---------------------------------------------------------------------------
echo "==> weaver fork name"
sub aurora-server/build.gradle.kts.patch 's/val canvas = forks\.register\("canvas"\)/val aurora = forks.register("aurora")/'
sub aurora-server/build.gradle.kts.patch 's/^\+    activeFork = canvas$/+    activeFork = aurora/'
[[ -f build-data/canvas.at ]] && git mv build-data/canvas.at build-data/aurora.at

grep -q 'forks.register("aurora")' aurora-server/build.gradle.kts.patch || die "fork not renamed"
[[ -f build-data/aurora.at ]] || die "access transformer not renamed"
rm -f aurora-server/build.gradle.kts
