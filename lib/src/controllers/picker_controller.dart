import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/picker_config.dart';

class CategoryPickerController extends ChangeNotifier {
  final List<Category> _categories;
  final CategoryPickerConfig config;

  Category? _selectedPrimary;
  final List<Category> _selectedCategories = [];
  String _searchQuery = '';
  Color _selectedColor;

  // 添加缓存字段
  List<Category>? _cachedFilteredPrimary;
  List<Category>? _cachedFilteredSecondary;
  String? _lastSearchQuery;

  Category? get selectedPrimary => _selectedPrimary;

  List<Category> get selectedCategories =>
      List.unmodifiable(_selectedCategories);

  String get searchQuery => _searchQuery;

  Color get selectedColor => _selectedColor;

  CategoryPickerController({
    required List<Category> categories,
    this.config = const CategoryPickerConfig(),
    Color? initialColor,
  })  : _categories = List.unmodifiable(categories),
        _selectedColor = initialColor ?? config.defaultSelectedColor {
    if (_categories.isNotEmpty) {
      _selectedPrimary = _categories.first;
    }
  }

  void selectPrimaryCategory(Category category) {
    if (_selectedPrimary == category) return;

    // 立即更新选中的主类别，为了确保UI能迅速响应
    _selectedPrimary = category;

    // 清除缓存
    _cachedFilteredSecondary = null;
    _lastSearchQuery = null;

    // 清除所有已选子类别（不管是哪个主类别下的）
    _selectedCategories.removeWhere((c) => !c.isMainCategory);

    // 清除已选的主类别
    if (!config.multiSelectPrimary) {
      _selectedCategories.removeWhere((c) => c.isMainCategory);
    }

    // 将新选中的主类别添加到已选列表中
    if (!_selectedCategories.contains(category)) {
      _selectedCategories.add(category);
    }

    // 如果类别有颜色且颜色选择器可用，使用类别颜色
    if (config.showColorPicker) {
      _selectedColor = category.color;
    }

    // 无论如何都通知监听器，确保UI立即更新
    notifyListeners();
  }

  void toggleCategorySelection(Category category) {
    // 判断是否是主类别
    final isPrimary = category.isMainCategory;
    bool changed = false;

    if (isPrimary) {
      // 主类别选择逻辑
      if (!config.multiSelectPrimary) {
        changed = _selectedCategories.any((c) => c.isMainCategory);
        _selectedCategories.removeWhere((c) => c.isMainCategory);
      }
    } else {
      // 子类别选择逻辑
      if (!config.multiSelectSecondary) {
        changed = _selectedCategories
            .any((c) => !c.isMainCategory && c.parentId == category.parentId);
        // 使用parentId移除同一父类别下的所有子类别
        _selectedCategories.removeWhere(
            (c) => !c.isMainCategory && c.parentId == category.parentId);
      }
    }

    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
      changed = true;
    } else {
      _selectedCategories.add(category);
      changed = true;

      // 如果类别有颜色且颜色选择器可用，使用类别颜色
      if (config.showColorPicker) {
        _selectedColor = category.color;
      }
    }

    // 只有在发生改变时才通知监听器
    if (changed) {
      notifyListeners();
    }
  }

  void updateSelectedColor(Color color) {
    if (_selectedColor == color) return;
    _selectedColor = color;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;

    // 清除缓存
    _cachedFilteredPrimary = null;
    _cachedFilteredSecondary = null;
    _lastSearchQuery = null;

    notifyListeners();
  }

  void selectCategoriesByIds(
      List<String> primaryIds, List<String> secondaryIds) {
    bool changed = false;
    _selectedCategories.clear();
    changed = true;

    // 添加主类别
    for (final primaryId in primaryIds) {
      try {
        final primary = _findPrimaryCategoryById(primaryId);
        if (primary != null) {
          _selectedCategories.add(primary);

          // 更新选中颜色
          if (config.showColorPicker) {
            _selectedColor = primary.color;
          }
        }
      } catch (_) {
        continue;
      }
    }

    // 添加子类别
    for (final secondaryId in secondaryIds) {
      final secondary = _findSecondaryCategoryById(secondaryId);
      if (secondary != null) {
        _selectedCategories.add(secondary);

        // 更新选中颜色
        if (config.showColorPicker) {
          _selectedColor = secondary.color;
        }
      }
    }

    // 设置选中的主类别
    if (_selectedCategories.isNotEmpty) {
      final firstSelected = _selectedCategories.first;
      if (firstSelected.isMainCategory) {
        _selectedPrimary = firstSelected;
      } else if (firstSelected.parentId != null) {
        // 通过parentId查找主类别
        _selectedPrimary = _findPrimaryCategoryById(firstSelected.parentId!) ??
            (_categories.isNotEmpty ? _categories.first : null);
      }
    }

    // 清除缓存
    _cachedFilteredPrimary = null;
    _cachedFilteredSecondary = null;

    if (changed) {
      notifyListeners();
    }
  }

  // 查找主类别的辅助方法
  Category? _findPrimaryCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // 查找子类别的辅助方法
  Category? _findSecondaryCategoryById(String id) {
    // 先从所有主类别的children中查找
    for (final primary in _categories) {
      if (primary.hasChildren) {
        try {
          return primary.children!.firstWhere((c) => c.id == id);
        } catch (_) {
          // 继续查找下一个
        }
      }
    }
    return null;
  }

  List<Category> get filteredPrimaryCategories {
    // 使用缓存提高性能
    if (_cachedFilteredPrimary != null && _lastSearchQuery == _searchQuery) {
      return _cachedFilteredPrimary!;
    }

    if (_searchQuery.isEmpty) {
      _cachedFilteredPrimary = _categories;
      _lastSearchQuery = '';
      return _categories;
    }

    final lowerQuery = _searchQuery.toLowerCase();
    final filtered = _categories.where((category) {
      // 检查主类别名称
      if (category.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // 检查子类别名称
      if (category.hasChildren) {
        return category.children!
            .any((child) => child.name.toLowerCase().contains(lowerQuery));
      }

      return false;
    }).toList();

    _cachedFilteredPrimary = filtered;
    _lastSearchQuery = _searchQuery;
    return filtered;
  }

  List<Category>? get filteredSecondaryCategories {
    if (_selectedPrimary == null) return null;
    if (!_selectedPrimary!.hasChildren) return null;

    // 使用缓存提高性能
    if (_cachedFilteredSecondary != null && _lastSearchQuery == _searchQuery) {
      return _cachedFilteredSecondary;
    }

    if (_searchQuery.isEmpty) {
      _cachedFilteredSecondary = _selectedPrimary!.children;
      return _selectedPrimary!.children;
    }

    final lowerQuery = _searchQuery.toLowerCase();
    final filtered = _selectedPrimary!.children!.where((category) {
      return category.name.toLowerCase().contains(lowerQuery);
    }).toList();

    _cachedFilteredSecondary = filtered;
    return filtered;
  }

  @override
  void dispose() {
    // 清除缓存
    _cachedFilteredPrimary = null;
    _cachedFilteredSecondary = null;
    super.dispose();
  }

  // 避免过度渲染的简化分类刷新方法，不需要通知监听器
  // 用于在账本切换时批量操作时使用
  void softReset() {
    // 清除所有缓存
    _cachedFilteredPrimary = null;
    _cachedFilteredSecondary = null;
    _lastSearchQuery = null;

    // 更新选中的主类别
    if (_categories.isNotEmpty) {
      _selectedPrimary = _categories.first;
    } else {
      _selectedPrimary = null;
    }

    // 清除已选分类
    _selectedCategories.clear();

    // 不调用notifyListeners()，由调用方决定何时刷新UI
  }

  // 支持完全重置控制器状态
  void resetState() {
    // 清除选中状态
    _selectedPrimary = _categories.isNotEmpty ? _categories.first : null;
    _selectedCategories.clear();
    _searchQuery = '';

    // 清除缓存
    _cachedFilteredPrimary = null;
    _cachedFilteredSecondary = null;
    _lastSearchQuery = null;

    // 通知监听器
    notifyListeners();
  }
}
