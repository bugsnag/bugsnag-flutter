Releasing
=========

- Using GitHub create a new releasing branch from `next`: `releases/v<version number>`
- Checkout the release branch
  - Bump the version number: `make VERSION=<version> bump`
  - Inspect the updated CHANGELOG, README, and version files to ensure they are correct
  - Open a PR from the release branch to `main`
- Once merged:
  - Pull the latest changes from `main`
  - Run `git clean -df` to ensure no unexpected files make it into the release
  - Creating the staged release: `make stage`
  - Publish the new version to pub.dev: 
    - `cd staging/bugsnag_flutter && flutter pub publish`
    - `cd staging/bugsnag_breadcrumbs_dart_io && flutter pub publish`
    - `cd staging/bugsnag_breadcrumbs_http && flutter pub publish`
- Release on GitHub:
  - Create a release and tag from `main`
    on [GitHub Releases](https://github.com/bugsnag/bugsnag-flutter/releases)
- Merge outstanding docs PRs related to this release 
- Merge main into next