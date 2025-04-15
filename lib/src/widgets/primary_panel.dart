import 'package:flutter/material.dart';
import 'package:category_picker/src/controllers/picker_controller.dart';
import 'package:category_picker/src/models/picker_config.dart';
import 'package:category_picker/src/models/category.dart';

class PrimaryCategoryPanel extends StatelessWidget {
  final CategoryPickerController controller;
  final CategoryPickerConfig config;

  /// 长按主类别的回调函数
  final Function(Category category)? onLongPressPrimary;

  const PrimaryCategoryPanel({
    super.key,
    required this.controller,
    required this.config,
    this.onLongPressPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final categories = controller.filteredPrimaryCategories;
    final theme = Theme.of(context);

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.category_outlined,
                size: 40,
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                '没有找到相关类别',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // 搜索结果指示器
        if (controller.searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Text(
                  '搜索结果',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '"${controller.searchQuery}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${categories.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 主类别列表
        Expanded(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              // 使用Key确保在选择改变时重建
              final listKey = ValueKey(
                  'primary_list_${controller.selectedPrimary?.id}_${controller.searchQuery}');

              return ListView.builder(
                key: listKey,
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = controller.selectedPrimary == category;

                  // 自定义主类别项目
                  return _buildPrimaryCategoryItem(context, category,
                      isSelected, index == categories.length - 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建主类别项目
  Widget _buildPrimaryCategoryItem(
      BuildContext context, Category category, bool isSelected, bool isLast) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categoryColor = category.color ?? config.defaultSelectedColor;

    // 背景颜色和样式
    final backgroundColor =
        isSelected ? categoryColor.withOpacity(0.15) : Colors.transparent;

    final borderWidth = isSelected ? 2.0 : 0.0;
    final borderColor = isSelected ? categoryColor : Colors.transparent;
    final borderRadius = BorderRadius.circular(isSelected ? 8 : 0);

    // 文本样式
    final textColor = isSelected ? categoryColor : colorScheme.onSurface;
    final iconColor =
        isSelected ? categoryColor : categoryColor.withOpacity(0.7);

    return Container(
      margin: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 4,
        bottom: isLast ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: categoryColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectPrimaryCategory(category),
            onLongPress: onLongPressPrimary != null
                ? () => onLongPressPrimary!(category)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 图标和名称的上下结构
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 图标
                        if (config.showIcons &&
                            (category.icon != null ||
                                config.defaultIcon != null))
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: categoryColor
                                  .withOpacity(isSelected ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              category.icon ?? config.defaultIcon,
                              color: iconColor,
                              size: 20,
                            ),
                          ),
                        const SizedBox(height: 8),
                        // 文本
                        Text(
                          category.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isSelected)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: categoryColor,
                      size: 14,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
