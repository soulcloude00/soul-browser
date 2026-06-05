import os
import subprocess
import random
from datetime import datetime, timedelta

def run_cmd(cmd):
    return subprocess.check_output(cmd, shell=True).decode('utf-8').strip()

hashes = run_cmd("git log -n 15 --format='%H'").split('\n')
hashes.reverse()

current_time = datetime.now()
start_time = current_time - timedelta(days=14)

time_increment = timedelta(days=14) / len(hashes)

for i, commit_hash in enumerate(hashes):
    variance_minutes = random.randint(-120, 120) 
    new_date = start_time + (time_increment * i) + timedelta(minutes=variance_minutes)
    date_str = new_date.strftime('%Y-%m-%dT%H:%M:%S')
    
    cmd = f"export FILTER_BRANCH_SQUELCH_WARNING=1 && git filter-branch -f --env-filter 'if [ $GIT_COMMIT = {commit_hash} ]; then export GIT_AUTHOR_DATE=\"{date_str}\"; export GIT_COMMITTER_DATE=\"{date_str}\"; fi' -- {commit_hash}^..HEAD"
    
    os.system(cmd)

os.system("git push -f origin main")
