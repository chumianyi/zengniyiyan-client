import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'neu.dart';
import 'yiyan_service.dart';

/// 与原生（Android）分享通道
const MethodChannel _shareChannel = MethodChannel('cn.zengniyiyan.app/share');

class HomeScreen extends StatefulWidget {
  final bool dark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.dark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Yiyan? _quote;
  bool _loading = false;
  String? _error;
  int _fetchCount = 0;
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fetch();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _spin.repeat();

    try {
      final quote = await YiyanService.fetch();
      if (!mounted) return;
      setState(() {
        _quote = quote;
        _fetchCount++;
      });
    } on YiyanException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '发生未知错误，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _settleSpin();
      }
    }
  }

  /// 旋转平滑回到正位（补足当前这一圈再归零）
  void _settleSpin() {
    if (!_spin.isAnimating) {
      _spin.value = 0;
      return;
    }
    final remainingMs = ((1 - _spin.value) * 900).round();
    _spin
        .animateTo(1.0,
            duration: Duration(milliseconds: remainingMs), curve: Curves.linear)
        .whenComplete(() {
      if (mounted) _spin.value = 0;
    });
  }

  Future<void> _copy() async {
    final quote = _quote;
    if (quote == null) return;
    await Clipboard.setData(ClipboardData(text: quote.shareText));
    if (!mounted) return;
    _toast('已复制到剪贴板');
  }

  Future<void> _share() async {
    final quote = _quote;
    if (quote == null) return;
    try {
      await _shareChannel.invokeMethod('shareText', <String, dynamic>{
        'text': '${quote.shareText}\n\n—— 来自「赠你一言」',
      });
    } catch (_) {
      if (!mounted) return;
      _toast('分享失败，请重试');
    }
  }

  void _toast(String message) {
    final c = NeuColors.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: c.bg, fontSize: 13),
          ),
          backgroundColor: c.text,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final c = NeuColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 14),
              // 顶栏
              Row(
                children: [
                  Text(
                    '赠你一言',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: c.text,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  NeuIconButton(
                    icon: widget.dark
                        ? Icons.wb_sunny_outlined
                        : Icons.nightlight_round,
                    onTap: widget.onToggleTheme,
                    size: 44,
                    tooltip: widget.dark ? '切换到浅色' : '切换到深色',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 一言卡片
              Expanded(
                child: Center(child: _buildCard(c)),
              ),
              const SizedBox(height: 20),
              // 操作按钮
              _buildActions(c),
              const SizedBox(height: 18),
              Text(
                '数据来源 · 一言 API',
                style: TextStyle(fontSize: 11, color: c.subText, letterSpacing: 1),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(NeuColors c) {
    final quote = _quote;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 440),
      child: NeuCard(
        padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 装饰引号
            Text(
              '\u201C',
              style: TextStyle(
                fontSize: 52,
                height: 1,
                color: c.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: (children) => Stack(
                    alignment: Alignment.topCenter,
                    children: children,
                  ),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  ),
                  child: _buildBody(c),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 序号
            Text(
              (quote != null && quote.index > 0)
                  ? '第 ${quote.index} / ${quote.total} 则'
                  : ' ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: c.subText,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NeuColors c) {
    if (_loading && _quote == null) {
      return Padding(
        key: const ValueKey('loading'),
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(c.accent),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '正在为你寻觅一言…',
              style: TextStyle(fontSize: 13, color: c.subText),
            ),
          ],
        ),
      );
    }

    if (_error != null && _quote == null) {
      return Padding(
        key: ValueKey('error:$_error'),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: c.danger),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.subText, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方刷新重试',
              style: TextStyle(fontSize: 12, color: c.subText),
            ),
          ],
        ),
      );
    }

    final quote = _quote;
    if (quote == null) {
      return const SizedBox(key: ValueKey('empty'), height: 60);
    }
    return Column(
      key: ValueKey('quote:$_fetchCount:${quote.text}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          quote.text,
          style: TextStyle(
            fontSize: 21,
            height: 1.8,
            color: c.text,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          quote.from.isEmpty ? '—— 佚名' : '—— ${quote.from}',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 13, color: c.subText, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildActions(NeuColors c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NeuIconButton(
          icon: Icons.copy_rounded,
          onTap: _copy,
          size: 56,
          enabled: _quote != null,
          tooltip: '复制',
        ),
        const SizedBox(width: 24),
        // 刷新主按钮
        NeuPressable(
          onTap: _fetch,
          radius: 40,
          padding: EdgeInsets.zero,
          color: c.accent,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: AnimatedBuilder(
                animation: _spin,
                builder: (context, child) => Transform.rotate(
                  angle: _spin.value * 6.283185307179586,
                  child: child,
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 36,
                  color: c.onAccent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        NeuIconButton(
          icon: Icons.share_rounded,
          onTap: _share,
          size: 56,
          enabled: _quote != null,
          tooltip: '分享',
        ),
      ],
    );
  }
}
