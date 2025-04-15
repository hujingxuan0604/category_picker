import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/picker_config.dart';

class CategoryPickerController extends ChangeNotifier {
  final List<Category> _categories;
  final CategoryPickerConfig config;
  
  Category? _selectedPrimary;
  final List<Category> _selectedCategories = [];
  String _searchQuery = '';

  Category? get selectedPrimary => _selectedPrimary;
  List<Category> get selectedCategories => List.unmodifiable(_selectedCategories);
  String get searchQuery => _searchQuery;

  CategoryPickerController({
    required List<Category> categories,
    this.config = const CategoryPickerConfig(),
  }) : _categories = List.unmodifiable(categories) {
    if (_categories.isNotEmpty) {
      _selectedPrimary = _categories.first;
    }
  }

  void selectPrimaryCategory(Category category) {
    if (_selectedPrimary == category) return;
    
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
    
    _selectedPrimary = category;
    notifyListeners();
  }

  void toggleCategorySelection(Category category) {
    // 判断是否是主类别
    final isPrimary = category.isMainCategory;
    
    if (isPrimary) {
      // 主类别选择逻辑
      if (!config.multiSelectPrimary) {
        _selectedCategories.removeWhere((c) => c.isMainCategory);
      }
    } else {
      // 子类别选择逻辑
      if (!config.multiSelectSecondary) {
        // 使用parentId移除同一父类别下的所有子类别
        _selectedCategories.removeWhere((c) => 
          !c.isMainCategory && c.parentId == category.parentId);
      }
    }

    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }

    notifyListeners();
  }

  void _toggleSelection(Category category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategoriesByIds(List<String> primaryIds, List<String> secondaryIds) {
    _selectedCategories.clear();
    
    // 添加主类别
    for (final primaryId in primaryIds) {
      try {
        final primary = _categories.firstWhere(
          (c) => c.id == primaryId,
          orElse: () => throw Exception('Primary category not found: $primaryId'),
        );
        
        _selectedCategories.add(primary);
      } catch (_) {
        continue;
      }
    }

    // 添加子类别
    for (final secondaryId in secondaryIds) {
      // 先从所有主类别的children中查找
      bool found = false;
      for (final primary in _categories) {
        if (primary.hasChildren) {
          try {
            final secondary = primary.children!.firstWhere(
              (c) => c.id == secondaryId,
            );
            _selectedCategories.add(secondary);
            found = true;
            break;
          } catch (_) {
            continue;
          }
        }
      }
      
      // 如果未找到，查找所有有parentId的分类
      if (!found) {
        try {
          // 假设可能在列表外还有子类别
          final secondary = Category(
            id: secondaryId,
            name: '未知分类',
            parentId: primaryIds.isNotEmpty ? primaryIds.first : null,
          );
          _selectedCategories.add(secondary);
        } catch (_) {
          continue;
        }
      }
    }

    // 设置选中的主类别
    if (_selectedCategories.isNotEmpty) {
      final firstSelected = _selectedCategories.first;
      if (firstSelected.isMainCategory) {
        _selectedPrimary = firstSelected;
      } else {
        // 通过parentId查找主类别
        _selectedPrimary = _categories.firstWhere(
          (c) => c.id == firstSelected.parentId,
          orElse: () => _categories.first,
        );
      }
    }

    notifyListeners();
  }

  List<Category> get filteredPrimaryCategories {
    if (_searchQuery.isEmpty) return _categories;
    
    return _categories.where((category) {
      // 检查主类别名称
      if (category.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return true;
      }
      
      // 检查子类别名称
      if (category.hasChildren) {
        return category.children!.any((child) => 
          child.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      }
      
      return false;
    }).toList();
  }

  List<Category>? get filteredSecondaryCategories {
    if (_selectedPrimary == null) return null;
    if (!_selectedPrimary!.hasChildren) return null;
    
    if (_searchQuery.isEmpty) return _selectedPrimary!.children;
    
    return _selectedPrimary!.children!.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
}