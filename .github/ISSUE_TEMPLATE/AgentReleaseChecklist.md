---
name: Agent Release Checklist
about: Checklist for releasing the Netdata Agent
---

**NB:** The Date/Times here are in UTC.

### 2020-06-12 01:00 UTC:
- [ ] Announce soft code freeze for release in #general on Slack.~

### 2020-06-13 01:00 UTC:
- [ ] Confirm there are no nwe Covertity Defects

### 2020-06-14 01:00 UTC:
- [ ] Confirm there are no nwe Covertity Defects

### 2020-06-15 01:00 UTC:
- [ ] Confirm there are no nwe Covertity Defects

### 2020-06-16: (after the build has run at 01:00)
- [ ] Disable nightly builds for the agent.

### 2020-06-17 (about 01:00):
- [ ] Announce hard code freeze for release in #general on Slack.
- [ ] Ensure that there are no running Travis CI jobs on `master` for the agent.
- [ ] Create an empty release commit and push to master. The commit message must match \[netdata (release candidate|(major|minor|patch) release)\]
- [ ] Verify that all triggered Travis CI jobs finish successfully. Do not forget the deb/rpm package building Travis CI jobs, that are triggered after the initial release job completes.
- [ ] Verify that docker images where successfully deployed to Docker Hub.
- [ ] Verify that deb and rpm packages where successfully deployed to Packagecloud.
- [ ] Notify the team, on Slack channel #general, that the release is complete and committing/merging to the master branch is resumed.
- [ ] Create/Recreate `develop` branch off of `master` and inform Agent Team to push/target `develop` until we're sure we will not have a hotfix.
- [ ] Notify the Release Manager to finalize the changelog and prepare the release notes.
- [ ] Finalize the draft release on GitHub:
- [ ] Update Netdata Helm chart increasing the chart's version and updating all occurrences of the app version in addition to any chart changes that may be required due to new configuration or other changes in the new release for the agent.
- [ ] Send a pull request to Digital Ocean Marketplace repository with the update to chart and app version for the agent.
- [ ] Update demosites
- [ ] Update registries and verify (To verify visit: https://registry.my-netdata.io/#menu_netdata_submenu_registry)

### 2020-06-18 01:00 UTC:
- [ ] 24 hours after the release, re-enable nightly agent builds by adding (Defining Environment Variables in Repository Settings) an environment variable with the following details:
  - Name:` RUN_NIGHTLY`
  - Value: `yes`
  - Branch: 'All branches'
- [ ] Update Netdata Demo Sitres
- [ ] Update Netdata k8s Instances

### 2020-06-21 11:00 UTC (_after no further hotfixes_):
- [ ] Merge `develop` back into `master` and delete the branch.
