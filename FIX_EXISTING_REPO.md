# How to fix an existing GitHub repo that shows folders as submodules

If the current GitHub repository already shows folders with the arrow icon, run these commands from your local repository root:

```bash
git rm --cached argo-cd-implementation ci-cd-templates terraform-modules-reference
rm -rf argo-cd-implementation/.git ci-cd-templates/.git terraform-modules-reference/.git
find . -name .DS_Store -delete

git add .
git commit -m "Fix portfolio repository structure"
git push
```

After pushing, the folders should appear as normal folders on GitHub.
