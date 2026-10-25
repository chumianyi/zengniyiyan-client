import 'package:flutter/material.dart';

/// Neumorphism（新拟态）调色板
class NeuColors {
  final Color bg;
  final Color shadowLight;
  final Color shadowDark;
  final Color text;
  final Color subText;
  final Color accent;
  final Color accentSoft;
  final Color onAccent;
  final Color danger;

  const NeuColors({
    required this.bg,
    required this.shadowLight,
    required this.shadowDark,
    required this.text,
    required this.subText,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.danger,
  });

  /// 亮色：经典 #E0E5EC 浅灰蓝底
  static const light = NeuColors(
    bg: Color(0xFFE0E5EC),
    shadowLight: Color(0xFFFFFFFF),
    shadowDark: Color(0xFFA3B1C6),
    text: Color(0xFF3A424C),
    subText: Color(0xFF8A94A3),
    accent: Color(0xFFBC6152),
    accentSoft: Color(0xFFF0DBD4),
    onAccent: Color(0xFFFFFFFF),
    danger: Color(0xFFC05046),
  );

  /// 暗色：深灰蓝底
  static const dark = NeuColors(
    bg: Color(0xFF2B2F36),
    shadowLight: Color(0xFF3A3F48),
    shadowDark: Color(0xFF1F2228),
    text: Color(0xFFE6E9EE),
    subText: Color(0xFF9AA3AF),
    accent: Color(0xFFD98A76),
    accentSoft: Color(0xFF46352F),
    onAccent: Color(0xFF2B2F36),
    danger: Color(0xFFE0786A),
  );

  static NeuColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  /// 将颜色按比例混合到底色上
  Color blend(Color top, double opacity, Color base) {
    return Color.alphaBlend(top.withOpacity(opacity), base);
  }
}

/// 可按压新拟态容器：默认凸起，按压时凹陷
class NeuPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool enabled;

  const NeuPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.radius = 24,
    this.padding = EdgeInsets.zero,
    this.color,
    this.enabled = true,
  });

  @override
  State<NeuPressable> createState() => _NeuPressableState();
}

class _NeuPressableState extends State<NeuPressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (!widget.enabled || widget.onTap == null) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final c = NeuColors.of(context);
    final base = widget.color ?? c.bg;
    final pressed = _pressed;

    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
          // 始终提供 gradient，保证凸起/凹陷之间可平滑插值
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: pressed
                ? [
                    c.blend(c.shadowDark, 0.55, base),
                    c.blend(c.shadowLight, 0.55, base),
                  ]
                : [base, base],
          ),
          boxShadow: pressed
              ? null
              : [
                  BoxShadow(
                    color: c.shadowLight,
                    offset: const Offset(-5, -5),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: c.shadowDark,
                    offset: const Offset(5, 5),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: widget.enabled
            ? widget.child
            : Opacity(opacity: 0.5, child: widget.child),
      ),
    );
  }
}

/// 新拟态卡片（凸起）
class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const NeuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final c = NeuColors.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: c.shadowLight,
            offset: const Offset(-7, -7),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: c.shadowDark,
            offset: const Offset(7, 7),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 圆形新拟态图标按钮
class NeuIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final Color? bg;
  final bool enabled;
  final String? tooltip;

  const NeuIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 56,
    this.iconColor,
    this.bg,
    this.enabled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final c = NeuColors.of(context);
    final button = NeuPressable(
      onTap: onTap,
      enabled: enabled,
      radius: size / 2,
      padding: EdgeInsets.zero,
      color: bg,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            icon,
            size: size * 0.42,
            color: iconColor ?? c.text,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
