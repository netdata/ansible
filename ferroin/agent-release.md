# Netdata agent release process

Throughout this document, `<version>` is used as a stand-in for the version number for the release itself.

‘Release engineer’ below refers to the individual responsible for the release process outlined here, and will
in almost all cases be a member of the agent SRE team.

## Release checklist issue

High-level release progress is tracked using a release checklist issue created in the
https://github.com/netdata/internal repository. An issue template already exists in that repository for creating
the relese checklist issues.

Once a release date has been announced, this issue should be created by the release engineer.

As the steps of the release process are completed, the release checklist issue should be updated accordingly.

## Soft code freeze

Starting five workdays before the release day, the agent repository enters a soft code freeze. During this time,
no new features can be merged unless they have explicitly been stated as mandatory for the release. Bugfixes and
documentation updates are still permitted however.

The start of this soft code freeze is to be announced by the release engineer in the #agent channel on Slack,
using a message like the following:

```
@here We are now entering a _soft_ code freeze for the netdata/netdata repository in preparation for the release
of <version>. During this time, only bugfixes and documentation changes are permitted to be merged.
```

This step can be skipped if the soft code freeze from the previous release has not yet ended.

## Pre-release blockers

On the days leading up to the release, the  release engineer is expected to keep in-sync with the agent team
about any potential blockers for the release. Each day after the strt of the soft code freeze leading up to the
release day, they should confirm with the agent team that any potential blockers for the release are expected to
be resolved by the end of the workday _before_ the release and will be in that day's nightly build.

## Release notes

The release notes are managed prior to the release as an issue in the https://github.com/netdata/marketing repository
with an issue title like `Agent Release: <version>`. These are initially created as a joint effort between the
agent team, the product team, and the documentation team.

The release notes are expected to be fully reviewed by the product and documentation teams by the end of the
workday _before_ the release. The release engineer should confirm this on that workday.

## Release day greenlight decision

On the day of the release itself, prior to starting the release, the release engineer should confirm with the
agent team that there are no pending blockers for the release and no new issues that should delay the release.

This should be done on Slack in the #agent channel so that it remains on the public record.

## Hard code freeze

Once the final greenlight has been given for the release to go ahead. the agent repository immediately enters
a hard code freeze in preparation for the release, during which time _absolutely nothing_ may be merged to the
`master` branch.

This is to be announced on the #general channel on Slack using a message like the following, with the link at the
end replaced with a link to the release checklist issue for this release:

```
@here We are now entering a _hard_ code freeze for the netdata/netdata repository in preparation for the release of
<version>. During this time _nothing_ may be merged to `master` in netdata/netdata. Annother announcemne twill be
made here on #general when the hard code freeze is lifted. To follow along with the release progress, please see:
https://github.com/netdata/internal/issues/65
```

Once the announcement is made, a short waiting period of roughly five minutes is observed to ensure that the
announcement has been seen before proceeding to the next step.

## Triggering the release process

To actually trigger the release:

1. Ensure you have a clean local checkout of the `master` branch from the netdata/netdata repository. This can be
   achieved in one of two ways:
    * Create a temporary local clone of the netdata/netdata repository _just_ for use with this release.
    * Checkout the `msater` branch in an existing clone, pull the upstream master branch, and then run
      `git clean -dxf && git submodule update --init --recursive`.
2. Create an empty commit with the appropriate commit message for the release type:
    * For a major release: `git commit --allow-empty -m '[netdata major release] <version>'`
    * For a minor release: `git commit --allow-empty -m '[netdata minor release] <version>'`
    * For a patch release: `git commit --allow-empty -m '[netdata patch release] <version>'`
3. Push the commit to the master branch of the netdata/netdata repository.

## Monitoring the release CI jobs

Triggering the release process will result in a special Travis CI build being started. This build should show up
as the top item in https://app.travis-ci.com/github/netdata/netdata/builds. This will test building the agent,
generate the changelogs, and then finally trigger a set of three GitHub Actions workflows that prepare and publish
the various release artifacts.  The Travis build should be monitored to confirm it completes successfully.

Once the Travis build finsihes, the triggered GitHub Actions workflows should show up in
https://github.com/netdata/netdata/actions. They should have the titles ‘Build’ (for the primary release
artifact build workflow), ‘Docker’ (for the Docker image build workflow) and ‘Packages’ (for the native
DEB/RPM package build workflow), and all three should be listed as ‘Manually run by netdatabot’.

Each of these workflows should be monitored individually.

### Build

The build workflow is expected to take approximately two hours to fully complete. Once it finishes running,
https://github.com/netdata/netdata/releases should show a draft release without any text but with associated
release assets.

### Docker

The docker workflow si expected to take just over an hour to fully complete. Once it finishes running,
https://hub.docker.com/repository/docker/netdata/netdata should list recently pushed `stable` and `latest` tags,
as well as tags for the version of the release itself.

### Packages

The packages workflow si expected to take roughly 4-6 hours to fully complete. We usually do not wait for it to
run 100% to completion before continuing the release process due to how long this normally takes. Instead, we
typically wait until at least one each of the DEB and RPM package build jobs have completed (this usually happens
by the time the other workflows are done). Prior to continuing, https://packagecloud.io/netdata/netdata should be
checked to verify that the packages the workflow lists as built have actually been published successfully.

## Publishing the release

Once the release CI jobs are done, the release is ready to be published. To do so:

1. Open the release notes issue from https://github.com/netdata/marketing.
2. Click the three-dot icon at the top right of the original post in the issue and select ‘Edit’.
3. Copy everything after the first line that contains just `---` up through either the end of the text or the final line with just `---` on it (whichever is first).
4. Go to https://github.com/netdata/netdata/releases and select the blank draft release at the top of the page.
5. Click the pencil icon near the top right of the release banner to edit the release.
6. Paste the text copied above in step 3 into the large textbox.
7. Put `Release <version>` in the small textbox near the top.
8. At the bottom of the page, click the button labeled ‘Publish Release’.

## Release completion notice

Once the release has been published, the hard code freeze is lifted, and an announcement should be made in the
\#general channel on Slack by the release engineer as follows:

```
@here <version> of the Netdata Agent has been released and the hard code freeze for the netdata/netdata repository
is now over. Please note however that were are still in a soft code freeze (bug fixes and documentation changes
only) for the foreseeable future until we have determined there will be no further patch releases.
```

Additionally, the channel topic in #general should be updated to indicate the newly released version of the agent.

## Post-release tasks

After the releasee is published, there are still a number of tasks that need to be completed.

### Create the `develop` branch

Post-release, until the soft code freeze is lifted, a separate branch is created called `develop` which should
serve as the target for any PRs that would be blocked by the soft code freeze.

To create the branch (for a major or minor release):

1. Update the local `master` branch in the repository you are using for the release to be in-sync with the `master`
   branch in the netdata/netdata repository (this should pull exactly one additional commit).
2. Create the the `develop` branch with `git checkout -b develop`.
3. Push the `develop` branch.

To update the branch (for a patch release):

1. Update the local `master` branch in the repository you are using for the release to be in-sync with the `master`
   branch in the netdata/netdata repository (this should pull exactly one additional commit).
2. Checkout the `develop` branch.
3. Rebase the `develop` branch onto the latest `master` branch with `git rebase master`.
4. Force push the `develop` branch.

After creating or updating the branch, a message should be sent in the #agent-team channel on Slack to notify everyone.

### Verify that a PR has been created to update the Helm chart

When the Docker images are published for the release, this hsould automatically trigger the creation of a PR in
https://github.com/netdata/helmchart to update the Helm chart to use the latest release of netdata.

If this PR was not automatically created, the Cloud SRE team should be notified so that they can create it.

### Digital Ocean Marketplace

Once the Helm chart PR mentioned above has been merged and the updated Helm chart has been released, a PR should
be opened in https://github.com/digitalocean/marketplace-kubernetes to update the version of Netdata there.

See https://github.com/digitalocean/marketplace-kubernetes/pull/211 for what such a PR should look like.

### Demo site updates

The Netdata demo sites are set to automatically update to the latest stable version of Netdata using our regular
auto-update mechanism.

24-hours after the release is published, the demo sites should be checked to verify that they did, indeed, update
to the latest version, and if they did not they should be updated manually.

## Final cleanup

Once the release is finished and it has been determined that no further patch releases will be made, a few additional
cleanup steps are required.

First, the end of the soft code freeze should be announced in the #agent channel on Slack.

Second, the `develop` branch should be merged into the `master` branch. This should be handled by creating a PR.

Third, any existing PRs which have `develop` as their base branch should be found
(https://github.com/netdata/netdata/pulls?q=is%3Apr+is%3Aopen+base%3Adevelop for a search that will list all such
open PRs) and their authors notified to change their base to `master`.
