import 'package:flutter/material.dart';

/// 分类模型类
///
/// 用于表示可选择的分类项，支持主类别和子类别的层级结构
@immutable
class Category {
  /// 唯一ID
  final String id;

  /// 类别名称
  final String name;

  /// 父类别ID（如果是子类别）
  final String? parentId;

  /// 图标
  final IconData icon;

  /// 颜色
  final Color color;

  /// 子类别列表
  final List<Category>? children;

  /// 额外数据
  final Map<String, dynamic>? extraData;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    IconData? icon,
    Color? color,
    this.children,
    this.extraData,
  })  : icon = icon ?? Icons.category,
        color = color ?? Colors.blue;

  bool get hasChildren => children != null && children!.isNotEmpty;

  // 是否为主类别
  bool get isMainCategory => parentId == null;

  Category copyWith({
    String? id,
    String? name,
    String? parentId,
    IconData? icon,
    Color? color,
    List<Category>? children,
    Map<String, dynamic>? extraData,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      children: children ?? this.children,
      extraData: extraData ?? this.extraData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';

  /// 从Map创建
  factory Category.fromMap(Map<String, dynamic> map) {
    List<Category>? childList;

    // 安全地处理子类别
    if (map['children'] != null && map['children'] is List) {
      try {
        childList = (map['children'] as List)
            .map((item) => item is Map<String, dynamic>
                ? Category.fromMap(item)
                : throw FormatException('Invalid child format'))
            .toList();
      } catch (e) {
        // 处理错误但不抛出异常，返回空列表
        childList = [];
      }
    }

    // 创建基本分类
    return Category(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      parentId: map['parentId']?.toString(),
      icon: map['icon'] is IconData ? map['icon'] as IconData : null,
      color: map['color'] is Color ? map['color'] as Color : null,
      children: childList,
      extraData: map['extraData'] is Map
          ? Map<String, dynamic>.from(map['extraData'])
          : null,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      if (parentId != null) 'parentId': parentId,
      'icon': icon,
      'color': color,
      if (children != null)
        'children': children?.map((child) => child.toMap()).toList(),
      if (extraData != null) 'extraData': extraData,
    };
  }
}
