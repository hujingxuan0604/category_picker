import 'package:flutter/material.dart';
import '../controllers/picker_controller.dart';
import '../models/picker_config.dart';
import '../models/category.dart';
import '../utils/responsive_helper.dart';
import 'category_item.dart';

class PrimaryCategoryPanel extends StatelessWidget {
  final CategoryPickerController controller;
  final CategoryPickerConfig config;

  /// 长按主类别的回调函数
  final Function(Category category)? onLongPressPrimary;

  /// 点击类别的回调函数
  final Function(Category category)? onCategoryTap;

  const PrimaryCategoryPanel({
    super.key,
    required this.controller,
    required this.config,
    this.onLongPressPrimary,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = controller.filteredPrimaryCategories;
    final selectedPrimary = controller.selectedPrimary;
    final theme = Theme.of(context);
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final padding = ResponsiveHelper.getPadding(context, isSmall: true);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 在大屏幕上添加横向padding以增加美观度
    final horizontalPadding = deviceType == DeviceType.desktop ? 12.0 : 4.0;

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
          child: Text(
            config.emptyText,
            style: TextStyle(
              fontSize: 14 * ResponsiveHelper.getTextScaleFactor(context),
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final itemHeight = ResponsiveHelper.getPrimaryItemHeight(context);

    // 使用ListView.builder提高性能
    final listViewWidget = ListView.builder(
      // 添加关键缓存属性，优化滚动性能
      key: PageStorageKey<String>('primary_panel_${selectedPrimary?.id}'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: padding / 2,
        horizontal: horizontalPadding, // 水平内边距
      ),
      itemExtent: itemHeight,
      // 固定每项高度以提高性能
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedPrimary?.id == category.id;

        // 使用唯一key帮助Flutter识别和优化重建
        return KeyedSubtree(
          key: ValueKey('primary_${category.id}'),
          child: CategoryItem(
            category: category,
            isSelected: isSelected,
            isPrimary: true,
            config: config.copyWith(
              primaryItemHeight: itemHeight,
            ),
            onTap: () {
              if (onCategoryTap != null) {
                // 使用Future.microtask确保在下一个微任务循环中执行回调
                // 这可以帮助解决状态更新和UI渲染的同步问题
                Future.microtask(() => onCategoryTap!(category));
              }
            },
            onLongPress: onLongPressPrimary,
          ),
        );
      },
      // 添加缓存范围，优化内存使用
      cacheExtent: itemHeight * 10, // 预缓存10个项目的高度
    );

    // 针对大屏幕添加装饰容器
    if (deviceType == DeviceType.desktop) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? theme.colorScheme.surface.withValues(alpha: 0.95)
              : theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border(
            right: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        child: listViewWidget,
      );
    }

    // 其他设备直接返回列表
    return listViewWidget;
  }
}
