import 'package:flutter/material.dart';

/// 分类选择器配置类
///
/// 用于配置分类选择器的外观和行为
@immutable
class CategoryPickerConfig {
  /// 是否允许多选主类别
  final bool multiSelectPrimary;

  /// 是否允许多选子类别
  final bool multiSelectSecondary;

  /// 是否显示搜索框
  final bool showSearch;

  /// 是否显示标题
  final bool showHeader;

  /// 自定义标题文本
  final String headerText;

  /// 主类别面板宽度比例 (0-1)
  final double primaryPanelWidthRatio;

  /// 主类别面板固定宽度，优先级高于比例
  final double? primaryPanelWidth;

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

  /// 是否显示颜色选择器
  final bool showColorPicker;

  /// 是否在标题栏显示管理按钮
  final bool showManageButton;

  /// 管理按钮文本
  final String manageButtonText;

  /// 可选择的颜色列表
  final List<Color> availableColors;

  const CategoryPickerConfig({
    this.multiSelectPrimary = false,
    this.multiSelectSecondary = false,
    this.showSearch = false,
    this.showHeader = true,
    this.headerText = '选择类别',
    this.primaryPanelWidthRatio = 0.25,
    this.primaryPanelWidth,
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
    this.showColorPicker = false,
    this.showManageButton = false,
    this.manageButtonText = '管理',
    this.availableColors = const [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ],
  });

  CategoryPickerConfig copyWith({
    bool? multiSelectPrimary,
    bool? multiSelectSecondary,
    bool? showSearch,
    bool? showHeader,
    String? headerText,
    double? primaryPanelWidthRatio,
    double? primaryPanelWidth,
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
    bool? showColorPicker,
    bool? showManageButton,
    String? manageButtonText,
    List<Color>? availableColors,
  }) {
    return CategoryPickerConfig(
      multiSelectPrimary: multiSelectPrimary ?? this.multiSelectPrimary,
      multiSelectSecondary: multiSelectSecondary ?? this.multiSelectSecondary,
      showSearch: showSearch ?? this.showSearch,
      showHeader: showHeader ?? this.showHeader,
      headerText: headerText ?? this.headerText,
      primaryPanelWidthRatio:
          primaryPanelWidthRatio ?? this.primaryPanelWidthRatio,
      primaryPanelWidth: primaryPanelWidth ?? this.primaryPanelWidth,
      defaultSelectedColor: defaultSelectedColor ?? this.defaultSelectedColor,
      primaryItemHeight: primaryItemHeight ?? this.primaryItemHeight,
      secondaryItemHeight: secondaryItemHeight ?? this.secondaryItemHeight,
      primaryTextStyle: primaryTextStyle ?? this.primaryTextStyle,
      primarySelectedTextStyle:
          primarySelectedTextStyle ?? this.primarySelectedTextStyle,
      secondaryTextStyle: secondaryTextStyle ?? this.secondaryTextStyle,
      secondarySelectedTextStyle:
          secondarySelectedTextStyle ?? this.secondarySelectedTextStyle,
      searchHintText: searchHintText ?? this.searchHintText,
      emptyText: emptyText ?? this.emptyText,
      showIcons: showIcons ?? this.showIcons,
      defaultIcon: defaultIcon ?? this.defaultIcon,
      showAddButtonInSecondary:
          showAddButtonInSecondary ?? this.showAddButtonInSecondary,
      addCategoryText: addCategoryText ?? this.addCategoryText,
      showColorPicker: showColorPicker ?? this.showColorPicker,
      showManageButton: showManageButton ?? this.showManageButton,
      manageButtonText: manageButtonText ?? this.manageButtonText,
      availableColors: availableColors ?? this.availableColors,
    );
  }
}
