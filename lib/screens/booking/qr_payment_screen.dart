import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import 'payos_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import 'booking_success_screen.dart';

class QrPaymentScreen extends StatefulWidget {
  final BookingModel booking;
  const QrPaymentScreen({super.key, required this.booking});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen>
    with SingleTickerProviderStateMixin {
  static const double _discountPercent  = 0.15;
  static const _pollInterval            = Duration(seconds: 5);
  static const _timeoutSeconds          = 60; // ← timeout 1 phút

  final _bookingRepo = BookingRepository();

  String? _qrCode;
  int?    _orderCode;
  bool    _isLoadingQr  = true;
  String? _qrError;
  bool    _isPaid       = false;
  bool    _isConfirming = false;

  // Countdown
  int   _secondsLeft  = _timeoutSeconds;
  bool  _isTimedOut   = false;
  Timer? _pollTimer;
  Timer? _countdownTimer;

  late final AnimationController _successAnim;
  late final Animation<double>   _scaleAnim;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _successAnim, curve: Curves.easeIn);
    _loadPayOSQr();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _successAnim.dispose();
    super.dispose();
  }

  // ── 1. Tạo QR ─────────────────────────────────────────────────────────────
  Future<void> _loadPayOSQr() async {
    setState(() {
      _isLoadingQr   = true;
      _qrError       = null;
      _isPaid        = false;
      _isTimedOut    = false;
      _secondsLeft   = _timeoutSeconds;
    });

    final booking    = widget.booking;
    final int finalAmount = (booking.totalPrice * (1 - _discountPercent)).round();
    final desc       = 'DH${booking.id.substring(0, 5).toUpperCase()}';

    try {
      final data = await PayOSService.createPaymentLink(
        amount:      finalAmount,
        description: desc,
        bookingId:   booking.id,
      );

      if (!mounted) return;
      setState(() {
        _qrCode      = data['qrCode'] as String?;
        _orderCode   = data['orderCode'] as int?;
        _isLoadingQr = false;
      });

      _startPolling();
      _startCountdown(); // ← bắt đầu đếm ngược
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _qrError     = e.toString();
        _isLoadingQr = false;
      });
    }
  }

  // ── 2. Countdown 60 giây ──────────────────────────────────────────────────
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }

      if (_secondsLeft <= 1) {
        timer.cancel();
        _onTimeout();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  // ── 3. Hết giờ ────────────────────────────────────────────────────────────
  Future<void> _onTimeout() async {
    _pollTimer?.cancel();

    setState(() => _isTimedOut = true);

    // Hủy đơn PayOS bất đồng bộ (không cần await, không block UI)
    if (_orderCode != null) {
      PayOSService.cancelPaymentLink(_orderCode!).catchError((_) {});
    }

    // Hủy booking trong DB
    try {
      await _bookingRepo.cancelBooking(widget.booking.id);
    } catch (_) {}

    if (!mounted) return;

    // Hiện dialog thông báo rồi quay về trang chủ
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer_off_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Hết thời gian'),
          ],
        ),
        content: const Text(
          'Phiên thanh toán đã hết hạn.\nĐặt phòng của bạn đã bị hủy.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();         // đóng dialog
              Navigator.of(context).popUntil(      // về trang chủ
                    (route) => route.isFirst,
              );
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  // ── 4. Polling PayOS ──────────────────────────────────────────────────────
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_orderCode == null || _isPaid || _isTimedOut) return;
    try {
      final status = await PayOSService.getPaymentStatus(_orderCode!);
      if (status == 'PAID' && mounted) {
        _pollTimer?.cancel();
        _countdownTimer?.cancel(); // ← dừng đếm ngược khi đã thanh toán
        await _onPaymentDetected();
      }
    } catch (_) {}
  }

  // ── 5. Thanh toán thành công ───────────────────────────────────────────────
  Future<void> _onPaymentDetected() async {
    setState(() => _isConfirming = true);

    BookingModel? updated;
    try {
      updated = await _bookingRepo.updateBookingStatusToSuccess(widget.booking.id);
    } catch (_) {
      updated = widget.booking;
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BookingSuccessScreen(booking: updated!)),
      );
    }
  }

  // ── 6. Nút xác nhận thủ công ─────────────────────────────────────────────
  Future<void> _onManualConfirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    try {
      final updated = await _bookingRepo.updateBookingStatusToSuccess(
        widget.booking.id,
      );
      if (mounted) {
        _pollTimer?.cancel();
        _countdownTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BookingSuccessScreen(booking: updated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  // ── Widget: Countdown bar ─────────────────────────────────────────────────
  Widget _buildCountdownBar() {
    final progress = _secondsLeft / _timeoutSeconds;
    final isUrgent = _secondsLeft <= 15;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thời gian còn lại',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${_secondsLeft}s',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isUrgent ? AppColors.error : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.surfaceDark,
            valueColor: AlwaysStoppedAnimation(
              isUrgent ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Widget: QR section ────────────────────────────────────────────────────
  Widget _buildQrSection() {
    if (_isPaid) {
      return FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceDark),
            ),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 48),
                ),
                const SizedBox(height: 16),
                const Text('Thanh toán thành công!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  'Đặt phòng của bạn đã được xác nhận.\nCảm ơn bạn đã sử dụng dịch vụ!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                if (_isConfirming) ...[
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoadingQr) {
      return _qrBox(
        child: const SizedBox(
          width: 220, height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_qrError != null || _qrCode == null) {
      return _qrBox(
        child: SizedBox(
          width: 220, height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 36),
              const SizedBox(height: 8),
              Text('Không tải được mã QR',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              TextButton(onPressed: _loadPayOSQr, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    return _qrBox(
      child: QrImageView(
        data: _qrCode!,
        version: QrVersions.auto,
        size: 220,
        eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square, color: Colors.black),
        dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square, color: Colors.black),
      ),
    );
  }

  Widget _qrBox({required Widget child}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.surfaceDark),
    ),
    child: child,
  );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            _pollTimer?.cancel();
            _countdownTimer?.cancel();
            Navigator.pop(context);
          },
          color: AppColors.textPrimary,
        ),
        title: const Text('Thanh toán',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Thông tin đơn hàng
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.hotelName,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(booking.roomName,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const Divider(height: 20),
                  _infoRow('Số đêm', '${booking.numberOfNights} đêm'),
                  const SizedBox(height: 8),
                  _infoRow('Tạm tính',
                      CurrencyFormatter.format(booking.totalPrice)),
                  const SizedBox(height: 8),
                  _infoRow(
                    'Giảm giá (15%)',
                    '-${CurrencyFormatter.format(booking.totalPrice * _discountPercent)}',
                    highlight: true,
                  ),
                  const Divider(height: 20),
                  _infoRow(
                    'Tổng thanh toán',
                    CurrencyFormatter.format(
                        booking.totalPrice * (1 - _discountPercent)),
                    bold: true,
                    highlight: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Countdown bar — chỉ hiện khi đang chờ thanh toán
            if (!_isPaid && !_isLoadingQr && _qrCode != null && !_isTimedOut)
              _buildCountdownBar(),

            const SizedBox(height: 16),

            if (!_isPaid)
              const Text('Quét mã để thanh toán',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),

            const SizedBox(height: 12),

            _buildQrSection(),

            if (!_isPaid) ...[
              const SizedBox(height: 8),
              Text('Chuyển khoản đúng số tiền trên',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13)),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isConfirming || _isTimedOut ? null : _onManualConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: _isConfirming
                    ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
                    : Text(_isPaid
                    ? 'Xem chi tiết đặt phòng'
                    : 'Đã thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {bool bold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: highlight ? AppColors.primary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }
}