import json
import os
import subprocess

with open("heartbeats_today.json") as f:
    heartbeats = json.load(f)

for hb in heartbeats:
    entity = hb["entity"]
    timestamp = hb["time"]
    cmd = ["wakatime-cli", "--entity", entity, "--time", str(timestamp)]
    if hb.get("is_write"):
        cmd.append("--write")
    subprocess.run(cmd)

print("Finished syncing all heartbeats to WakaTime!")
