// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:file/file.dart';

import '../base/issue_detector.dart';
import '../metadata/devicelab_metadata.dart';

class SymbolsReadFromMemoryDetector extends IssueDetector {
  SymbolsReadFromMemoryDetector(super.metadata, super.config);

  DevicelabMetadata get _devicelabMetadata => metadata as DevicelabMetadata;

  @override
  Type get requiredMetadataType => DevicelabMetadata;

  @override
  bool get allowRunLocally => true;

  @override
  void cancel() {
    // TODO: implement cancel
  }

  @override
  String get description => 'Check if lldb is reading from device memory for symbols.';

  @override
  IssueDetectorIdentifer get identifer => IssueDetectorIdentifer.symbolsReadFromMemoryDetector;

  @override
  String get name => 'Symbols Read From Memory Detector';

  @override
  String get owner => '@vashworth';

  @override
  bool get shouldRun {
    if (!config.platform.isMacOS) {
      return false;
    }
    return true;
  }

  static final RegExp _symbolsPathPattern = RegExp(r'.*Symbol Path: ');
  String? _symbolsDirectoryPath;

  @override
  Future<DetectionResult> run() async {
    Directory? logsDirectory = _devicelabMetadata.logsDirectory;
    if (logsDirectory == null) {
      throw 'Unable to find logs directory in metadata';
    }

    for (TestRunnerTestLog testLog in _devicelabMetadata.testLogFilePaths) {
      if (testLog.logPath == null) {
        config.logger.severe('Could not get test log path from metadata');
        continue;
      }
      File logFile = logsDirectory.childFile(testLog.logPath!);
      if (!logFile.existsSync()) {
        config.logger.severe('Could not find file ${logFile.path}');
        continue;
      }

      config.logger.fine('Analyzing file ${logFile.path}');

      bool errorFound = false;

      try {
        String logString = await logFile.readAsString();

        List<String> testLines = LineSplitter.split(logString).toList();

        for (String line in testLines) {
          if (line.contains('(lldb) warning: libobjc.A.dylib is being read from process memory.')) {
            errorFound = true;
          }
          if (line.contains('Symbol Path:') && _symbolsPathPattern.hasMatch(line)) {
            final String prefix = _symbolsPathPattern.stringMatch(line) ?? '';
            if (prefix.isEmpty) {
              continue;
            }
            _symbolsDirectoryPath = line.substring(prefix.length);
          }

          if (errorFound && _symbolsDirectoryPath != null) {
            break;
          }
        }
      } catch (e) {
        config.logger.severe(e);
      }

      if (errorFound) {
        return DetectionResult(this, true);
      }
    }

    return DetectionResult(this, false);
  }
}
