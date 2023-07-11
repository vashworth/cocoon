// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:ci_issue_detector/ci_issue_detector.dart';
import 'package:file/file.dart';

Future<void> main() async {
  // TODO: Check github rate limit

  List<String> commitSHAs = getCommitList();

  for (String commitSHA in commitSHAs) {
    List<File> metadataFiles = getMetadataFiles(commitSHA);

    // Run issue detection
    IssueDetection issueDetection = IssueDetection();

    List<DetectionResult> allResults = <DetectionResult>[];

    for (File file in metadataFiles) {
      // DetectorMetadata metadata = issueDetection.getMetadata(file.path);
      List<DetectionResult> results = await issueDetection.detectIssues(metadataFilePath: file.path);
      allResults.addAll(results);
    }

    // TODO
    // Add results to database

    // TODO
    // Post to Github
    for (DetectionResult result in allResults) {
      GithubTrackingOptions? githubOptions = result.detector.githubOptions;
      if (result.matchFound == false || githubOptions == null) {
        continue;
      }
      // Get timeline of issue
      // Check if issue is closed
      // Check if already commented
      // Update or create new comment

      // https://docs.github.com/en/rest/issues/timeline?apiVersion=2022-11-28
      // https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#update-an-issue-comment
      // https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#create-an-issue-comment
    }
  }
}

List<String> getCommitList() {
  // TODO
  // Call Github API to get list of commits in last hour
  // https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28#list-commits
  // Probably something like this: /repos/OWNER/REPO/commits?since=YYYY-MM-DDTHH:MM:SSZ&per_page=100&page=1

  return <String>[];
}

List<File> getMetadataFiles(String commitSHA) {
  // TODO
  // Get logs from Google Cloud Services
  // gcloud storage ls gs://[insert bucket name]/flutter/[insert commit-sha]/**/detector_metadata.json
  // alternative: gsutil ls gs://[insert bucket name]/flutter/[insert commit-sha]/**/detector_metadata.json
  // copy files to local filesystem
  return <File>[];
}
