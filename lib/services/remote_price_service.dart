import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class RemoteIngredientPrice {
  final String itemName;
  final String formatName;
  final int price;

  const RemoteIngredientPrice({
    required this.itemName,
    required this.formatName,
    required this.price,
  });
}

class RemotePriceService {
  // Cambia este valor por la URL real de Cloud Functions al desplegar.
  static const String _baseUrl =
      String.fromEnvironment('PRICES_API_URL', defaultValue: '');

  static Future<Map<String, RemoteIngredientPrice>> fetchPricesByItems(
    List<String> items,
  ) async {
    if (_baseUrl.isEmpty || items.isEmpty) return {};

    final normalized = items
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList();
    final uri = Uri.parse(
      '$_baseUrl/getPrices?items=${Uri.encodeComponent(normalized.join(','))}',
    );

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.getUrl(uri);
      final res = await req.close();
      if (res.statusCode != 200) return {};

      final body = await utf8.decodeStream(res);
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return {};
      final data = decoded['items'];
      if (data is! List) return {};

      final result = <String, RemoteIngredientPrice>{};
      for (final row in data) {
        if (row is! Map<String, dynamic>) continue;
        final itemName = row['itemName'];
        final formatName = row['formatName'];
        final price = row['price'];
        if (itemName is String &&
            formatName is String &&
            formatName.trim().isNotEmpty &&
            price is num &&
            price > 0) {
          result[itemName.toLowerCase()] = RemoteIngredientPrice(
            itemName: itemName,
            formatName: formatName,
            price: price.toInt(),
          );
        }
      }
      return result;
    } catch (error) {
      debugPrint('[RemotePriceService.fetchPricesByItems] $error');
      return {};
    } finally {
      client.close(force: true);
    }
  }
}
