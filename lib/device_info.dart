import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';


class DeviceInfo {
  bool isPhone() {
    var pixelRatio = window.devicePixelRatio;
    var logicalScreenSize = window.physicalSize / pixelRatio;
    var logicalWidth = logicalScreenSize.width;
    var logicalHeight = logicalScreenSize.height;
    var shortestSide = math.min(logicalWidth.abs(), logicalHeight.abs());
    return shortestSide < 600;
  }

  Size getSized(Orientation orientation) {
    Size sized = const Size(375, 812);
    if (isPhone()) {
      if (orientation == Orientation.portrait) {
        sized = const Size(375, 812);
      } else {
        sized = const Size(812, 375);
      }
    } else {
      if (orientation == Orientation.portrait) {
        sized = const Size(834, 1194);
      } else {
        sized = const Size(1194, 834);
      }
    }
    return sized;
  }
}
