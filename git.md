# Git and GitHub

## Setup config

```
git config --global user.name "Guilhem Mizrahi"
git config --global user.email "guilhem.mizrahi@gmail.com"
```

## Setup SSH key

Add the SSH key to the GitHub profile. 

```
ssh-keygen -t ed25519 -C "guilhem.mizrahi@gmail.com"
```

## Setup repo

```
git init
git add -A
git commit -a -m "Commit message"
git remote add origin git@github.com:g-mizrahi/<repository>.git
git push --set-upstream origin master
```
