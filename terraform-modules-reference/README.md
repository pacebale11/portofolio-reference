# terraform-modules

## Releasing new module versions

New versions are released using a combination of Git tags and GitLab releases.

**New versions are released using [GitLab release feature](https://gitlab.com/host-id/host-host/infra/terraform-modules/-/releases).** Terraform only requires the module to be published using `git tag`, but we use GitLab release to also put changelogs.

**Git tags are named using this format: `<module>/<version>`** (e.g. `gcs/1.2.0`, `uptime-check/1.1.0`). The `<module>` name corresponds to the module directory name on this repository.

This way, modules in this repository are called using `git` module source format below:

```terraform
module "gcs_<bucket name>" {
  # Format: git::https://gitlab.com/host-id/host-host/infra/terraform-modules.git//<module>?ref=<module>/<version>
  source = "git::https://gitlab.com/host-id/host-host/infra/terraform-modules.git//gcs?ref=gcs/1.1.0"

  # ...
}
```

**Version numbers are using [Semantic Versioning convention](https://semver.org/) as much as possible.**

**To release new module versions, follow the steps below:**

1. Open an MR containing your changes.
    - Don't forget to also update the `CHANGELOG.md` file inside the module directory.
1. Follow the MR workflow as described in [Cloud Ops ways of working page](https://docs.google.com/document/d/1fgMUkL0lNB7L1o4Uypui_Az6LApkpN3FCx6CbSlAhuk/edit?usp=drive_link).
1. **After merging the MR**
    - In your local workstation, go to `main` branch & pull the latest version
    - Create new git tag by running `git tag <module>/<version>`
    - Push the tag `git push <module>/version`
    - Create new release by visiting this page: https://gitlab.com/host-id/host-host/infra/terraform-modules/-/releases, then click the **New release** button.
2. Fill the form:
    - On the **Tag name** field, put the desired Git tag name, following the format explained above;
    - Leave the **Release name** field empty; it will automatically use the Git tag name;
    - On the **Release notes** field, put the changelog entry for this version from `CHANGELOG.md`.
3. Click the **Create release** button.
4. Announce the new version release on [#kuli-kabel internal Slack channel](https://merdeka-host.slack.com/archives/G01L2H9GTFZ).
