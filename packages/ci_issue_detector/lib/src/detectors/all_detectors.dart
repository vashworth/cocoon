// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../base/detector_config.dart';
import '../base/detector_metadata.dart';
import '../base/issue_detector.dart';
import 'symbols_read_from_memory_detector.dart';

List<IssueDetector> getAllDetectors(
  DetectorMetadata metadata,
  DetectorConfig config,
) {
  return <IssueDetector>[
    SymbolsReadFromMemoryDetector(metadata, config),
  ];
}
