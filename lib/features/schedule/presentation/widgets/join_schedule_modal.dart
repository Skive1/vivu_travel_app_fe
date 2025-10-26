import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../data/models/join_schedule_request.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class JoinScheduleModal extends StatefulWidget {
  const JoinScheduleModal({super.key});

  @override
  State<JoinScheduleModal> createState() => _JoinScheduleModalState();
}

class _JoinScheduleModalState extends State<JoinScheduleModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  MobileScannerController? _scannerController;
  bool _isQRScanning = false;
  bool _isProcessingQR = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isProcessingQR = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) async {
        if (state is JoinScheduleSuccess) {
          // Đóng modal trước
          Navigator.of(context).pop();
          
          // Hiển thị dialog thành công
          await DialogUtils.showSuccessDialog(
            context: context,
            title: 'Tham gia thành công',
            message: 'Bạn đã tham gia lịch trình thành công!',
            useRootNavigator: true,
          );
        } else if (state is JoinScheduleError) {
          await DialogUtils.showErrorDialog(
            context: context,
            title: 'Tham gia thất bại',
            message: state.message,
            useRootNavigator: true,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is JoinScheduleLoading;
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Tham gia lịch trình',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Tab bar (Segmented control style)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(vertical: 6),
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(
                      iconMargin: EdgeInsets.only(bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.password_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Nhập mã'),
                        ],
                      ),
                    ),
                    Tab(
                      iconMargin: EdgeInsets.only(bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Quét QR'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildManualInputTab(isLoading),
                    _buildQRScanTab(isLoading),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManualInputTab(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập mã chia sẻ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập mã chia sẻ mà bạn nhận được từ người tạo lịch trình',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'Nhập mã chia sẻ',
                prefixIcon: const Icon(Icons.code, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mã chia sẻ';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _joinWithCode,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login),
                label: const Text('Tham gia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScanTab(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quét mã QR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quét mã QR để tham gia lịch trình một cách nhanh chóng',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isQRScanning
                    ? MobileScanner(
                        controller: _scannerController!,
                        onDetect: _onQRDetect,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Nhấn để bắt đầu quét QR',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final hasPermission = await _checkCameraPermission();
                                if (hasPermission) {
                                  _scannerController = MobileScannerController();
                                  setState(() {
                                    _isQRScanning = true;
                                  });
                                }
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Bắt đầu quét'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          if (_isQRScanning) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isQRScanning = false;
                  });
                  _scannerController?.dispose();
                  _scannerController = null;
                },
                icon: const Icon(Icons.stop),
                label: const Text('Dừng quét'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onQRDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isProcessingQR) {
      final String? code = barcodes.first.rawValue;
      if (code != null && _isQRScanning) {
        // Đánh dấu đang xử lý để tránh multiple requests
        setState(() {
          _isProcessingQR = true;
          _isQRScanning = false;
        });
        
        // Dừng scanner ngay lập tức
        _scannerController?.dispose();
        _scannerController = null;
        
        _joinWithQRCode(code);
      }
    }
  }

  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      await DialogUtils.showErrorDialog(
        context: context,
        title: 'Quyền camera bị từ chối',
        message: 'Vui lòng bật quyền camera trong cài đặt để sử dụng tính năng quét QR.',
        useRootNavigator: true,
      );
      return false;
    }
    return false;
  }

  void _joinWithCode() {
    if (_formKey.currentState!.validate()) {
      final request = JoinScheduleRequest(shareCode: _codeController.text.trim());
      context.read<ScheduleBloc>().add(JoinScheduleEvent(request: request));
    }
  }

  void _joinWithQRCode(String qrCode) {
    final request = JoinScheduleRequest(shareCode: qrCode);
    context.read<ScheduleBloc>().add(JoinScheduleEvent(request: request));
  }
}
