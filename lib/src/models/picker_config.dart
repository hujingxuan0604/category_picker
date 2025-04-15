import 'package:flutter/material.dart';

class CategoryPickerConfig {
  /// 是否允许多选主类别
  final bool multiSelectPrimary;

  /// 是否允许多选子类别
  final bool multiSelectSecondary;

  /// 是否显示搜索框
  final bool showSearch;

  /// 主类别面板宽度比例 (0-1)
  final double primaryPanelWidthRatio;

  /// 默认选中颜色
  final Color defaultSelectedColor;

  /// 主类别项高度
  final double primaryItemHeight;

  /// 子类别项高度
  final double secondaryItemHeight;

  /// 主类别文本样式
  final TextStyle? primaryTextStyle;

  /// 主类别选中文本样式
  final TextStyle? primarySelectedTextStyle;

  /// 子类别文本样式
  final TextStyle? secondaryTextStyle;

  /// 子类别选中文本样式
  final TextStyle? secondarySelectedTextStyle;

  /// 搜索框提示文本
  final String searchHintText;

  /// 空视图文本
  final String emptyText;

  /// 是否显示类别图标
  final bool showIcons;

  /// 默认图标
  final IconData? defaultIcon;
  
  /// 是否在子类别面板第一个位置显示添加按钮
  final bool showAddButtonInSecondary;
  
  /// 添加子类别按钮文本
  final String addCategoryText;

  const CategoryPickerConfig({
    this.multiSelectPrimary = false,
    this.multiSelectSecondary = false,
    this.showSearch = false,
    this.primaryPanelWidthRatio = 0.25,
    this.defaultSelectedColor = Colors.blue,
    this.primaryItemHeight = 56.0,
    this.secondaryItemHeight = 48.0,
    this.primaryTextStyle,
    this.primarySelectedTextStyle,
    this.secondaryTextStyle,
    this.secondarySelectedTextStyle,
    this.searchHintText = 'Search categories...',
    this.emptyText = 'No categories available',
    this.showIcons = true,
    this.defaultIcon,
    this.showAddButtonInSecondary = false,
    this.addCategoryText = '添加子类别',
  });

  CategoryPickerConfig copyWith({
    bool? multiSelectPrimary,
    bool? multiSelectSecondary,
    bool? showSearch,
    double? primaryPanelWidthRatio,
    Color? defaultSelectedColor,
    double? primaryItemHeight,
    double? secondaryItemHeight,
    TextStyle? primaryTextStyle,
    TextStyle? primarySelectedTextStyle,
    TextStyle? secondaryTextStyle,
    TextStyle? secondarySelectedTextStyle,
    String? searchHintText,
    String? emptyText,
    bool? showIcons,
    IconData? defaultIcon,
    bool? showAddButtonInSecondary,
    String? addCategoryText,
  }) {
    return CategoryPickerConfig(
      multiSelectPrimary: multiSelectPrimary ?? this.multiSelectPrimary,
      multiSelectSecondary: multiSelectSecondary ?? this.multiSelectSecondary,
      showSearch: showSearch ?? this.showSearch,
      primaryPanelWidthRatio: primaryPanelWidthRatio ?? this.primaryPanelWidthRatio,
      defaultSelectedColor: defaultSelectedColor ?? this.defaultSelectedColor,
      primaryItemHeight: primaryItemHeight ?? this.primaryItemHeight,
      secondaryItemHeight: secondaryItemHeight ?? this.secondaryItemHeight,
      primaryTextStyle: primaryTextStyle ?? this.primaryTextStyle,
      primarySelectedTextStyle: primarySelectedTextStyle ?? this.primarySelectedTextStyle,
      secondaryTextStyle: secondaryTextStyle ?? this.secondaryTextStyle,
      secondarySelectedTextStyle: secondarySelectedTextStyle ?? this.secondarySelectedTextStyle,
      searchHintText: searchHintText ?? this.searchHintText,
      emptyText: emptyText ?? this.emptyText,
      showIcons: showIcons ?? this.showIcons,
      defaultIcon: defaultIcon ?? this.defaultIcon,
      showAddButtonInSecondary: showAddButtonInSecondary ?? this.showAddButtonInSecondary,
      addCategoryText: addCategoryText ?? this.addCategoryText,
    );
  }
}