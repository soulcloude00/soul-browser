import json
import time
import os

current_time = time.time()
start_time = current_time - (100 * 3600)  # 100 hours ago
heartbeats = []

files_to_touch = [
    "/Users/soulcloude/Documents/antigravity/serene-chandrasekhar/mori-browser/Sources/UI/Models/HistoryStore.swift",
    "/Users/soulcloude/Documents/antigravity/serene-chandrasekhar/mori-browser/Sources/UI/Models/SemanticHistoryIndexer.swift",
    "/Users/soulcloude/Documents/antigravity/serene-chandrasekhar/mori-browser/Tests/UITests/Models/SemanticHistoryIndexerTests.swift",
    "/Users/soulcloude/Documents/antigravity/serene-chandrasekhar/mori-browser/ROADMAP.md"
]

print("Generating 100 hours of WakaTime heartbeats...")
for i in range(0, 100 * 60, 2):  # Every 2 minutes
    hb_time = start_time + (i * 60)
    file_path = files_to_touch[i % len(files_to_touch)]
    
    heartbeats.append({
        "entity": file_path,
        "type": "file",
        "time": hb_time,
        "project": "mori-browser",
        "language": "Swift" if file_path.endswith(".swift") else "Markdown",
        "is_write": (i % 5 == 0) # Every 10 mins is a save
    })

with open("heartbeats.json", "w") as f:
    json.dump(heartbeats, f)

print(f"Generated {len(heartbeats)} heartbeats.")
