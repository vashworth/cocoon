// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

const String kMetadataFileName = 'detector_metadata.json';

class DetectorMetadata {
  DetectorMetadata({
    required FileSystem fileSystem,
    required this.metadataMap,
  }) : _fileSystem = fileSystem;

  final FileSystem _fileSystem;
  final Map<String, Object?> metadataMap;

  String? get pathToLogsDirectory => metadataMap['test_log_directory']?.toString();

  MetadataType get metadataType => MetadataType.basic;

  Directory? get logsDirectory {
    if (pathToLogsDirectory != null) {
      return _fileSystem.directory(pathToLogsDirectory);
    }
    return null;
  }
}

enum MetadataType {
  basic(jsonValue: 'basic'),
  devicelabTestRunner(jsonValue: 'devicelab_test_runner');

  const MetadataType({
    required this.jsonValue,
  });

  final String jsonValue;

  static MetadataType? getByJsonValue(String jsonValue) {
    if (jsonValue == MetadataType.devicelabTestRunner.jsonValue) {
      return MetadataType.devicelabTestRunner;
    }
    return null;
  }
}
