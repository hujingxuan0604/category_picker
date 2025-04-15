import 'package:flutter/material.dart';

@immutable
class Category {
  /// 唯一ID
  final String id;
  
  /// 类别名称
  final String name;
  
  /// 父类别ID（如果是子类别）
  final String? parentId;
  
  /// 图标
  final IconData? icon;
  
  /// 颜色
  final Color? color;
  
  /// 子类别列表
  final List<Category>? children;
  
  /// 额外数据
  final dynamic extraData;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    this.icon,
    this.color,
    this.children,
    this.extraData,
  });

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
    dynamic extraData,
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
    // 创建基本分类
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parentId'] as String?,
      icon: map['icon'] is IconData ? map['icon'] as IconData : Icons.category,
      color: map['color'] is Color ? map['color'] as Color : Colors.blue,
      children: map['children'] != null 
          ? (map['children'] as List).map((item) => Category.fromMap(item)).toList()
          : null,
      extraData: map['extraData'],
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'icon': icon,
      'color': color,
      'children': children?.map((child) => child.toMap()).toList(),
      'extraData': extraData,
    };
  }
}