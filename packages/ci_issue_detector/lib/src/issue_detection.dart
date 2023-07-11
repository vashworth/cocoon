// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:platform/platform.dart';
import 'package:logging/logging.dart';

import 'base/detector_config.dart';
import 'base/detector_metadata.dart';
import 'base/issue_detector.dart';
import 'detectors/all_detectors.dart';
import 'metadata/devicelab_metadata.dart';

class IssueDetection {
  IssueDetection({
    this.isLocal = true,
    Platform platform = const LocalPlatform(),
    FileSystem fileSystem = const LocalFileSystem(),
    bool verbose = false,
    Logger? logger,
    // TODO: timeout?
  })  : _platform = platform,
        _fileSystem = fileSystem {

    // Setup logger
    if (logger != null) {
      _logger = logger;
    } else {
      if (verbose) {
        Logger.root.level = Level.ALL;
      } else {
        Logger.root.level = Level.WARNING;
      }
    }
    _logger.onRecord.listen((LogRecord record) {
      stdout.writeln(record.toString());
    });
  }

  final Platform _platform;
  final FileSystem _fileSystem;
  Logger _logger = Logger('issue_detection');

  bool isLocal;

  Future<List<DetectionResult>> detectIssues({
    required String metadataFilePath,
  }) async {
    // TODO: Add parameters - list of detectors to run, machine flag?

    DetectorMetadata metadata = getMetadata(metadataFilePath);

    DetectorConfig config = DetectorConfig(
      fileSystem: _fileSystem,
      platform: _platform,
      logger: _logger,
    );

    List<IssueDetector> detectors = getAllDetectors(metadata, config);

    List<DetectionResult> results = [];

    for (IssueDetector detector in detectors) {
      if (_shouldRunDetector(detector)) {
        _logger.fine('Running ${detector.name}...');
        DetectionResult result = await detector.run();
        results.add(result);
        _logger.fine('Results of ${detector.name}: ${result.matchFound}');
      }
    }
    return results;
  }

  bool _shouldRunDetector(IssueDetector detector) {
    // Skip detector if incompatible metadata
    if (detector.metadata.runtimeType != detector.requiredMetadataType) {
      _logger.fine('Skipping ${detector.name} - incompatible metadata...');
      return false;
    }
    // Skip is running locally and the detector does not allow
    if (!detector.allowRunLocally && isLocal) {
      _logger.fine('Skipping ${detector.name} - not allowed to run locally...');
      return false;
    }
    if (!detector.shouldRun) {
      _logger.fine('Skipping ${detector.name}...');
      return false;
    }
    return true;
  }

  DetectorMetadata getMetadata(String metadataFilePath) {
    File metadataFile = _fileSystem.file(metadataFilePath);
    if (!metadataFile.existsSync()) {
      _logger.severe('Unable to find metadata file at ${metadataFile.path}');
      throw '';
    }

    final String stringOutput = metadataFile.readAsStringSync();
    try {
      final Object parsedResults =
          json.decode(stringOutput) as Map<String, Object?>;
      if (parsedResults is! Map<String, Object?>) {
        throw ('$kMetadataFileName has unexpected JSON response: $stringOutput');
      }
      final String? metadataTypeString =
          parsedResults['metadata_type']?.toString();
      if (metadataTypeString == null) {
        throw ('A $kMetadataFileName was found, but it did not contain a metadata_type.');
      }
      MetadataType? metadataType =
          MetadataType.getByJsonValue(metadataTypeString);
      if (metadataType == null) {
        throw ('Found an unknown metadata_type: $metadataTypeString');
      }

      switch (metadataType) {
        case MetadataType.basic:
          return DetectorMetadata(
              fileSystem: _fileSystem, metadataMap: parsedResults);
        case MetadataType.devicelabTestRunner:
          return DevicelabMetadata(
              fileSystem: _fileSystem, metadataMap: parsedResults);
      }
    } on FormatException {
      _logger.severe('$kMetadataFileName has non-JSON response: $stringOutput');
      rethrow;
    }
  }
}
