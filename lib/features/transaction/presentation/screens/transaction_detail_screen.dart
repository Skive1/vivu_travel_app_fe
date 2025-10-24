import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';
import '../widgets/transaction_detail_app_bar.dart';
import '../widgets/transaction_detail_content.dart';
import '../../../../core/widgets/page_manager.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionEntity transaction;
  final PageManager? pageManager;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.pageManager,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Custom App Bar - extends behind status bar
          TransactionDetailAppBar(
            transaction: widget.transaction,
            pageManager: widget.pageManager,
          ),
          
          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideAnimation,
                  curve: Curves.easeOutCubic,
                )),
                child: RepaintBoundary(
                  child: TransactionDetailContent(
                    transaction: widget.transaction,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
