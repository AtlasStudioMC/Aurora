#!/bin/bash
# Aikar's flags: https://docs.papermc.io/paper/aikars-flags
# Same G1GC tuning Atlas ships, for the same reason: GC pauses are the single
# biggest cause of ping spikes that the server itself can control. A 200ms
# collection pause is a 200ms freeze for every connected player, no matter how
# good their connection is.
#
# -Xms == -Xmx on purpose: letting the heap resize at runtime causes extra GC
# pauses exactly when the server is busiest.
#
# -XX:+AlwaysPreTouch is deliberately left OUT, matching Atlas. It forces the OS
# to commit and zero the whole heap before the server does anything, which adds
# a long delay to every startup. The tradeoff is some page faults during the
# first seconds of load instead. Add it back if you prefer that trade.

MEMORY="4G"

if [ -z "${JAR:-}" ]; then
  for candidate in Aurora-26.2.jar aurora-paperclip-26.2.jar; do
    if [ -f "$candidate" ]; then JAR="$candidate"; break; fi
  done
fi
if [ -z "${JAR:-}" ]; then
  echo "No Aurora jar found in $(pwd)." >&2
  echo "Expected Aurora-26.2.jar, or set JAR=/path/to/server.jar" >&2
  exit 1
fi

java -Xms${MEMORY} -Xmx${MEMORY} \
  -XX:+UseG1GC \
  -XX:+ParallelRefProcEnabled \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+DisableExplicitGC \
  -XX:G1NewSizePercent=30 \
  -XX:G1MaxNewSizePercent=40 \
  -XX:G1HeapRegionSize=8M \
  -XX:G1ReservePercent=20 \
  -XX:G1HeapWastePercent=5 \
  -XX:G1MixedGCCountTarget=4 \
  -XX:InitiatingHeapOccupancyPercent=15 \
  -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 \
  -XX:SurvivorRatio=32 \
  -XX:+PerfDisableSharedMem \
  -XX:MaxTenuringThreshold=1 \
  --add-modules=jdk.incubator.vector \
  -Dusing.aikars.flags=https://mcflags.emc.gs \
  -Daikars.new.flags=true \
  -jar "$JAR" nogui
