// lib/core/services/payos_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class PayOSService {
  // ⚠️ Chỉ dùng cho dev/học tập — production phải để ở backend
  static const _clientId = 'deea9909-9b5d-402b-b05c-bf68dd9b0f5d';
  static const _apiKey = 'befed90e-eac8-423f-aa51-d2d411e03740';
  static const _checksumKey = 'e262152968f43bc001d8e6a1be0153c4afc35c61a73837fef8f5120afe278c2d';
  static const _baseUrl = 'https://api-merchant.payos.vn';

  /// Tạo chữ ký HMAC_SHA256
  static String _sign({
    required int amount,
    required String cancelUrl,
    required String description,
    required int orderCode,
    required String returnUrl,
  }) {
    final data =
        'amount=$amount'
        '&cancelUrl=$cancelUrl'
        '&description=$description'
        '&orderCode=$orderCode'
        '&returnUrl=$returnUrl';

    final key = utf8.encode(_checksumKey);
    final msg = utf8.encode(data);
    return Hmac(sha256, key).convert(msg).toString();
  }

  /// Gọi API tạo link thanh toán, trả về dữ liệu gồm qrCode, checkoutUrl
  static Future<Map<String, dynamic>> createPaymentLink({
    required int amount,
    required String description,
    required String bookingId,
  }) async {
    // orderCode phải là số nguyên dương, unique
    final orderCode = DateTime.now().millisecondsSinceEpoch % 1000000000;

    const returnUrl = 'https://yourapp.com/payment/success';
    const cancelUrl = 'https://yourapp.com/payment/cancel';

    final signature = _sign(
      amount: amount,
      cancelUrl: cancelUrl,
      description: description,
      orderCode: orderCode,
      returnUrl: returnUrl,
    );

    final body = {
      'orderCode': orderCode,
      'amount': amount,
      'description': description,   // Tối đa 9 ký tự nếu dùng VietQR thường
      'cancelUrl': cancelUrl,
      'returnUrl': returnUrl,
      'signature': signature,
      'items': [
        {
          'name': description,
          'quantity': 1,
          'price': amount,
        }
      ],
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/v2/payment-requests'),
      headers: {
        'x-client-id': _clientId,
        'x-api-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['code'] != '00') {
      throw Exception(json['desc'] ?? 'Tạo link thanh toán thất bại');
    }

    return json['data'] as Map<String, dynamic>;
    // Trả về: { qrCode, checkoutUrl, amount, orderCode, ... }
  }
  /// Kiểm tra trạng thái đơn hàng theo orderCode
  static Future<String> getPaymentStatus(int orderCode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/v2/payment-requests/$orderCode'),
      headers: {
        'x-client-id': _clientId,
        'x-api-key': _apiKey,
      },
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != '00') {
      throw Exception(json['desc'] ?? 'Không lấy được trạng thái');
    }

    // Trả về: PENDING | PAID | CANCELLED | EXPIRED
    return (json['data']['status'] as String);
  }
  static Future<void> cancelPaymentLink(int orderCode) async {
    final response = await http
        .delete(
      Uri.parse('$_baseUrl/v2/payment-requests/$orderCode'),
      headers: {
        'x-client-id':  _clientId,
        'x-api-key':    _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'cancellationReason': 'Hết thời gian thanh toán'}),
    )
        .timeout(const Duration(seconds: 10));

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != '00') {
      throw Exception(json['desc'] ?? 'Hủy đơn thất bại');
    }
  }
}