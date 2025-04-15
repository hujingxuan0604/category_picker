import 'package:flutter/material.dart';
import 'package:category_picker/src/models/category.dart';
import 'package:category_picker/src/models/picker_config.dart';


class CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final bool isPrimary;
  final CategoryPickerConfig config;
  final VoidCallback onTap;
  /// 长按回调函数
  final Function(Category category)? onLongPress;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.isPrimary,
    required this.config,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final defaultTextStyle = isPrimary 
        ? config.primaryTextStyle ?? theme.textTheme.titleSmall
        : config.secondaryTextStyle ?? theme.textTheme.bodySmall;
    
    final selectedTextStyle = isPrimary
        ? config.primarySelectedTextStyle ?? defaultTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          )
        : config.secondarySelectedTextStyle ?? defaultTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          );

    final categoryColor = category.color ?? config.defaultSelectedColor;
    final backgroundColor = isSelected
        ? categoryColor.withOpacity(isPrimary ? 1.0 : 0.9)
        : isPrimary 
            ? Colors.transparent 
            : colorScheme.surface;
    
    final borderColor = isSelected
        ? categoryColor
        : isPrimary 
            ? colorScheme.outline.withOpacity(0.3)
            : colorScheme.outline.withOpacity(0.2);

    final textColor = isSelected
        ? colorScheme.onPrimary
        : isPrimary 
            ? colorScheme.onSurface
            : colorScheme.onSurfaceVariant;

    final iconColor = isSelected
        ? colorScheme.onPrimary
        : categoryColor;

    if (isPrimary) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? categoryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress != null ? () => onLongPress!(category) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              children: [
                if (config.showIcons && (category.icon != null || config.defaultIcon != null))
                  Container(
                    //padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? categoryColor.withOpacity(0.2) : categoryColor.withOpacity(0.1),
                      shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category.icon ?? config.defaultIcon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: (isSelected ? selectedTextStyle : defaultTextStyle)?.copyWith(
                      color: textColor,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress != null ? () => onLongPress!(category) : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? categoryColor
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  category.icon ?? config.defaultIcon ?? Icons.category,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : categoryColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? categoryColor : theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
}