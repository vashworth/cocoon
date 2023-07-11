// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../base/detector_metadata.dart';

class DevicelabMetadata extends DetectorMetadata {
  DevicelabMetadata({
    required super.fileSystem,
    required super.metadataMap,
  });

  List<TestRunnerTestLog> get testLogFilePaths {
    List<TestRunnerTestLog> testLogs = <TestRunnerTestLog>[];
    if (metadataMap['test_logs'] is List<Object?>) {
      final List<Object?> logValues = metadataMap['test_logs']! as List<Object?>;
      for (final Object? logValue in logValues) {
        if (logValue != null && logValue is Map<String, Object?>) {
          testLogs.add(TestRunnerTestLog(logValue));
        }
      }
    }

    return testLogs;
  }

  @override
  MetadataType get metadataType => MetadataType.devicelabTestRunner;
}

class TestRunnerTestLog {
  TestRunnerTestLog(
    Map<String, Object?> data,
  ) : _data = data;

  final Map<String, Object?> _data;

  String? get testName => _data['test_name']?.toString();
  String? get logPath => _data['log_path']?.toString();
  int? get testDurationInSeconds {
    if (_data['test_duration_in_seconds'] is int?) {
      return _data['test_duration_in_seconds'] as int?;
    }
    return null;
  }
}
