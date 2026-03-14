#!/bin/bash

cmd="$1"

case "$cmd" in
  i)
    if [[ -z "$2" ]]; then
      echo "Usage: g i <remote-url> [commit-message]"
      exit 1
    fi

    message="${3:-Initial commit}"

    if git rev-parse --git-dir > /dev/null 2>&1; then
      echo "Error: already inside a git repository"
      exit 1
    fi

    git init
    git remote add origin "$2"
    git add .
    git commit -m "$message"
    branch=$(git branch --show-current)
    git push -u origin "$branch"
    ;;

  c)
    if [[ -z "$2" ]]; then
      modified=$(git diff --name-only)
      untracked=$(git ls-files --others --exclude-standard)
      modified_count=$(echo "$modified" | grep -c .)
      untracked_count=$(echo "$untracked" | grep -c .)

      if [[ $modified_count -eq 0 && $untracked_count -eq 0 ]]; then
        echo "nothing to commit, working tree clean"
        exit 1
      elif [[ $modified_count -eq 1 && $untracked_count -eq 0 ]]; then
        message="Update $modified"
      elif [[ $untracked_count -eq 1 && $modified_count -eq 0 ]]; then
        message="Created $untracked"
      else
        echo "Please provide a commit message. Here are the changed files:"
        echo ""
        git diff --name-status
        echo ""
        echo "Usage: g c \"commit-message\""
        exit 1
      fi
    else
      message="$2"
    fi

    git add .
    git commit -m "$message"
    branch=$(git branch --show-current)
    git push origin "$branch"
    ;;

  s)
    git status
    ;;

  p)
    git pull --ff
    git push
    git push --tags
    ;;

  b)
    git branch -a
    ;;

  dirty)
    find . -type d -name .git | while read repo; do
        dir=$(dirname "$repo")
        cd "$dir"

        has_changes=false
        has_unpushed=false

        # Local changes (staged/unstaged/untracked)
        if [[ -n "$(git status --porcelain)" ]]; then
            has_changes=true
        fi

        # Unpushed commits
        if git log --branches --not --remotes | grep -q '^commit'; then
            has_unpushed=true
        fi

        if [[ "$has_changes" == true || "$has_unpushed" == true ]]; then
            echo "Repo: $dir"
            if [[ "$has_changes" == true ]]; then
                echo "  - Working tree is DIRTY"
                git status -sb
            fi
            if [[ "$has_unpushed" == true ]]; then
                echo "  - There are UNPUSHED COMMITS"
            fi
            echo ""
        fi

        cd - > /dev/null
    done
    ;;


  prune)
    git fetch --prune
    gone=$(git branch -vv | grep ': gone]' | awk '{print $1}')
    if [[ -z "$gone" ]]; then
      echo "No local branches to delete."
    else
      echo "The following local branches will be deleted:"
      echo "$gone"
      echo ""
      read -r -p "Proceed? [y/N] " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "$gone" | xargs git branch -d
      else
        echo "Aborted."
      fi
    fi
    ;;

  *)
    echo "Usage:"
    echo "  g i <remote-url> [commit-message]   Init repo, commit all, and push"
    echo "  g c <commit-message>                Add all, commit, and push"
    echo "  g s                                 Check status"
    echo "  g p                                 Pull"
    echo "  g b                                 List all local and remote branches"
    echo "  g prune                             Prune remote tracking refs and delete local branches whose remote is gone"
    exit 1
    ;;
esac
