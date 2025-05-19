import 'package:flutter/material.dart';

/// 响应式布局助手类，用于在不同屏幕尺寸上优化UI显示
class ResponsiveHelper {
  /// 屏幕宽度断点 - 手机最大宽度
  static const double kMobileBreakpoint = 600.0;

  /// 屏幕宽度断点 - 平板最大宽度
  static const double kTabletBreakpoint = 900.0;

  /// 屏幕宽度断点 - 标准桌面宽度
  static const double kDesktopBreakpoint = 1200.0;

  /// 屏幕宽度断点 - 宽屏桌面宽度
  static const double kWideDesktopBreakpoint = 1600.0;

  /// 根据屏幕宽度确定设备类型
  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width < kMobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < kTabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 获取主面板宽度比例
  static double getPrimaryPanelWidthRatio(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 0.33; // 手机上主面板占屏幕宽度的1/3
      case DeviceType.tablet:
        return 0.28; // 平板上主面板占屏幕宽度的28%
      case DeviceType.desktop:
        return 0.20; // 桌面上主面板占屏幕宽度的20%
    }
  }

  /// 获取次级分类网格列数
  static int getSecondaryGridCrossAxisCount(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);
    double width = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.mobile:
        return width < 400 ? 3 : 4; // 在较小的手机上使用3列
      case DeviceType.tablet:
        return 5; // 平板上使用5列
      case DeviceType.desktop:
        // 根据屏幕宽度动态调整列数，超宽屏幕可显示更多列
        if (width > kWideDesktopBreakpoint) {
          return 8; // 超宽屏幕使用8列
        } else if (width > kDesktopBreakpoint) {
          return 7; // 宽屏使用7列
        } else {
          return 6; // 标准桌面使用6列
        }
    }
  }

  /// 获取适合当前屏幕的文本尺寸系数
  static double getTextScaleFactor(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);
    double width = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.desktop:
        // 大屏幕上文本尺寸可以更大一些，但不要过大
        if (width > kWideDesktopBreakpoint) {
          return 1.3; // 超宽屏幕
        } else if (width > kDesktopBreakpoint) {
          return 1.25; // 宽屏
        } else {
          return 1.2; // 标准桌面
        }
    }
  }

  /// 获取主类别项目高度
  static double getPrimaryItemHeight(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 48.0;
      case DeviceType.tablet:
        return 54.0;
      case DeviceType.desktop:
        return 68.0; // 增加大屏幕上的高度
    }
  }

  /// 获取次要类别的宽高比
  static double getSecondaryItemAspectRatio(BuildContext context) {
    DeviceType deviceType = getDeviceType(context);
    double width = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.mobile:
        return 0.85;
      case DeviceType.tablet:
        return 0.90;
      case DeviceType.desktop:
        // 超宽屏幕上使用不同的宽高比，使卡片更加方正
        if (width > kWideDesktopBreakpoint) {
          return 1.05; // 更加方正的卡片
        } else if (width > kDesktopBreakpoint) {
          return 1.0; // 在宽屏上更方正
        } else {
          return 0.95; // 标准桌面比例
        }
    }
  }

  /// 获取适合当前屏幕的间距
  static double getPadding(BuildContext context, {bool isSmall = false}) {
    DeviceType deviceType = getDeviceType(context);
    double width = MediaQuery.of(context).size.width;

    if (isSmall) {
      switch (deviceType) {
        case DeviceType.mobile:
          return 4.0;
        case DeviceType.tablet:
          return 6.0;
        case DeviceType.desktop:
          // 超宽屏幕上间距可以适当增加
          if (width > kWideDesktopBreakpoint) {
            return 12.0;
          } else if (width > kDesktopBreakpoint) {
            return 10.0;
          } else {
            return 8.0;
          }
      }
    } else {
      switch (deviceType) {
        case DeviceType.mobile:
          return 8.0;
        case DeviceType.tablet:
          return 12.0;
        case DeviceType.desktop:
          // 超宽屏幕上间距可以适当增加
          if (width > kWideDesktopBreakpoint) {
            return 24.0;
          } else if (width > kDesktopBreakpoint) {
            return 20.0;
          } else {
            return 16.0;
          }
      }
    }
  }

  /// 根据屏幕方向判断是否采用紧凑布局
  static bool shouldUseCompactLayout(BuildContext context) {
    // 检查是否是横屏模式的手机
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isMobile = getDeviceType(context) == DeviceType.mobile;

    return isLandscape && isMobile;
  }

  /// 获取图标大小
  static double getIconSize(BuildContext context, {bool isSmall = false}) {
    DeviceType deviceType = getDeviceType(context);
    double width = MediaQuery.of(context).size.width;

    if (isSmall) {
      switch (deviceType) {
        case DeviceType.mobile:
          return 16.0;
        case DeviceType.tablet:
          return 18.0;
        case DeviceType.desktop:
          // 大屏幕上的图标可以更大一些
          if (width > kWideDesktopBreakpoint) {
            return 24.0;
          } else if (width > kDesktopBreakpoint) {
            return 22.0;
          } else {
            return 20.0;
          }
      }
    } else {
      switch (deviceType) {
        case DeviceType.mobile:
          return 20.0;
        case DeviceType.tablet:
          return 22.0;
        case DeviceType.desktop:
          // 大屏幕上的图标可以更大一些
          if (width > kWideDesktopBreakpoint) {
            return 28.0;
          } else if (width > kDesktopBreakpoint) {
            return 26.0;
          } else {
            return 24.0;
          }
      }
    }
  }
}

/// 设备类型枚举
enum DeviceType {
  mobile,
  tablet,
  desktop,
}
