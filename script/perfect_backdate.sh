#!/bin/bash
# Get the last 10 commit hashes from oldest to newest
commits=$(git log --reverse --format="%H" HEAD~10..HEAD)

# Save the target branch
git checkout -b temp_backdate

# Hard reset back 10 commits
git reset --hard HEAD~10

# Calculate start date (10 days ago)
start_ts=$(date -v-10d +%s 2>/dev/null || date -d "10 days ago" +%s)
increment=$(( 86400 )) # 1 day per commit

current_ts=$start_ts

for commit in $commits; do
    echo "Cherry-picking $commit..."
    
    # Format the timestamp
    formatted_date=$(date -r $current_ts +"%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -d @$current_ts +"%Y-%m-%dT%H:%M:%S")
    
    export GIT_AUTHOR_DATE="$formatted_date"
    export GIT_COMMITTER_DATE="$formatted_date"
    
    git cherry-pick -n $commit
    git commit -C $commit
    
    current_ts=$((current_ts + increment))
done

# Replace main with temp_backdate
git checkout main
git reset --hard temp_backdate
git branch -D temp_backdate
git push -f origin main
echo "Done! History perfectly backdated."
