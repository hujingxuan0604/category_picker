import 'package:flutter/material.dart';
import 'package:category_picker/src/controllers/picker_controller.dart';
import 'package:category_picker/src/models/picker_config.dart';
import 'package:category_picker/src/models/category.dart';
import 'package:category_picker/src/widgets/primary_panel.dart';
import 'package:category_picker/src/widgets/secondary_panel.dart';

class HierarchicalCategoryPicker extends StatefulWidget {
  /// 控制器
  final CategoryPickerController controller;

  /// 配置
  final CategoryPickerConfig config;

  /// 长按主类别的回调函数
  final Function(Category category)? onLongPressPrimary;

  /// 长按子类别的回调函数
  final Function(Category category)? onLongPressSecondary;

  /// 添加子类别的回调函数
  final Function(Category? parentCategory)? onAddCategory;

  const HierarchicalCategoryPicker({
    super.key,
    required this.controller,
    this.config = const CategoryPickerConfig(),
    this.onLongPressPrimary,
    this.onLongPressSecondary,
    this.onAddCategory,
  });

  @override
  State<HierarchicalCategoryPicker> createState() =>
      _HierarchicalCategoryPickerState();
}

class _HierarchicalCategoryPickerState
    extends State<HierarchicalCategoryPicker> {
  final TextEditingController _searchController = TextEditingController();
  CategoryPickerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    // 监听搜索框的变化
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// 搜索内容变化
  void _onSearchChanged() {
    _controller.updateSearchQuery(_searchController.text);
  }

  /// 清除搜索内容
  void _clearSearch() {
    _searchController.clear();
    _controller.updateSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            // 搜索区域
            Card(
              margin: const EdgeInsets.all(12),
              color: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 2,
              shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: brightness == Brightness.light
                        ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索类别...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _controller.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                              color: theme.colorScheme.onSurfaceVariant,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // 类别选择区域
            Expanded(
              child: Card(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                elevation: 2,
                color: theme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      // 主类别面板
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            widget.config.primaryPanelWidthRatio,
                        child: PrimaryCategoryPanel(
                          controller: _controller,
                          config: widget.config,
                          onLongPressPrimary: widget.onLongPressPrimary ??
                              _defaultPrimaryLongPress,
                        ),
                      ),

                      // 分隔线
                      Container(
                        width: 1,
                        color: theme.colorScheme.outline.withOpacity(
                          brightness == Brightness.light ? 0.15 : 0.25,
                        ),
                      ),

                      // 子类别面板
                      Expanded(
                        child: SecondaryCategoryPanel(
                          controller: _controller,
                          config: widget.config,
                          onLongPressSecondary: widget.onLongPressSecondary ??
                              _defaultSecondaryLongPress,
                          onAddCategory: widget.onAddCategory,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _defaultPrimaryLongPress(Category category) {
    final snackBar = SnackBar(
      content: Text('长按了主类别: ${category.name}'),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _defaultSecondaryLongPress(Category category) {
    final snackBar = SnackBar(
      content: Text('长按了子类别: ${category.name}'),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
