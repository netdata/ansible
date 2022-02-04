---
name: Agent Release Checklist
about: Checklist for releasing the Netdata Agent
---

Titles reflect timing relative to release day in business days.

### T minus 5 days:
- [ ] Announce soft code freeze for release in #agent on Slack.

### T minus 4 days:
- [ ] Confirm with the agent team that any blockers for the release are on schedule

### T minus 3 days:
- [ ] Confirm with the agent team that any blockers for the release are on schedule

### T minus 2 days:
- [ ] Confirm with the agent team that any blockers for the release are on schedule

### T minus 1 day:
- [ ] Confirm with the agent team that all blockers for the release have been resolved
- [ ] Confirm with the documentation team that the relase notes are ready

### Release day:
- [ ] Confirm with the agent team on Slack that there are no pending blockers for the release
- [ ] Announce hard code freeze for release in #general on Slack
- [ ] Create an empty release commit and push to master. The commit message must match `\[netdata (release candidate|(major|minor|patch) release)\]`
- [ ] Verify that all triggered Travis CI jobs finish successfully
- [ ] Verify that the Docker build CI workflow has completed and that the `latest` and `stable` tags have been updated on Docker Hub
- [ ] Verify that the package build CI workflow has correctly published packages to PackageCloud
- [ ] Verify that the main build CI workflow has finished completely and created a draft release with the correct artifacts attached
- [ ] Copy the release notes from the issue in the marketing repo to the draft release
- [ ] Publish the draft release
- [ ] Notify the team, on Slack channel #general, that the release is complete and committing/merging to the master branch is resumed
- [ ] Create/Recreate `develop` branch off of `master` and inform Agent Team to push/target `develop` until we're sure we will not have a hotfix
- [ ] Verify that a PR updating the Helm chart was automatically created

### T plus 1 day:
- [ ] Verify that the demo sites have updated to the new release, and if not update them
- [ ] Verify that the Helm chart update has been merged
- [ ] Send a pull request to Digital Ocean Marketplace repository with the update to chart and app version for the agent

### Once no further hotfixes are required:
- [ ] Announce the end of the soft code freeze for the release in #agent on Slack
- [ ] Merge `develop` back into `master` and delete the branch
- [ ] Find a list of any remaining PRs targeting the `develop` branch (search PRs using `is:open is:pr base:develop`) and notify their authors to update to target the master branch.
