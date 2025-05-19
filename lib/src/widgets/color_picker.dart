import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// 颜色选择器组件
class ColorPickerTile extends StatefulWidget {
  final Color selectedColor;
  final List<Color> colors;
  final Function(Color) onColorSelected;
  final bool showCustomColorOption;

  const ColorPickerTile({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.showCustomColorOption = true,
    this.colors = const [
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

  @override
  State<ColorPickerTile> createState() => _ColorPickerTileState();
}

class _ColorPickerTileState extends State<ColorPickerTile> {
  bool _isCustomColor = false;

  @override
  void initState() {
    super.initState();
    // 检查当前选中的颜色是否在预设颜色中
    _isCustomColor = !widget.colors.contains(widget.selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isCompact = ResponsiveHelper.shouldUseCompactLayout(context);

    // 计算颜色项的大小和高度
    final double itemSize = deviceType == DeviceType.mobile
        ? (isCompact ? 28.0 : 36.0)
        : (deviceType == DeviceType.tablet ? 40.0 : 44.0);

    final double containerHeight = isCompact ? 40.0 : 48.0;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDarkMode
              ? theme.colorScheme.outline.withValues(alpha: 0.2)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getPadding(context, isSmall: true) / 2,
          vertical: (containerHeight - itemSize) / 2,
        ),
        itemCount: widget.showCustomColorOption
            ? widget.colors.length + 1
            : widget.colors.length,
        itemBuilder: (context, index) {
          // 第一个位置显示自定义颜色选项
          if (index == 0 && widget.showCustomColorOption) {
            return _buildCustomColorItem(theme, itemSize);
          }

          // 调整颜色索引以适应自定义颜色选项
          final colorIndex = widget.showCustomColorOption ? index - 1 : index;
          final color = widget.colors[colorIndex];
          final isSelected = !_isCustomColor && widget.selectedColor == color;

          return _buildColorItem(color, isSelected, theme, itemSize);
        },
      ),
    );
  }

  Widget _buildCustomColorItem(ThemeData theme, double itemSize) {
    final isSelected = _isCustomColor;
    final customColor = widget.selectedColor;
    final checkSize = itemSize / 3; // 选中标记的大小
    final borderWidth = itemSize / 18; // 边框宽度

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(itemSize / 2),
          onTap: () => _showCustomColorDialog(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 多彩背景
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: itemSize,
                height: itemSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.blue, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: borderWidth,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: customColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              // 自定义图标
              Icon(
                Icons.color_lens,
                size: itemSize / 2,
                color: Colors.white,
              ),
              // 选中指示器
              if (isSelected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: checkSize,
                    height: checkSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: checkSize / 2,
                        height: checkSize / 2,
                        decoration: BoxDecoration(
                          color: customColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorItem(
      Color color, bool isSelected, ThemeData theme, double itemSize) {
    final borderWidth = itemSize / 18; // 边框宽度
    final indicatorSize = itemSize / 3; // 选中标记大小

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(itemSize / 2),
          onTap: () {
            setState(() {
              _isCustomColor = false;
            });
            widget.onColorSelected(color);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: itemSize,
                height: itemSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: borderWidth,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              // 选中指示器
              if (isSelected)
                Container(
                  width: indicatorSize / 3,
                  height: indicatorSize / 3,
                  decoration: BoxDecoration(
                    color: _isColorBright(color) ? Colors.black : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 判断颜色是否明亮（用于决定选中指示器的颜色）
  bool _isColorBright(Color color) {
    return (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) /
            255 >
        0.5;
  }

  void _showCustomColorDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final padding = ResponsiveHelper.getPadding(context);

    // 初始RGB值
    int red = widget.selectedColor.red;
    int green = widget.selectedColor.green;
    int blue = widget.selectedColor.blue;

    Color previewColor = widget.selectedColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // 根据设备类型调整对话框大小
              title: Text('自定义颜色'),
              content: SizedBox(
                width: deviceType == DeviceType.mobile ? 280 : 320,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 颜色预览
                      Container(
                        width: deviceType == DeviceType.mobile ? 70 : 80,
                        height: deviceType == DeviceType.mobile ? 70 : 80,
                        margin: EdgeInsets.only(bottom: padding),
                        decoration: BoxDecoration(
                          color: previewColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: previewColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),

                      // RGB 滑块
                      _buildColorSlider(
                        label: 'R',
                        value: red,
                        color: Colors.red,
                        onChanged: (value) {
                          setState(() {
                            red = value;
                            previewColor =
                                Color.fromRGBO(red, green, blue, 1.0);
                          });
                        },
                      ),

                      _buildColorSlider(
                        label: 'G',
                        value: green,
                        color: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            green = value;
                            previewColor =
                                Color.fromRGBO(red, green, blue, 1.0);
                          });
                        },
                      ),

                      _buildColorSlider(
                        label: 'B',
                        value: blue,
                        color: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            blue = value;
                            previewColor =
                                Color.fromRGBO(red, green, blue, 1.0);
                          });
                        },
                      ),

                      // HEX值输入
                      Padding(
                        padding: EdgeInsets.only(top: padding),
                        child: Row(
                          children: [
                            Text(
                              'HEX:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? theme
                                          .colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.5)
                                      : theme
                                          .colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: TextField(
                                  controller: TextEditingController(
                                    text: '#${_colorToHex(previewColor)}',
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    letterSpacing: 1.2,
                                  ),
                                  maxLength: 7,
                                  buildCounter: (context,
                                          {required currentLength,
                                          required isFocused,
                                          maxLength}) =>
                                      null,
                                  onChanged: (value) {
                                    if (value.startsWith('#') &&
                                        value.length == 7) {
                                      try {
                                        // 解析HEX值
                                        final colorValue = int.parse(
                                            'FF${value.substring(1)}',
                                            radix: 16);
                                        final newColor = Color(colorValue);
                                        setState(() {
                                          red = newColor.red;
                                          green = newColor.green;
                                          blue = newColor.blue;
                                          previewColor = newColor;
                                        });
                                      } catch (_) {
                                        // 解析失败，忽略
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isCustomColor = true;
                    });
                    widget.onColorSelected(previewColor);
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColorSlider({
    required String label,
    required int value,
    required Color color,
    required Function(int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                thumbColor: color,
                activeTrackColor: color.withValues(alpha: 0.5),
                inactiveTrackColor: color.withValues(alpha: 0.1),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 4,
              ),
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 255,
                divisions: 255,
                onChanged: (double newValue) {
                  onChanged(newValue.round());
                },
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // 将颜色转换为十六进制字符串
  String _colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }
}
