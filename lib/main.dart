import 'package:category_picker/src/controllers/picker_controller.dart';
import 'package:category_picker/src/models/category.dart';
import 'package:category_picker/src/models/picker_config.dart';
import 'package:category_picker/src/widgets/picker_widget.dart';
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
  ThemeMode _themeMode = ThemeMode.dark; // 默认黑暗模式

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Category Picker Demo',
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
      home: CategoryPickerDemo(toggleTheme: toggleTheme),
    );
  }
}

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
  final List<Category> _productCategories = [];
  final List<Category> _serviceCategories = [];
  List<Category> _selectedProductCategories = [];
  List<Category> _selectedServiceCategories = [];
  String? _currentPrimaryId; // 当前选中的主类别ID
  late CategoryPickerController _productPickerController;
  late CategoryPickerController _servicePickerController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCategories();
    _productPickerController =
        CategoryPickerController(categories: _productCategories);
    _servicePickerController =
        CategoryPickerController(categories: _serviceCategories);

    // 设置产品分类监听器
    _productPickerController.addListener(() {
      if (_tabController.index == 0) {
        setState(() {
          // 我们不再需要专门更新_currentPrimaryId
          // 只需要更新选中的类别列表即可
          _selectedProductCategories =
              _productPickerController.selectedCategories;
        });
      }
    });

    // 设置服务分类监听器
    _servicePickerController.addListener(() {
      if (_tabController.index == 1) {
        setState(() {
          // 我们不再需要专门更新_currentPrimaryId
          // 只需要更新选中的类别列表即可
          _selectedServiceCategories =
              _servicePickerController.selectedCategories;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productPickerController.dispose();
    _servicePickerController.dispose();
    super.dispose();
  }

  void _initializeCategories() {
    // 初始化产品分类
    _productCategories.addAll([
      Category(
        id: 'electronics',
        name: '产品',
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
      appBar: AppBar(
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
          onTap: (index) {
            // 切换Tab时更新当前主类别信息
            setState(() {
              // 无需再更新_currentPrimaryId，因为我们现在直接从controller获取主类别名称

              // 主要目的是触发界面刷新，显示正确的已选分类信息
            });
          },
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: '产品分类', icon: Icon(Icons.shopping_cart)),
            Tab(text: '服务分类', icon: Icon(Icons.medical_services)),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // 产品分类Tab
            _buildCategoryTab(),
            // 服务分类Tab
            _buildCategoryTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomInfoBar(),
    );
  }

  Widget _buildBottomInfoBar() {
    final theme = Theme.of(context);
    final currentTabIndex = _tabController.index;
    final selectedCategories = currentTabIndex == 0
        ? _selectedProductCategories
        : _selectedServiceCategories;

    // 获取当前选中的主类别名称
    String currentPrimaryName = '未选择';
    final controller = currentTabIndex == 0
        ? _productPickerController
        : _servicePickerController;

    if (controller.selectedPrimary != null) {
      currentPrimaryName = controller.selectedPrimary!.name;
    }

    // 获取所有主类别ID和子类别ID
    final primaryIds = <String>{};
    final secondaryIds = <String>{};

    for (final category in selectedCategories) {
      // 使用isMainCategory判断是否是主类别
      if (category.isMainCategory) {
        primaryIds.add(category.id);
      } else {
        // 如果是子类别，使用parentId找到对应的主类别
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
        padding: const EdgeInsets.all(16),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
    );
  }

  Widget _buildCategoryTab() {
    final controller = _tabController.index == 0
        ? _productPickerController
        : _servicePickerController;

    return Column(
      children: [
        Expanded(
          child: HierarchicalCategoryPicker(
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
      // 添加主类别
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('添加${tabName}主类别')),
      );
    } else {
      // 添加子类别
      _showAddSubcategoryDialog(parentCategory);
    }
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
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category.color?.withOpacity(0.2) ??
                              theme.colorScheme.primaryContainer
                                  .withOpacity(0.3),
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
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.edit_outlined,
                      color: theme.colorScheme.primary),
                  title: Text('编辑${isPrimary ? "主" : "子"}类别'),
                  subtitle: const Text('修改名称、图标和颜色'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCategoryDialog(category, isPrimary);
                  },
                ),
                if (isPrimary && category.hasChildren)
                  ListTile(
                    leading: Icon(Icons.add_circle_outline,
                        color: theme.colorScheme.primary),
                    title: const Text('添加子类别'),
                    subtitle: Text('向 ${category.name} 添加新的子类别'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAddSubcategoryDialog(category);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('删除${isPrimary ? "主" : "子"}类别',
                      style: const TextStyle(color: Colors.red)),
                  subtitle: Text(
                    isPrimary && category.hasChildren
                        ? '警告：将同时删除所有子类别'
                        : '从列表中移除此类别',
                    style: const TextStyle(color: Colors.red),
                  ),
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

  /// 显示编辑类别对话框
  void _showEditCategoryDialog(Category category, bool isPrimary) {
    // 此处添加编辑类别的对话框实现
    // 可以使用showDialog显示一个编辑表单
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑${isPrimary ? "主" : "子"}类别: ${category.name}')),
    );
  }

  /// 显示添加子类别对话框
  void _showAddSubcategoryDialog(Category parentCategory) {
    // 此处添加新增子类别的对话框实现
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('向 ${parentCategory.name} 添加子类别')),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(Category category, bool isPrimary) {
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
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里添加实际的删除逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除: ${category.name}')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
