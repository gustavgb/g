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

      if [[ $modified_count -eq 1 && $untracked_count -eq 0 ]]; then
        message="Update $modified"
      elif [[ $untracked_count -eq 1 && $modified_count -eq 0 ]]; then
        message="Created $untracked"
      else
        echo "Please provide a commit message. Here are the changed files."
        echo "  Usage: g c <commit-message>\n"
        git status
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

  *)
    echo "Usage:"
    echo "  g i <remote-url> [commit-message]   Init repo, commit all, and push"
    echo "  g c <commit-message>                Add all, commit, and push"
    echo "  g s                                 Check status"
    exit 1
    ;;
esac
