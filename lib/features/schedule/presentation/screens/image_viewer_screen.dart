import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/media_entity.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<MediaEntity> mediaList;
  final int initialIndex;

  const ImageViewerScreen({
    Key? key,
    required this.mediaList,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Color _getTypeColor(int uploadMethod) {
    switch (uploadMethod) {
      case 0: // Check-in
        return AppColors.success;
      case 1: // Check-out
        return AppColors.primary;
      case 2: // Normal
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for swiping between images
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _resetZoom(); // Reset zoom when changing images
            },
            itemCount: widget.mediaList.length,
            itemBuilder: (context, index) {
              final media = widget.mediaList[index];
              return GestureDetector(
                onTap: _toggleControls,
                onDoubleTap: _resetZoom,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: Center(
                    child: Image.network(
                      media.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top controls
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + context.responsive(
                    verySmall: 6,
                    small: 8,
                    large: 10,
                  ),
                  left: context.responsive(
                    verySmall: 10,
                    small: 12,
                    large: 20,
                  ),
                  right: context.responsive(
                    verySmall: 10,
                    small: 12,
                    large: 20,
                  ),
                  bottom: context.responsive(
                    verySmall: 6,
                    small: 8,
                    large: 10,
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                          verySmall: 12,
                          small: 16,
                          large: 20,
                        )),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: context.responsiveIconSize(
                            verySmall: 16,
                            small: 18,
                            large: 20,
                          ),
                        ),
                        padding: context.responsivePadding(
                          all: context.responsive(
                            verySmall: 6,
                            small: 8,
                            large: 12,
                          ),
                        ),
                        constraints: context.responsive(
                          verySmall: BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          small: BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          large: BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Image counter
                    Container(
                      padding: context.responsivePadding(
                        horizontal: context.responsive(
                          verySmall: 6,
                          small: 8,
                          large: 12,
                        ),
                        vertical: context.responsive(
                          verySmall: 3,
                          small: 4,
                          large: 6,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                          verySmall: 8,
                          small: 12,
                          large: 16,
                        )),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.mediaList.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.responsiveFontSize(
                            verySmall: 10,
                            small: 12,
                            large: 14,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Close button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                          verySmall: 12,
                          small: 16,
                          large: 20,
                        )),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: context.responsiveIconSize(
                            verySmall: 18,
                            small: 20,
                            large: 24,
                          ),
                        ),
                        padding: context.responsivePadding(
                          all: context.responsive(
                            verySmall: 6,
                            small: 8,
                            large: 12,
                          ),
                        ),
                        constraints: context.responsive(
                          verySmall: BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          small: BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          large: BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom info panel
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: context.responsive(
                    verySmall: 10,
                    small: 12,
                    large: 20,
                  ),
                  right: context.responsive(
                    verySmall: 10,
                    small: 12,
                    large: 20,
                  ),
                  top: context.responsive(
                    verySmall: 10,
                    small: 12,
                    large: 20,
                  ),
                  bottom: MediaQuery.of(context).padding.bottom + context.responsive(
                    verySmall: 10,
                    small: 12,
                    large: 20,
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Participant info
                    if (widget.mediaList[_currentIndex].participantName != null && 
                        widget.mediaList[_currentIndex].participantName!.isNotEmpty) ...[
                      Row(
                        children: [
                          // Avatar
                          if (widget.mediaList[_currentIndex].participantAvatar != null && 
                              widget.mediaList[_currentIndex].participantAvatar!.isNotEmpty)
                            Container(
                              width: context.responsive(
                                verySmall: 24,
                                small: 28,
                                large: 32,
                              ),
                              height: context.responsive(
                                verySmall: 24,
                                small: 28,
                                large: 32,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  widget.mediaList[_currentIndex].participantAvatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[800],
                                    child: Icon(
                                      Icons.person,
                                      size: context.responsive(
                                        verySmall: 12,
                                        small: 14,
                                        large: 16,
                                      ),
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.mediaList[_currentIndex].participantAvatar != null && 
                              widget.mediaList[_currentIndex].participantAvatar!.isNotEmpty)
                            SizedBox(width: context.responsive(
                              verySmall: 8,
                              small: 10,
                              large: 12,
                            )),
                          // Name
                          Expanded(
                            child: Text(
                              widget.mediaList[_currentIndex].participantName!,
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 12,
                                  small: 14,
                                  large: 16,
                                ),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          // Upload date
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(
                              DateTime.parse(widget.mediaList[_currentIndex].uploadedAt),
                            ),
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 8,
                                small: 10,
                                large: 12,
                              ),
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveSpacing(
                        verySmall: 8,
                        small: 10,
                        large: 12,
                      )),
                    ] else ...[
                      // Fallback: Media type and date only
                      Row(
                        children: [
                          Container(
                            padding: context.responsivePadding(
                              horizontal: context.responsive(
                                verySmall: 6,
                                small: 8,
                                large: 12,
                              ),
                              vertical: context.responsive(
                                verySmall: 3,
                                small: 4,
                                large: 6,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(widget.mediaList[_currentIndex].uploadMethod),
                              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                                verySmall: 8,
                                small: 12,
                                large: 16,
                              )),
                            ),
                            child: Text(
                              widget.mediaList[_currentIndex].uploadMethodText,
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 8,
                                  small: 10,
                                  large: 12,
                                ),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(
                              DateTime.parse(widget.mediaList[_currentIndex].uploadedAt),
                            ),
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 8,
                                small: 10,
                                large: 12,
                              ),
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveSpacing(
                        verySmall: 8,
                        small: 10,
                        large: 12,
                      )),
                    ],

                    // Media type badge
                    Container(
                      padding: context.responsivePadding(
                        horizontal: context.responsive(
                          verySmall: 6,
                          small: 8,
                          large: 12,
                        ),
                        vertical: context.responsive(
                          verySmall: 3,
                          small: 4,
                          large: 6,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(widget.mediaList[_currentIndex].uploadMethod),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                          verySmall: 8,
                          small: 12,
                          large: 16,
                        )),
                      ),
                      child: Text(
                        widget.mediaList[_currentIndex].uploadMethodText,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 8,
                            small: 10,
                            large: 12,
                          ),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Description
                    if (widget.mediaList[_currentIndex].description != null && 
                        widget.mediaList[_currentIndex].description!.isNotEmpty) ...[
                      SizedBox(height: context.responsiveSpacing(
                        verySmall: 6,
                        small: 8,
                        large: 12,
                      )),
                      Text(
                        widget.mediaList[_currentIndex].description!,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 10,
                            small: 12,
                            large: 14,
                          ),
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    
                    // Instructions
                    SizedBox(height: context.responsiveSpacing(
                      verySmall: 10,
                      small: 12,
                      large: 16,
                    )),
                    Center(
                      child: Container(
                        padding: context.responsivePadding(
                          horizontal: context.responsive(
                            verySmall: 10,
                            small: 12,
                            large: 16,
                          ),
                          vertical: context.responsive(
                            verySmall: 4,
                            small: 6,
                            large: 8,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                            verySmall: 12,
                            small: 16,
                            large: 20,
                          )),
                        ),
                        child: Text(
                          context.isVerySmallPhone || context.isSmallPhone
                            ? 'Vuốt để xem hình khác • Chạm để ẩn/hiện'
                            : 'Vuốt để xem hình khác • Chạm để ẩn/hiện điều khiển • Double-tap để reset zoom',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: context.responsiveFontSize(
                              verySmall: 8,
                              small: 10,
                              large: 12,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Zoom controls (only show when zoomed)
          if (_showControls && _transformationController.value != Matrix4.identity())
            Positioned(
              top: MediaQuery.of(context).padding.top + context.responsive(
                verySmall: 50,
                small: 60,
                large: 80,
              ),
              left: context.responsive(
                verySmall: 10,
                small: 12,
                large: 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                    verySmall: 12,
                    small: 16,
                    large: 20,
                  )),
                ),
                child: IconButton(
                  onPressed: _resetZoom,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: context.responsiveIconSize(
                      verySmall: 18,
                      small: 20,
                      large: 24,
                    ),
                  ),
                  padding: context.responsivePadding(
                    all: context.responsive(
                      verySmall: 6,
                      small: 8,
                      large: 12,
                    ),
                  ),
                  constraints: context.responsive(
                    verySmall: BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    small: BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    large: BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
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
