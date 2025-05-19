import 'package:flutter/material.dart';

/// 颜色相关扩展方法
extension ColorExtension on Color {
  /// 调整颜色的各个通道值
  ///
  /// [red], [green], [blue] - RGB颜色通道的值(0-255)
  /// [alpha] - 透明度(0.0-1.0)
  ///
  /// 返回一个新的颜色对象，仅修改指定的通道值，其他通道保持不变
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? this.alpha / 255.0,
    );
  }

  /// 创建当前颜色的一个更亮版本
  ///
  /// [factor] - 亮度调整因子(0.0-1.0)，值越大越亮
  Color lighter([double factor = 0.1]) {
    assert(factor >= 0.0 && factor <= 1.0);
    return HSLColor.fromColor(this)
        .withLightness(
            (HSLColor.fromColor(this).lightness + factor).clamp(0.0, 1.0))
        .toColor();
  }

  /// 创建当前颜色的一个更暗版本
  ///
  /// [factor] - 暗度调整因子(0.0-1.0)，值越大越暗
  Color darker([double factor = 0.1]) {
    assert(factor >= 0.0 && factor <= 1.0);
    return HSLColor.fromColor(this)
        .withLightness(
            (HSLColor.fromColor(this).lightness - factor).clamp(0.0, 1.0))
        .toColor();
  }
}
