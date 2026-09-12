#!/bin/bash
set -euo pipefail

echo "=== Applying all patches ==="
./gradlew applyAllPatches --quiet

echo "=== Enabling Git file patches ==="
BUILD_FILES=(
  "build.gradle.kts"
  "aurora-server/build.gradle.kts"
)

for file in "${BUILD_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "ERROR: $file not found"
    exit 1
  fi

  sed -i 's/gitFilePatches *= *false/gitFilePatches = true/' "$file"
done

echo "=== Rebuilding single-file patches ==="
./gradlew rebuildFoliaSingleFilePatches --quiet

echo "=== Rebuilding file patches as Git patches ==="
./gradlew rebuildAllServerFilePatches --quiet
./gradlew rebuildPaperApiFilePatches --quiet

echo "=== Moving file patches to _unapplied ==="
dirs=(
  "aurora-server/minecraft-patches/sources aurora-server/minecraft-patches/sources_unapplied"
  "aurora-server/paper-patches/files aurora-server/paper-patches/files_unapplied"
  "aurora-server/folia-patches/files aurora-server/folia-patches/files_unapplied"
  "aurora-api/paper-patches/files aurora-api/paper-patches/files_unapplied"
  "aurora-api/folia-patches/files aurora-api/folia-patches/files_unapplied"
)

for dir in "${dirs[@]}"; do
  set -- $dir
  src=$1
  dest=$2

  if [[ -d "$src" ]]; then
    mkdir -p "$dest"
    mv "$src"/* "$dest"/ 2>/dev/null || true
  fi
done

echo "=== REMINDER: ==="
echo "After moving patches back to their directories during update, run the following tasks to apply them and move failed ones:"
echo "  ./gradlew applyOrMovePaperServerFilePatches"
echo "  ./gradlew applyOrMovePaperApiFilePatches"
