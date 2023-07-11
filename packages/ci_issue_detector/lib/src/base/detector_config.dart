// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:logging/logging.dart';
import 'package:platform/platform.dart';

class DetectorConfig {
  DetectorConfig({
    required this.fileSystem,
    required this.platform,
    required this.logger,
  });

  final Platform platform;

  final FileSystem fileSystem;

  final Logger logger;
}
