// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'detector_config.dart';
import 'detector_metadata.dart';

abstract class IssueDetector {
  IssueDetector(this.metadata, this.config);

  final DetectorMetadata metadata;

  final DetectorConfig config;

  IssueDetectorIdentifer get identifer;

  /// Easy to read name for the detector.
  String get name;

  /// If IssueDetector uses a custom DetectorMetadata, this should be set to the type of DetectorMetadata.
  /// This will be used to check if the IssueDetector should run.
  Type get requiredMetadataType;

  String get description;
  String get owner;

  bool get shouldRun;
  bool get allowRunLocally;
  GithubTrackingOptions? get githubOptions => null;

  Future<DetectionResult> run();

  void cancel();
}

class DetectionResult {
  DetectionResult(this.detector, this.matchFound);

  final bool matchFound;
  final IssueDetector detector;
}

class GithubTrackingOptions {
  GithubTrackingOptions(this.githubIssue);

  String githubIssue;
}

enum IssueDetectorIdentifer {
  symbolsReadFromMemoryDetector,
}
