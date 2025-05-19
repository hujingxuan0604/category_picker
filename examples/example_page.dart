import 'package:category_picker/src/controllers/picker_controller.dart';
import 'package:category_picker/src/models/category.dart';
import 'package:category_picker/src/models/picker_config.dart';
import 'package:category_picker/src/widgets/picker_widget.dart';
import 'package:category_picker/src/widgets/color_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '分类选择器示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: CategoryPickerDemo(toggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 分类示例的主页
class CategoryPickerDemo extends StatefulWidget {
  final VoidCallback toggleTheme;

  const CategoryPickerDemo({
    super.key,
    required this.toggleTheme,
  });

  @override
  State<CategoryPickerDemo> createState() => _CategoryPickerDemoState();
}

class _CategoryPickerDemoState extends State<CategoryPickerDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CategoryPickerController _productPickerController;
  late CategoryPickerController _servicePickerController;

  // 分类数据
  final List<Category> _productCategories = [];
  final List<Category> _serviceCategories = [];

  // 选中的分类
  List<Category> _selectedProductCategories = [];
  List<Category> _selectedServiceCategories = [];

  // 颜色选择器示例数据
  Color _selectedColor = Colors.blue;
  final List<Color> _recentColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeCategories();

    // 初始化控制器
    _productPickerController =
        CategoryPickerController(categories: _productCategories);
    _servicePickerController =
        CategoryPickerController(categories: _serviceCategories);

    // 设置产品分类监听器
    _productPickerController.addListener(() {
      if (_tabController.index == 0) {
        setState(() {
          _selectedProductCategories =
              _productPickerController.selectedCategories;
        });
      }
    });

    // 设置服务分类监听器
    _servicePickerController.addListener(() {
      if (_tabController.index == 1) {
        setState(() {
          _selectedServiceCategories =
              _servicePickerController.selectedCategories;
        });
      }
    });

    // 添加Tab控制器监听
    _tabController.addListener(() {
      setState(() {}); // 刷新界面以更新显示
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productPickerController.dispose();
    _servicePickerController.dispose();
    super.dispose();
  }

  /// 初始化分类数据
  void _initializeCategories() {
    // 初始化产品分类
    _productCategories.addAll([
      Category(
        id: 'electronics',
        name: '电子产品',
        icon: Icons.electrical_services,
        color: Colors.blue,
        children: [
          Category(
              id: 'smartphones',
              name: '智能手机',
              icon: Icons.phone_iphone,
              parentId: 'electronics'),
          Category(
              id: 'laptops',
              name: '笔记本电脑',
              icon: Icons.laptop_mac,
              parentId: 'electronics'),
          Category(
              id: 'tablets',
              name: '平板电脑',
              icon: Icons.tablet_mac,
              parentId: 'electronics'),
          Category(
              id: 'accessories',
              name: '配件',
              icon: Icons.headset,
              parentId: 'electronics'),
        ],
      ),
      Category(
        id: 'clothing',
        name: '服装',
        icon: Icons.shopping_bag,
        color: Colors.purple,
        children: [
          Category(
              id: 'mens', name: "男装", icon: Icons.man, parentId: 'clothing'),
          Category(
              id: 'womens',
              name: "女装",
              icon: Icons.woman,
              parentId: 'clothing'),
          Category(
              id: 'kids',
              name: "童装",
              icon: Icons.child_care,
              parentId: 'clothing'),
        ],
      ),
    ]);

    // 初始化服务分类
    _serviceCategories.addAll([
      Category(
        id: 'education',
        name: '教育培训',
        icon: Icons.school,
        color: Colors.orange,
        children: [
          Category(
              id: 'language',
              name: '语言培训',
              icon: Icons.language,
              parentId: 'education'),
          Category(
              id: 'programming',
              name: '编程培训',
              icon: Icons.code,
              parentId: 'education'),
          Category(
              id: 'music',
              name: '音乐培训',
              icon: Icons.music_note,
              parentId: 'education'),
        ],
      ),
      Category(
        id: 'health',
        name: '健康医疗',
        icon: Icons.medical_services,
        color: Colors.red,
        children: [
          Category(
              id: 'fitness',
              name: '健身服务',
              icon: Icons.fitness_center,
              parentId: 'health'),
          Category(
              id: 'massage', name: '按摩理疗', icon: Icons.spa, parentId: 'health'),
          Category(
              id: 'medical',
              name: '医疗服务',
              icon: Icons.local_hospital,
              parentId: 'health'),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDarkMode, theme),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // 产品分类Tab
            _buildCategoryTab(_productPickerController),
            // 服务分类Tab
            _buildCategoryTab(_servicePickerController),
            // 颜色选择器Tab
            _buildColorPickerTab(),
          ],
        ),
      ),
      bottomNavigationBar:
          _tabController.index == 2 ? null : _buildBottomInfoBar(theme),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(bool isDarkMode, ThemeData theme) {
    return AppBar(
      title: const Text('分类选择器'),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDarkMode ? '切换到亮色模式' : '切换到深色模式',
          onPressed: widget.toggleTheme,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: '产品分类', icon: Icon(Icons.shopping_cart)),
          Tab(text: '服务分类', icon: Icon(Icons.medical_services)),
          Tab(text: '颜色选择器', icon: Icon(Icons.color_lens)),
        ],
      ),
    );
  }

  /// 构建分类选项卡内容
  Widget _buildCategoryTab(CategoryPickerController controller) {
    return Column(
      children: [
        Expanded(
          child: CategoryPickerWidget(
            controller: controller,
            config: const CategoryPickerConfig(
              showSearch: true,
              defaultIcon: Icons.category,
              showAddButtonInSecondary: true,
              addCategoryText: '添加子类别',
            ),
            onLongPressPrimary: _handleLongPressPrimary,
            onLongPressSecondary: _handleLongPressSecondary,
            onAddCategory: _handleAddCategory,
          ),
        ),
      ],
    );
  }

  /// 构建底部信息栏
  Widget _buildBottomInfoBar(ThemeData theme) {
    final currentTabIndex = _tabController.index;
    final selectedCategories = currentTabIndex == 0
        ? _selectedProductCategories
        : _selectedServiceCategories;
    final controller = currentTabIndex == 0
        ? _productPickerController
        : _servicePickerController;

    // 获取当前选中的主类别名称
    String currentPrimaryName = '未选择';
    if (controller.selectedPrimary != null) {
      currentPrimaryName = controller.selectedPrimary!.name;
    }

    // 获取所有主类别ID和子类别ID
    final primaryIds = <String>{};
    final secondaryIds = <String>{};

    for (final category in selectedCategories) {
      if (category.isMainCategory) {
        primaryIds.add(category.id);
      } else {
        secondaryIds.add(category.id);
        if (category.parentId != null) {
          primaryIds.add(category.parentId!);
        }
      }
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.6),
              theme.colorScheme.primaryContainer.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '已选分类信息',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoItem(
              icon: Icons.view_list,
              label: '当前主类别',
              value: currentPrimaryName,
              context: context,
            ),
            _buildInfoItem(
              icon: Icons.folder,
              label: '主类别ID',
              value: primaryIds.isEmpty ? '未选择' : primaryIds.join(', '),
              context: context,
            ),
            _buildInfoItem(
              icon: Icons.bookmark,
              label: '子类别ID',
              value: secondaryIds.isEmpty ? '未选择' : secondaryIds.join(', '),
              context: context,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) const SizedBox(height: 12),
      ],
    );
  }

  /// 处理主类别长按事件
  void _handleLongPressPrimary(Category category) {
    final currentTabIndex = _tabController.index;
    String tabName = currentTabIndex == 0 ? "产品" : "服务";

    _showCategoryActionSheet(
      category: category,
      isPrimary: true,
      tabName: tabName,
    );
  }

  /// 处理子类别长按事件
  void _handleLongPressSecondary(Category category) {
    final currentTabIndex = _tabController.index;
    String tabName = currentTabIndex == 0 ? "产品" : "服务";

    _showCategoryActionSheet(
      category: category,
      isPrimary: false,
      tabName: tabName,
    );
  }

  /// 处理添加子类别事件
  void _handleAddCategory(Category? parentCategory) {
    final currentTabIndex = _tabController.index;
    String tabName = currentTabIndex == 0 ? "产品" : "服务";

    if (parentCategory == null) {
      _showAddMainCategoryDialog(tabName);
    } else {
      _showAddSubcategoryDialog(parentCategory);
    }
  }

  /// 显示添加主类别对话框
  void _showAddMainCategoryDialog(String tabName) {
    final controller = _tabController.index == 0
        ? _productPickerController
        : _servicePickerController;

    // 实际项目中应实现添加主类别的对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('添加${tabName}主类别'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 显示类别操作底部菜单
  void _showCategoryActionSheet({
    required Category category,
    required bool isPrimary,
    required String tabName,
  }) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 底部菜单拖拽条
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 类别信息栏
                _buildCategoryInfoHeader(category, isPrimary, tabName, theme),
                const Divider(),
                // 操作列表
                _buildActionTile(
                  icon: Icons.edit_outlined,
                  iconColor: theme.colorScheme.primary,
                  title: '编辑${isPrimary ? "主" : "子"}类别',
                  subtitle: '修改名称、图标和颜色',
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCategoryDialog(category, isPrimary);
                  },
                ),
                if (isPrimary && category.hasChildren)
                  _buildActionTile(
                    icon: Icons.add_circle_outline,
                    iconColor: theme.colorScheme.primary,
                    title: '添加子类别',
                    subtitle: '向 ${category.name} 添加新的子类别',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddSubcategoryDialog(category);
                    },
                  ),
                _buildActionTile(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: '删除${isPrimary ? "主" : "子"}类别',
                  titleColor: Colors.red,
                  subtitle: isPrimary && category.hasChildren
                      ? '警告：将同时删除所有子类别'
                      : '从列表中移除此类别',
                  subtitleColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(category, isPrimary);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建类别信息头部
  Widget _buildCategoryInfoHeader(
      Category category, bool isPrimary, String tabName, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color?.withOpacity(0.2) ??
                  theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category.icon ?? Icons.category,
              color: category.color ?? theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${isPrimary ? "$tabName主类别" : "$tabName子类别"} · ID: ${category.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作列表项
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    Color? subtitleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: Text(subtitle, style: TextStyle(color: subtitleColor)),
      onTap: onTap,
    );
  }

  /// 显示编辑类别对话框
  void _showEditCategoryDialog(Category category, bool isPrimary) {
    // 实际项目中应实现编辑类别的对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('编辑${isPrimary ? "主" : "子"}类别: ${category.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 显示添加子类别对话框
  void _showAddSubcategoryDialog(Category parentCategory) {
    // 实际项目中应实现添加子类别的对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('向 ${parentCategory.name} 添加子类别'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(Category category, bool isPrimary) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除${isPrimary ? "主" : "子"}类别'),
        content: Text(isPrimary && category.hasChildren
            ? '确定要删除 ${category.name} 及其所有子类别吗？此操作不可恢复。'
            : '确定要删除 ${category.name} 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('取消', style: TextStyle(color: theme.colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category, isPrimary);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 删除类别
  void _deleteCategory(Category category, bool isPrimary) {
    // 实际项目中应实现删除类别的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除: ${category.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 构建颜色选择器标签页
  Widget _buildColorPickerTab() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '颜色选择器示例',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 当前选中的颜色展示
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '已选颜色',
                    style: TextStyle(
                      color: _isColorBright(_selectedColor)
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 颜色值信息
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HEX', style: theme.textTheme.titleSmall),
                          Text(
                            '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RGB', style: theme.textTheme.titleSmall),
                          Text(
                            'R: ${_selectedColor.red}, G: ${_selectedColor.green}, B: ${_selectedColor.blue}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 基本颜色选择器
            Text(
              '基本颜色选择器',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ColorPickerTile(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                  if (!_recentColors.contains(color)) {
                    _recentColors.insert(0, color);
                    if (_recentColors.length > 5) {
                      _recentColors.removeLast();
                    }
                  }
                });
              },
            ),

            const SizedBox(height: 24),

            // 自定义颜色选项
            Text(
              '自定义颜色集',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ColorPickerTile(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              colors: const [
                Colors.redAccent,
                Colors.pinkAccent,
                Colors.purpleAccent,
                Colors.deepPurpleAccent,
                Colors.indigoAccent,
                Colors.blueAccent,
                Colors.lightBlueAccent,
                Colors.cyanAccent,
                Colors.tealAccent,
                Colors.greenAccent,
                Colors.lightGreenAccent,
                Colors.limeAccent,
                Colors.yellowAccent,
                Colors.amberAccent,
                Colors.orangeAccent,
                Colors.deepOrangeAccent,
              ],
            ),

            const SizedBox(height: 24),

            // 最近使用的颜色
            Text(
              '最近使用的颜色',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ColorPickerTile(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              colors: _recentColors,
              showCustomColorOption: false,
            ),
          ],
        ),
      ),
    );
  }

  // 判断颜色是否明亮
  bool _isColorBright(Color color) {
    return (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) /
            255 >
        0.5;
  }
}
