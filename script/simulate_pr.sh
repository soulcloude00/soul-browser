#!/bin/bash
set -e

BRANCH_NAME=$1
COMMIT_MSG=$2

echo "==> Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

echo "==> Staging and Committing..."
git add .
git commit -m "$COMMIT_MSG"

echo "==> Pushing branch to remote..."
git push origin "$BRANCH_NAME" || git push --set-upstream origin "$BRANCH_NAME"

echo "==> 📝 SIMULATING PULL REQUEST REVIEW..."
sleep 2
echo "==> ✅ PR APPROVED."

echo "==> Merging into main..."
git checkout main
git merge "$BRANCH_NAME"

echo "==> Pushing main to remote..."
git push origin main

echo "==> 🎉 Workflow Cycle Complete!"
