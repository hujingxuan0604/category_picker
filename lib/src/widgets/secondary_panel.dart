import 'package:flutter/material.dart';

import '../controllers/picker_controller.dart';
import '../models/picker_config.dart';
import '../models/category.dart';
import '../utils/responsive_helper.dart';
import 'category_item.dart';

class SecondaryCategoryPanel extends StatelessWidget {
  final CategoryPickerController controller;
  final CategoryPickerConfig config;

  /// 长按子类别的回调函数
  final Function(Category category)? onLongPressSecondary;

  /// 添加子类别的回调函数
  final Function(Category? parentCategory)? onAddCategory;

  /// 点击类别的回调函数
  final Function(Category category)? onCategoryTap;

  const SecondaryCategoryPanel({
    super.key,
    required this.controller,
    required this.config,
    this.onLongPressSecondary,
    this.onAddCategory,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPrimary = controller.selectedPrimary;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (selectedPrimary == null) {
      return _buildEmptyState(
        context,
        '请先选择一个主类别',
        Icons.arrow_back,
      );
    }

    final secondaryCategories = controller.filteredSecondaryCategories;

    if (secondaryCategories == null || secondaryCategories.isEmpty) {
      // 检查是否由于搜索导致的空结果
      if (controller.searchQuery.isNotEmpty) {
        return _buildEmptyState(
          context,
          '没有找到匹配的子类别',
          Icons.search_off,
        );
      }

      // 真正的空子类别
      return _buildEmptyStateWithAction(
        context,
        selectedPrimary,
        '该类别下暂无子类别',
        Icons.category_outlined,
      );
    }

    // 获取响应式布局参数
    final padding = ResponsiveHelper.getPadding(context, isSmall: true);
    final isCompact = ResponsiveHelper.shouldUseCompactLayout(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类别标题
          _buildHeader(context, selectedPrimary, isDarkMode, theme, isCompact),

          // 子类别网格
          Expanded(
            child: _buildSecondaryGrid(context, secondaryCategories),
          ),
        ],
      ),
    );
  }

  /// 构建标题
  Widget _buildHeader(BuildContext context, Category selectedPrimary,
      bool isDarkMode, ThemeData theme, bool isCompact) {
    final headerPadding = EdgeInsets.fromLTRB(
        ResponsiveHelper.getPadding(context, isSmall: true),
        ResponsiveHelper.getPadding(context, isSmall: true) / 2,
        ResponsiveHelper.getPadding(context, isSmall: true),
        ResponsiveHelper.getPadding(context, isSmall: false) / 2);

    // 根据屏幕大小和方向调整布局
    return Padding(
      padding: headerPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${selectedPrimary.name}下的子类别',
              style: TextStyle(
                fontSize: 14 * ResponsiveHelper.getTextScaleFactor(context),
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.9)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (config.showAddButtonInSecondary && onAddCategory != null)
            TextButton.icon(
              onPressed: () => onAddCategory?.call(selectedPrimary),
              icon: Icon(
                Icons.add,
                size: ResponsiveHelper.getIconSize(context, isSmall: true),
              ),
              label: Text(
                isCompact ? '添加' : config.addCategoryText,
                style: TextStyle(
                  fontSize: isCompact ? 11 : 12,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      ResponsiveHelper.getPadding(context, isSmall: true),
                ),
                visualDensity: VisualDensity.compact,
                textStyle: TextStyle(
                  fontSize: 12 * ResponsiveHelper.getTextScaleFactor(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建子类别网格
  Widget _buildSecondaryGrid(BuildContext context, List<Category> categories) {
    final selectedPrimaryId = controller.selectedPrimary?.id ?? 'none';
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final crossAxisCount =
        ResponsiveHelper.getSecondaryGridCrossAxisCount(context);
    final aspectRatio = ResponsiveHelper.getSecondaryItemAspectRatio(context);
    final padding = ResponsiveHelper.getPadding(context, isSmall: true);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 大屏幕上使用更大的间距
    double width = MediaQuery.of(context).size.width;
    final isExtraLargeScreen = width > 1600;

    final gridPadding = deviceType == DeviceType.desktop
        ? EdgeInsets.symmetric(
            horizontal: isExtraLargeScreen ? padding * 2.0 : padding * 1.6,
            vertical: isExtraLargeScreen ? padding * 1.6 : padding * 1.2)
        : EdgeInsets.symmetric(horizontal: padding, vertical: padding);

    // 大屏幕上改进间距，使布局更加宽松舒适
    final crossAxisSpacing = deviceType == DeviceType.desktop
        ? isExtraLargeScreen
            ? padding * 2.0
            : padding * 1.6 // 大屏幕上的列间距
        : padding;

    final mainAxisSpacing = deviceType == DeviceType.desktop
        ? isExtraLargeScreen
            ? padding * 1.5
            : padding * 1.2 // 大屏幕上的行间距
        : padding / 2;

    // 创建美观的网格视图
    final gridView = GridView.builder(
      // 使用包含主类别ID的key，确保在主类别变化时完全重建
      key: PageStorageKey<String>('secondary_grid_$selectedPrimaryId'),
      padding: gridPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = controller.selectedCategories.contains(category);

        // 使用唯一key帮助Flutter优化重建
        return KeyedSubtree(
          key: ValueKey('secondary_${selectedPrimaryId}_${category.id}'),
          child: CategoryItem(
            category: category,
            isSelected: isSelected,
            isPrimary: false,
            config: config,
            onTap: () {
              if (onCategoryTap != null) {
                // 使用microtask确保在下一个UI渲染周期执行
                Future.microtask(() => onCategoryTap!(category));
              }
            },
            onLongPress: onLongPressSecondary,
          ),
        );
      },
    );

    // 在大屏幕上使用装饰容器增强视觉效果
    if (deviceType == DeviceType.desktop) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? theme.colorScheme.surface.withValues(alpha: 0.97)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(isExtraLargeScreen ? 8 : 4),
          // 添加轻微阴影增强立体感
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(
          vertical: isExtraLargeScreen ? padding : padding / 2,
          horizontal: isExtraLargeScreen ? padding : padding / 2,
        ),
        child: gridView,
      );
    }

    return gridView;
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    final theme = Theme.of(context);
    final textScale = ResponsiveHelper.getTextScaleFactor(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48 * textScale,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context)),
          Text(
            message,
            style: TextStyle(
              fontSize: 14 * textScale,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建带操作的空状态
  Widget _buildEmptyStateWithAction(
    BuildContext context,
    Category parentCategory,
    String message,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final textScale = ResponsiveHelper.getTextScaleFactor(context);
    final padding = ResponsiveHelper.getPadding(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48 * textScale,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          SizedBox(height: padding),
          Text(
            message,
            style: TextStyle(
              fontSize: 14 * textScale,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (config.showAddButtonInSecondary && onAddCategory != null) ...[
            SizedBox(height: padding),
            ElevatedButton.icon(
              onPressed: () => onAddCategory?.call(parentCategory),
              icon: Icon(
                Icons.add,
                size: ResponsiveHelper.getIconSize(context, isSmall: true),
              ),
              label: Text(
                config.addCategoryText,
                style: TextStyle(fontSize: 14 * textScale),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding / 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
