import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../domain/entities/checked_item_entity.dart';
import '../../data/models/add_checked_item_request.dart';

class CheckedItemsModal extends StatefulWidget {
  final String scheduleId;
  final String? userRole;

  const CheckedItemsModal({
    Key? key,
    required this.scheduleId,
    this.userRole,
  }) : super(key: key);

  @override
  State<CheckedItemsModal> createState() => _CheckedItemsModalState();
}

class _CheckedItemsModalState extends State<CheckedItemsModal> {
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _itemFocusNode = FocusNode();
  List<CheckedItemEntity> _checkedItems = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  Set<int> _selectedItemIds = {};

  bool get _isOwner => widget.userRole?.toLowerCase() == 'owner';

  @override
  void initState() {
    super.initState();
    // Load checked items when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleBloc>().add(GetCheckedItemsEvent(scheduleId: widget.scheduleId));
    });
  }

  @override
  void dispose() {
    _itemController.dispose();
    _itemFocusNode.dispose();
    super.dispose();
  }

  void _addCheckedItem() {
    final itemName = _itemController.text.trim();
    if (itemName.isEmpty) return;

    final request = AddCheckedItemRequest(
      name: itemName,
      scheduleId: widget.scheduleId,
    );

    context.read<ScheduleBloc>().add(AddCheckedItemEvent(request: [request]));
    _itemController.clear();
    _itemFocusNode.unfocus();
  }

  void _toggleCheckedItem(CheckedItemEntity item) {
    context.read<ScheduleBloc>().add(
      ToggleCheckedItemEvent(
        checkedItemId: item.checkedItemId,
        isChecked: !item.isChecked,
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItemIds.clear();
      }
    });
  }

  void _toggleItemSelection(int itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
      } else {
        _selectedItemIds.add(itemId);
      }
    });
  }

  void _deleteSelectedItems() {
    if (_selectedItemIds.isEmpty) return;

    _showDeleteConfirmDialog();
  }

  void _showDeleteConfirmDialog() {
    final selectedItems = _checkedItems
        .where((item) => _selectedItemIds.contains(item.checkedItemId))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.delete_forever,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Xóa mục kiểm tra',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Count info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedItemIds.length} mục được chọn',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items list
              if (selectedItems.length <= 5) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = selectedItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.checklist,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.checkedItemName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.checklist,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedItems[i].checkedItemName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (i < 2) const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '... và ${selectedItems.length - 3} mục khác',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Warning message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Hành động này không thể hoàn tác!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<ScheduleBloc>().add(
                          DeleteCheckedItemsBulkEvent(checkedItemIds: _selectedItemIds.toList()),
                        );
                        setState(() {
                          _isSelectionMode = false;
                          _selectedItemIds.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Xóa ${_selectedItemIds.length} mục',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is GetCheckedItemsSuccess) {
          setState(() {
            _checkedItems = state.checkedItems;
            _isLoading = false;
          });
        } else if (state is GetCheckedItemsLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is GetCheckedItemsError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tải danh sách: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AddCheckedItemSuccess) {
          // Refresh the list after adding
          context.read<ScheduleBloc>().add(GetCheckedItemsEvent(scheduleId: widget.scheduleId));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm mục kiểm tra'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AddCheckedItemError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi thêm mục: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is ToggleCheckedItemSuccess) {
          // Update the item in the list
          setState(() {
            final index = _checkedItems.indexWhere(
              (item) => item.checkedItemId == state.checkedItem.checkedItemId,
            );
            if (index != -1) {
              _checkedItems[index] = state.checkedItem;
            }
          });
        } else if (state is ToggleCheckedItemError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi cập nhật: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is DeleteCheckedItemsBulkSuccess) {
          // Remove the items from the list
          setState(() {
            _checkedItems.removeWhere(
              (item) => state.deletedItemIds.contains(item.checkedItemId),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa ${state.deletedItemIds.length} mục kiểm tra'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is DeleteCheckedItemsBulkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xóa mục: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.checklist,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Danh sách kiểm tra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_checkedItems.isNotEmpty && _isOwner)
                    IconButton(
                      onPressed: _toggleSelectionMode,
                      icon: Icon(
                        _isSelectionMode ? Icons.cancel : Icons.delete_sharp,
                        color: _isSelectionMode ? AppColors.error : AppColors.primary,
                      ),
                      tooltip: _isSelectionMode ? 'Hủy chọn' : 'Chọn để xóa',
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Add item section - Only for Owner
            if (_isOwner)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _itemController,
                        focusNode: _itemFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Thêm mục kiểm tra mới...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _addCheckedItem(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _addCheckedItem,
                        icon: const Icon(Icons.add, color: Colors.white),
                        tooltip: 'Thêm mục',
                      ),
                    ),
                  ],
                ),
              ),

            // Selection action bar - Only for Owner
            if (_isSelectionMode && _isOwner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedItemIds.isEmpty 
                          ? 'Chọn các mục cần xóa'
                          : 'Đã chọn ${_selectedItemIds.length} mục để xóa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedItemIds.isNotEmpty)
                      TextButton.icon(
                        onPressed: _deleteSelectedItems,
                        icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                        label: Text(
                          'Xóa ${_selectedItemIds.length} mục',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Items list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _checkedItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _checkedItems.length,
                          itemBuilder: (context, index) {
                            final item = _checkedItems[index];
                            return _buildCheckedItemCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.checklist_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có mục kiểm tra nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (_isOwner)
            const Text(
              'Thêm mục kiểm tra đầu tiên của bạn',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            )
          else
            const Text(
              'Chỉ Owner mới có thể thêm và xóa mục kiểm tra',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 16),
          if (_isOwner)
            const Text(
              '💡 Mẹo: Sử dụng nút "Chọn để xóa" để xóa nhiều mục cùng lúc',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildCheckedItemCard(CheckedItemEntity item) {
    final isSelected = _selectedItemIds.contains(item.checkedItemId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : (item.isChecked ? AppColors.primary : AppColors.border),
          width: isSelected ? 2 : (item.isChecked ? 2 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isSelectionMode
              ? () => _isOwner ? _toggleItemSelection(item.checkedItemId) : null
              : () => _toggleCheckedItem(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Selection checkbox (Owner only) or item checkbox (all roles)
                if (_isSelectionMode && _isOwner) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                ] else ...[
                  // Item checkbox - Available for all roles
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.isChecked ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: item.isChecked ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: item.isChecked
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                ],

                // Item content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.checkedItemName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: item.isChecked ? AppColors.textSecondary : AppColors.textPrimary,
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (item.isChecked) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Đã kiểm tra lúc ${_formatDateTime(item.checkedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action buttons - Toggle for all roles, selection only for Owner
                if (!_isSelectionMode) ...[
                  // Toggle button - Available for all roles
                  IconButton(
                    onPressed: () => _toggleCheckedItem(item),
                    icon: Icon(
                      item.isChecked ? Icons.undo : Icons.check,
                      color: item.isChecked ? AppColors.textSecondary : AppColors.primary,
                      size: 20,
                    ),
                    tooltip: item.isChecked ? 'Bỏ đánh dấu' : 'Đánh dấu',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
