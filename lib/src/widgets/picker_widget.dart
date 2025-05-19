import 'package:flutter/material.dart';
import '../controllers/picker_controller.dart';
import '../models/picker_config.dart';
import '../models/category.dart';
import '../utils/responsive_helper.dart';
import 'primary_panel.dart';
import 'secondary_panel.dart';
import 'color_picker.dart';

class CategoryPickerWidget extends StatefulWidget {
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

  /// 选择主类别的回调函数
  final Function(Category category)? onSelectPrimary;

  /// 选择子类别的回调函数
  final Function(Category category)? onSelectSecondary;

  /// 点击管理按钮的回调函数
  final VoidCallback? onManagePressed;

  const CategoryPickerWidget({
    super.key,
    required this.controller,
    this.config = const CategoryPickerConfig(),
    this.onLongPressPrimary,
    this.onLongPressSecondary,
    this.onAddCategory,
    this.onSelectPrimary,
    this.onSelectSecondary,
    this.onManagePressed,
  });

  @override
  State<CategoryPickerWidget> createState() => _CategoryPickerWidgetState();
}

class _CategoryPickerWidgetState extends State<CategoryPickerWidget> {
  final TextEditingController _searchController = TextEditingController();

  CategoryPickerController get _controller => widget.controller;

  // 使用ValueNotifier来管理UI的各部分状态，避免不必要的重建
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final ValueNotifier<Category?> _selectedPrimaryNotifier =
      ValueNotifier<Category?>(null);
  final ValueNotifier<Color> _selectedColorNotifier =
      ValueNotifier<Color>(Colors.blue);

  // 添加一个标志，防止连续触发多次UI更新
  bool _pendingUIUpdate = false;

  @override
  void initState() {
    super.initState();
    // 监听搜索框的变化
    _searchController.addListener(_onSearchChanged);

    // 初始化状态
    _selectedPrimaryNotifier.value = _controller.selectedPrimary;
    _selectedColorNotifier.value = _controller.selectedColor;

    // 监听控制器变化
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    // 移除所有监听器
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _controller.removeListener(_onControllerChanged);

    // 销毁ValueNotifier
    _searchQueryNotifier.dispose();
    _selectedPrimaryNotifier.dispose();
    _selectedColorNotifier.dispose();

    super.dispose();
  }

  /// 控制器变化时更新UI状态
  void _onControllerChanged() {
    // 检查主类别是否发生变化
    final currentSelectedPrimary = _controller.selectedPrimary;
    if (_selectedPrimaryNotifier.value?.id != currentSelectedPrimary?.id) {
      // 主类别发生变化，立即更新状态
      _selectedPrimaryNotifier.value = currentSelectedPrimary;

      // 用单个微任务执行UI更新，避免连续多次重绘
      if (!_pendingUIUpdate) {
        _pendingUIUpdate = true;
        Future.microtask(() {
          if (mounted) {
            setState(() {
              // 这个setState只是触发一次重建，不需要更新任何状态
              _pendingUIUpdate = false;
            });
          } else {
            _pendingUIUpdate = false;
          }
        });
      }
    }

    // 更新颜色选择器状态
    if (_selectedColorNotifier.value != _controller.selectedColor) {
      _selectedColorNotifier.value = _controller.selectedColor;
    }

    // 只有当搜索查询变化时才更新，避免不必要的重建
    if (_searchQueryNotifier.value != _controller.searchQuery) {
      _searchQueryNotifier.value = _controller.searchQuery;
      // 同步搜索框和控制器状态
      if (_searchController.text != _controller.searchQuery) {
        _searchController.text = _controller.searchQuery;
      }
    }
  }

  /// 搜索内容变化
  void _onSearchChanged() {
    final query = _searchController.text;
    if (_searchQueryNotifier.value != query) {
      _searchQueryNotifier.value = query;
      _controller.updateSearchQuery(query);
    }
  }

  /// 清除搜索内容
  void _clearSearch() {
    _searchController.clear();
    _controller.updateSearchQuery('');
  }

  /// 选择颜色
  void _onColorSelected(Color color) {
    _controller.updateSelectedColor(color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      color: isDarkMode
          ? theme.colorScheme.surface.withValues(alpha: 0.95)
          : theme.colorScheme.surface,
      elevation: 0,
      child: Column(
        children: [
          // 标题和搜索区域 - 根据配置决定是否显示
          if (widget.config.showHeader == true) _buildHeader(theme),

          // 搜索框
          if (widget.config.showSearch)
            ValueListenableBuilder<String>(
              valueListenable: _searchQueryNotifier,
              builder: (context, query, child) => _buildSearchBar(theme, query),
            ),

          // 颜色选择器
          if (widget.config.showColorPicker)
            ValueListenableBuilder<Color>(
              valueListenable: _selectedColorNotifier,
              builder: (context, color, child) =>
                  _buildColorPicker(theme, color),
            ),

          // 类别选择区域
          Expanded(
            child: _buildLayout(),
          ),
        ],
      ),
    );
  }

  /// 构建头部标题区域
  Widget _buildHeader(ThemeData theme) {
    final Color primaryColor = theme.colorScheme.primary;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 18, 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surface.withValues(alpha: 0.95)
            : theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 标题和图标
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.category_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.config.headerText,
                style: TextStyle(
                  color: isDarkMode
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.95)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          // 管理按钮（如果启用）
          if (widget.config.showManageButton && widget.onManagePressed != null)
            TextButton.icon(
              onPressed: widget.onManagePressed,
              icon: const Icon(Icons.settings, size: 16),
              label: Text(widget.config.manageButtonText),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar(ThemeData theme, String query) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 18, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4)
                  : theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? theme.colorScheme.outline.withValues(alpha: 0.2)
                    : theme.colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? theme.shadowColor.withValues(alpha: 0.08)
                      : theme.shadowColor.withValues(alpha: 0.03),
                  blurRadius: isDarkMode ? 4 : 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // 搜索图标
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.search,
                    size: 20,
                    color: isDarkMode
                        ? theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.9)
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.8),
                  ),
                ),

                // 输入框
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: '搜索类别',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7)
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                // 清除按钮
                if (query.isNotEmpty)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _clearSearch,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.cancel,
                          size: 18,
                          color: isDarkMode
                              ? theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.8)
                              : theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建颜色选择器
  Widget _buildColorPicker(ThemeData theme, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 18, 8),
      child: ColorPickerTile(
        selectedColor: color,
        colors: widget.config.availableColors,
        onColorSelected: _onColorSelected,
      ),
    );
  }

  /// 构建主要布局
  Widget _buildLayout() {
    double primaryWidth;
    if (widget.config.primaryPanelWidth != null) {
      primaryWidth = widget.config.primaryPanelWidth!;
    } else {
      primaryWidth = MediaQuery.of(context).size.width *
          widget.config.primaryPanelWidthRatio;
    }

    // 使用AnimatedBuilder监听控制器变化，确保主类别面板和子类别面板的及时更新
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          children: [
            // 主类别面板
            SizedBox(
              width: primaryWidth,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: ResponsiveHelper.getDeviceType(context) ==
                              DeviceType.desktop
                          ? Colors.transparent // 大屏幕上不需要边界线，因为已添加阴影效果
                          : Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                // 使用ValueListenableBuilder以响应selectedPrimaryNotifier的变化
                child: PrimaryCategoryPanel(
                  controller: _controller,
                  config: widget.config,
                  onLongPressPrimary: widget.onLongPressPrimary,
                  onCategoryTap: (category) {
                    // 立即更新本地Notifier以便立即反映到UI
                    _selectedPrimaryNotifier.value = category;
                    // 同时更新控制器状态
                    _controller.selectPrimaryCategory(category);
                    // 触发外部选择回调
                    if (widget.onSelectPrimary != null) {
                      widget.onSelectPrimary!(category);
                    }
                  },
                ),
              ),
            ),

            // 次级类别面板
            Expanded(
              child: SecondaryCategoryPanel(
                controller: _controller,
                config: widget.config,
                onLongPressSecondary: widget.onLongPressSecondary,
                onAddCategory: widget.onAddCategory,
                onCategoryTap: (category) {
                  _controller.toggleCategorySelection(category);
                  // 触发外部选择回调
                  if (widget.onSelectSecondary != null) {
                    widget.onSelectSecondary!(category);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
