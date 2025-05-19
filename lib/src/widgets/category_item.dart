import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/picker_config.dart';
import '../utils/responsive_helper.dart';

class CategoryItem extends StatefulWidget {
  final Category category;
  final bool isSelected;
  final bool isPrimary;
  final CategoryPickerConfig config;
  final VoidCallback onTap;
  final Function(Category category)? onLongPress;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.isPrimary,
    required this.config,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  // 选中状态跟踪
  bool _wasSelected = false;

  @override
  void initState() {
    super.initState();
    _wasSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(CategoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 状态变化时更新状态
    if (widget.isSelected != oldWidget.isSelected) {
      _wasSelected = oldWidget.isSelected;

      if (widget.isSelected) {
        // 选中时触发触觉反馈
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检测设备类型和布局
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isCompact = ResponsiveHelper.shouldUseCompactLayout(context);

    // 使用GestureDetector替换InkWell以完全避免涟漪效果
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // 确保即使透明区域也能接收点击
      onTap: widget.onTap,
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!(widget.category);
            }
          : null,
      child: widget.isPrimary
          ? _buildPrimaryItem(context, deviceType, isCompact)
          : _buildSecondaryItem(context, deviceType, isCompact),
    );
  }

  // 构建主类别项
  Widget _buildPrimaryItem(
      BuildContext context, DeviceType deviceType, bool isCompact) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color categoryColor = widget.category.color;
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = deviceType == DeviceType.desktop && width > 1200;

    // 根据设备类型和布局计算字体大小和边距
    final fontSize = deviceType == DeviceType.mobile
        ? (isCompact ? 11.0 : 12.0)
        : deviceType == DeviceType.tablet
            ? 13.0
            : isLargeScreen
                ? 15.0
                : 14.0; // 大屏幕上字体更大

    final padding = ResponsiveHelper.getPadding(context, isSmall: true);

    // 获取文本样式
    final TextStyle defaultStyle = widget.config.primaryTextStyle ??
        theme.textTheme.titleSmall ??
        TextStyle(
          fontSize: fontSize,
          letterSpacing: isLargeScreen ? 0.3 : 0.2, // 大屏幕上字间距更大
        );

    // 选中状态下使用加粗文本并使用类别颜色
    final TextStyle selectedStyle = widget.config.primarySelectedTextStyle ??
        defaultStyle.copyWith(
          fontWeight:
              isLargeScreen ? FontWeight.w700 : FontWeight.w600, // 大屏幕上更加醒目
          letterSpacing: isLargeScreen ? 0.4 : 0.3,
        );

    final Color borderColor = widget.isSelected
        ? categoryColor
        : theme.colorScheme.outline.withValues(alpha: isDarkMode ? 0.2 : 0.15);

    // 文本颜色根据选中状态更改
    final Color textColor = widget.isSelected
        ? categoryColor
        : isDarkMode
            ? theme.colorScheme.onSurface.withValues(alpha: 0.9)
            : theme.colorScheme.onSurface;

    return Stack(
      children: [
        // 主容器 - 无动画效果
        Container(
          margin: EdgeInsets.symmetric(
              vertical: 2, horizontal: isLargeScreen ? padding : padding / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isLargeScreen ? 10 : 8),
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? (isLargeScreen ? 2.0 : 1.5) : 0.8,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: isCompact ? 2 : 4, horizontal: isCompact ? 2 : 4),
            child: Row(
              children: [
                // 图标 - 选中状态时使用颜色背景
                if (widget.config.showIcons &&
                    (widget.category.icon != null ||
                        widget.config.defaultIcon != null))
                  Container(
                    width:
                        ResponsiveHelper.getIconSize(context, isSmall: true) +
                            2,
                    height:
                        ResponsiveHelper.getIconSize(context, isSmall: true) +
                            2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.category.icon,
                      color: categoryColor,
                      size:
                          ResponsiveHelper.getIconSize(context, isSmall: true),
                    ),
                  ),

                SizedBox(width: isCompact ? 2 : 4),

                // 类别名称 - 使用与选中状态匹配的颜色
                Expanded(
                  child: Text(
                    widget.category.name,
                    style: (widget.isSelected ? selectedStyle : defaultStyle)
                        .copyWith(
                      color: textColor,
                      fontSize: fontSize,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 右侧选中指示器 - 使用小圆点表示选中
                if (widget.isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(left: isCompact ? 3 : 6),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建子类别项
  Widget _buildSecondaryItem(
      BuildContext context, DeviceType deviceType, bool isCompact) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color categoryColor = widget.category.color;
    final bool justSelected = widget.isSelected && !_wasSelected;

    // 根据设备类型调整图标大小和文本大小
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = deviceType == DeviceType.desktop && width > 1200;
    final isExtraLargeScreen = width > 1600;

    final iconSize = ResponsiveHelper.getIconSize(context, isSmall: !isCompact);
    final labelFontSize = deviceType == DeviceType.mobile
        ? (isCompact ? 10.0 : 11.0)
        : deviceType == DeviceType.tablet
            ? 12.0
            : isExtraLargeScreen
                ? 14.0
                : 13.0; // 大屏幕上使用更大字体

    // 使用LayoutBuilder代替固定尺寸，确保布局适应父容器
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算可用高度，确定各组件的大小
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // 根据屏幕大小调整图标容器比例
        final double iconContainerRatio = isExtraLargeScreen
            ? 0.55 // 超大屏幕上图标容器更大
            : isLargeScreen
                ? 0.52 // 大屏幕
                : isCompact
                    ? 0.46 // 紧凑模式
                    : 0.5; // 标准尺寸

        final double iconContainerSize = availableHeight * iconContainerRatio;

        // 根据屏幕大小调整文本区域高度比例
        final double textHeightRatio = isLargeScreen ? 0.38 : 0.35;
        final double maxTextHeight = availableHeight * textHeightRatio;

        // 使用SizedBox约束大小
        return SizedBox(
          height: availableHeight,
          child: Stack(
            children: [
              // 主内容列
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 图标容器 - 无动画效果
                    Container(
                      width: iconContainerSize,
                      height: iconContainerSize,
                      decoration: BoxDecoration(
                        // 图标容器使用透明背景
                        color: isDarkMode
                            ? theme.colorScheme.surfaceContainerHighest
                                .withOpacity(widget.isSelected ? 0.25 : 0.2)
                            : theme.colorScheme.surfaceContainerHighest
                                .withOpacity(widget.isSelected ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(16),
                        // 选中状态使用类别颜色的边框
                        border: Border.all(
                          color: widget.isSelected
                              ? categoryColor
                              : isDarkMode
                                  ? theme.colorScheme.outline.withOpacity(0.1)
                                  : theme.colorScheme.outline.withOpacity(0.12),
                          width: widget.isSelected
                              ? (isLargeScreen ? 2.2 : 1.8) // 大屏幕上边框更粗
                              : 0.5,
                        ),
                        // 添加阴影效果，提高立体感
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: categoryColor.withValues(alpha: 0.2),
                                  blurRadius: isLargeScreen ? 6 : 4,
                                  spreadRadius: isLargeScreen ? 1 : 0,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          widget.category.icon,
                          size: iconSize,
                          // 图标始终使用类别颜色
                          color: categoryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 2), // 最小间距

                    // 类别名称
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxTextHeight,
                          maxWidth: availableWidth - 4,
                        ),
                        child: Text(
                          widget.category.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: labelFontSize,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            // 选中状态下使用类别颜色
                            color: widget.isSelected
                                ? categoryColor
                                : isDarkMode
                                    ? theme.colorScheme.onSurface
                                        .withOpacity(0.85)
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.9),
                            height: 1.0,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // 选中指示器条 - 无动画效果
                    SizedBox(
                      height: isLargeScreen ? 6 : 4, // 大屏幕上使用更高的容器
                      child: Center(
                        child: widget.isSelected
                            ? Container(
                                width: isLargeScreen ? 25 : 20,
                                height: isLargeScreen ? 3 : 2,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  borderRadius: BorderRadius.circular(
                                      isLargeScreen ? 1.5 : 1),
                                ),
                              )
                            : const SizedBox(), // 未选中时不显示
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
