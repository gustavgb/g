# g - my simple git shortcuts

```sh
~$ g
Usage:
  g i <remote-url> [commit-message]   Init repo, commit all, and push
  g c <commit-message>                Add all, commit, and push
  g s                                 Check status
```

If only one file was changed, you can omit the commit message from `g c`.

To make git respect special characters in the status and automatic commit messages, run `git config --global core.quotepath false`.

Use at your own risk.