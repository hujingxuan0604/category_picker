# Category Picker

一个类别选择器Flutter组件，支持两级类别、自定义图标和颜色。


## 功能特点

- 支持两级层级分类结构
- 自定义分类图标和颜色
- 高性能渲染，适合大量分类场景
- 支持单选和多选模式
- 完全可自定义的UI
- 易于集成和使用

## 安装

在`pubspec.yaml`文件中添加依赖：

```yaml
dependencies:
  category_picker: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

## 使用方法

### 基本用法

```dart
import 'package:category_picker/category_picker.dart';
import 'package:flutter/material.dart';

class CategoryPickerExample extends StatefulWidget {
  @override
  _CategoryPickerExampleState createState() => _CategoryPickerExampleState();
}

class _CategoryPickerExampleState extends State<CategoryPickerExample> {
  late CategoryPickerController _controller;
  final List<Category> _categories = [];
  
  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _controller = CategoryPickerController(categories: _categories);
  }
  
  void _initializeCategories() {
    _categories.add(
      Category(
        id: 'electronics',
        name: '电子产品',
        icon: Icons.devices,
        color: Colors.blue,
        children: [
          Category(
            id: 'smartphones',
            name: '智能手机',
            icon: Icons.phone_android,
            parentId: 'electronics',
          ),
          Category(
            id: 'tablets',
            name: '平板电脑',
            icon: Icons.tablet,
            parentId: 'electronics',
          ),
        ],
      ),
    );
    // 添加更多分类...
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('类别选择器示例')),
      body: Column(
        children: [
          CategoryPickerWidget(
            controller: _controller,
            config: PickerConfig(
              selectionMode: SelectionMode.multiple,
              mainCategoryStyle: CategoryStyle(
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              subCategoryStyle: CategoryStyle(
                textStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final selected = _controller.selectedCategories;
              print('已选择的类别: ${selected.map((c) => c.name).join(', ')}');
            },
            child: Text('获取选中分类'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 自定义配置

`PickerConfig` 类允许您自定义选择器的外观和行为：

```dart
CategoryPickerWidget(
  controller: _controller,
  config: PickerConfig(
    selectionMode: SelectionMode.multiple,  // 多选模式
    allowEmptySelection: false,             // 不允许空选
    mainCategoryStyle: CategoryStyle(       // 主分类样式
      backgroundColor: Colors.grey[100],
      selectedBackgroundColor: Colors.blue[100],
      textStyle: TextStyle(fontSize: 16),
      selectedTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      iconSize: 24,
      selectedIconColor: Colors.blue,
    ),
    subCategoryStyle: CategoryStyle(        // 子分类样式
      backgroundColor: Colors.white,
      selectedBackgroundColor: Colors.blue[50],
      textStyle: TextStyle(fontSize: 14),
      selectedTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      iconSize: 20,
      selectedIconColor: Colors.blue,
    ),
    layout: PickerLayout.horizontal,        // 水平布局
  ),
)
```

## 类参考

### Category

分类数据模型：

```dart
Category({
  required String id,           // 唯一ID
  required String name,         // 分类名称
  String? parentId,             // 父分类ID（如果是子分类）
  IconData? icon,               // 图标
  Color? color,                 // 颜色
  List<Category>? children,     // 子分类列表
  dynamic extraData,            // 额外数据
})
```

### CategoryPickerController

管理分类选择器状态：

```dart
// 创建控制器
final controller = CategoryPickerController(
  categories: yourCategories,
);

// 监听选择变化
controller.addListener(() {
  print('选中的分类: ${controller.selectedCategories}');
});

// 手动设置选中分类
controller.setSelectedCategories([category1, category2]);

// 清除选择
controller.clearSelection();

// 销毁控制器
controller.dispose();
```

## 示例

查看 `/examples` 目录获取完整示例。

## 许可证

本项目遵循 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件获取详情。
