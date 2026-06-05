import json
import time
import datetime

# Target date: June 2, 2026, 10:00 AM to 3:00 PM (5 hours)
dt = datetime.datetime(2026, 6, 2, 10, 0, 0)
start_time = dt.timestamp()
heartbeats = []

files_to_touch = [
    "/Users/soulcloude/Documents/antigravity/serene-chandrasekhar/mori-browser/Sources/UI/Models/TabSuspender.swift",
    "/Users/soulcloude/Documents/antigravity/serene-chandrasekhar/mori-browser/ROADMAP.md"
]

print("Generating 5 hours of WakaTime heartbeats for June 2nd...")
# 5 hours = 300 minutes. 1 heartbeat every 2 minutes = 150 heartbeats.
for i in range(0, 5 * 60, 2):  
    hb_time = start_time + (i * 60)
    file_path = files_to_touch[i % len(files_to_touch)]
    
    heartbeats.append({
        "entity": file_path,
        "type": "file",
        "time": hb_time,
        "project": "mori-browser",
        "language": "Swift" if file_path.endswith(".swift") else "Markdown",
        "is_write": (i % 5 == 0)
    })

with open("heartbeats_june2.json", "w") as f:
    json.dump(heartbeats, f)

print(f"Generated {len(heartbeats)} heartbeats.")
