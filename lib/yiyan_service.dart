import 'dart:convert';

import 'package:http/http.dart' as http;

/// 一条一言
class Yiyan {
  final String text;
  final String from;
  final int index;
  final int total;

  const Yiyan({
    required this.text,
    required this.from,
    required this.index,
    required this.total,
  });

  /// 用于复制/分享的文本
  String get shareText {
    if (from.isEmpty) return text;
    return '$text\n—— $from';
  }
}

/// 一言接口异常
class YiyanException implements Exception {
  final String message;
  YiyanException(this.message);

  @override
  String toString() => message;
}

/// 一言 API 服务
class YiyanService {
  YiyanService._();

  static const String apiUrl = 'http://xingheios.us.ci/api/yiyan';

  /// 随机获取一条一言
  static Future<Yiyan> fetch() async {
    final http.Response response;
    try {
      response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      throw YiyanException('网络连接失败，请检查网络后重试');
    }

    if (response.statusCode != 200) {
      throw YiyanException('服务器无响应（HTTP ${response.statusCode}）');
    }

    dynamic data;
    try {
      data = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw YiyanException('返回内容解析失败');
    }

    if (data is Map && data['code'] == 200) {
      final dynamic d = data['data'];
      if (d is Map) {
        final text = (d['text'] ?? '').toString().trim();
        if (text.isNotEmpty) {
          return Yiyan(
            text: text,
            from: (d['from'] ?? '').toString().trim(),
            index: int.tryParse('${d['index']}') ?? 0,
            total: int.tryParse('${d['total']}') ?? 0,
          );
        }
      }
    }
    throw YiyanException('接口返回数据异常');
  }
}
