import 'package:flutter/material.dart';
import 'package:category_picker/src/controllers/picker_controller.dart';
import 'package:category_picker/src/models/picker_config.dart';
import 'package:category_picker/src/models/category.dart';

import 'category_item.dart';

class SecondaryCategoryPanel extends StatelessWidget {
  final CategoryPickerController controller;
  final CategoryPickerConfig config;

  /// 长按子类别的回调函数
  final Function(Category category)? onLongPressSecondary;

  /// 添加子类别的回调函数
  final Function(Category? parentCategory)? onAddCategory;

  const SecondaryCategoryPanel({
    super.key,
    required this.controller,
    required this.config,
    this.onLongPressSecondary,
    this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = controller.filteredSecondaryCategories;
    final theme = Theme.of(context);

    if (categories == null || categories.isEmpty) {
      if (controller.selectedPrimary != null &&
          config.showAddButtonInSecondary) {
        // 如果有选中的主类别且配置显示添加按钮，即使没有子类别也显示添加按钮
        return _buildEmptyWithAddButton(context, controller.selectedPrimary!);
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 56,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              categories == null ? '请选择一个分类' : config.emptyText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (controller.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '没有符合"${controller.searchQuery}"的子类别',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // 计算合适的列数，根据屏幕宽度动态调整
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryPanelWidth = screenWidth * config.primaryPanelWidthRatio;
    final remainingWidth = screenWidth - primaryPanelWidth;
    // 固定显示4列
    final crossAxisCount = 4;

    return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          // 在列表中添加"添加子类别"按钮
          final displayCategories = controller.searchQuery.isEmpty &&
                  config.showAddButtonInSecondary &&
                  controller.selectedPrimary != null
              ? [null, ...categories] // null 作为添加按钮的占位符
              : categories;

          // 当前选中主类别
          final selectedPrimary = controller.selectedPrimary;
          final categoryColor =
              selectedPrimary?.color ?? config.defaultSelectedColor;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 子类别数量指示器
              if (selectedPrimary != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                  child: Row(
                    children: [
                      Text(
                        '子类别',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${categories.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (controller.searchQuery.isNotEmpty)
                        Text(
                          '搜索结果: ${controller.searchQuery}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),

              // 子类别网格
              Expanded(
                child: GridView.builder(
                  key: ValueKey(
                      'grid_${controller.selectedPrimary?.id}_${controller.searchQuery}'),
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: displayCategories.length,
                  itemBuilder: (context, index) {
                    // 如果是添加按钮位置，需要调整索引获取实际的类别
                    if (config.showAddButtonInSecondary &&
                        index == 0 &&
                        controller.searchQuery.isEmpty) {
                      return _buildAddCategoryButton(
                          context, controller.selectedPrimary);
                    }

                    final actualIndex = config.showAddButtonInSecondary &&
                            controller.searchQuery.isEmpty
                        ? index - 1
                        : index;
                    final category = categories[actualIndex];
                    final isSelected =
                        controller.selectedCategories.contains(category);

                    return CategoryItem(
                      category: category,
                      isSelected: isSelected,
                      isPrimary: false,
                      config: config,
                      onTap: () => controller.toggleCategorySelection(category),
                      onLongPress: onLongPressSecondary,
                    );
                  },
                ),
              ),
            ],
          );
        });
  }

  /// 构建添加子类别按钮
  Widget _buildAddCategoryButton(
      BuildContext context, Category? parentCategory) {
    final theme = Theme.of(context);
    final categoryColor = parentCategory?.color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        if (onAddCategory != null) {
          onAddCategory!(parentCategory);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标带圆形背景
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: 18,
                color: categoryColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            config.addCategoryText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: categoryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 构建空视图但带有添加按钮
  Widget _buildEmptyWithAddButton(
      BuildContext context, Category parentCategory) {
    final theme = Theme.of(context);
    final categoryColor = parentCategory.color ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主类别标题栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (parentCategory.icon != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    parentCategory.icon ?? Icons.category,
                    color: categoryColor,
                    size: 16,
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  parentCategory.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // 空状态
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(16)
                      // border: Border.all(
                      //   color: categoryColor.withOpacity(0.2),
                      //   width: 1,
                      // ),
                      ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${parentCategory.name}还没有子类别',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (onAddCategory != null) {
                      onAddCategory!(parentCategory);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(config.addCategoryText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    elevation: 2,
                    backgroundColor: categoryColor.withOpacity(0.8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
