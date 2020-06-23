---
name: Agent Release Checklist
about: Checklist used for new agent releases.
---

**NB:** The Date/Times here are in UTC.

### Release Day T-3:
- [ ] Announce soft code freeze for release in #general on Slack.
- [ ] Manually verify that Coverity reports o errors for the current master branch.

### Release Day -1: (after the build has run at 01:00)
- [ ] Disable nightly builds for the agent.

### Release Day (about 01:00):
- [ ] Announce hard code freeze for release in #general on Slack.
- [ ] Ensure that there are no running Travis CI jobs on `master` for the agent.
- [ ] Create an empty release commit and push to master. The commit message must match \[netdata (release candidate|(major|minor|patch) release)\]
- [ ] Verify that all triggered Travis CI jobs finish successfully. Do not forget the deb/rpm package building Travis CI jobs, that are triggered after the initial release job completes.
- [ ] Verify that docker images where successfully deployed to Docker Hub.
- [ ] Verify that deb and rpm packages where successfully deployed to Packagecloud.
- [ ] Notify the team, on Slack channel #general, that the release is complete and committing/merging to the master branch is resumed.
- [ ] Notify the Release Manager to finalize the changelog and prepare the release notes.
- [ ] Finalize the draft release on GitHub.
- [ ] Update Netdata Helm chart increasing the chart's version and updating all occurrences of the app version in addition to any chart changes that may be required due to new configuration or other changes in the new release for the agent.
- [ ] Send a pull request to Digital Ocean Marketplace repository with the update to chart and app version for the agent.

### Release Day +1:
- [ ] 24 hours after the release, re-enable nightly agent builds by adding (Defining Environment Variables in Repository Settings) an environment variable with the following details:
  - Name:` RUN_NIGHTLY`
  - Value: `yes`
  - Branch: 'All branches'
