import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../presentation/bloc/user_bloc.dart';
import '../../presentation/bloc/user_state.dart' as user_states;
import '../../presentation/bloc/user_event.dart' as user_events;
import '../../../../core/widgets/loading_overlay.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/dialog_utils.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _isEditing = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String _gender = 'Male';

  DateTime? _pickedDob;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && state.userEntity != null) {
      final u = state.userEntity!;
      _nameCtrl.text = u.name;
      _phoneCtrl.text = u.phoneNumber;
      _addressCtrl.text = u.address;
      _dobCtrl.text = _formatDob(u.dateOfBirth);
      _gender = u.gender.isNotEmpty ? u.gender : 'Male';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          'Edit Profile', 
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: context.responsiveFontSize(
              verySmall: 16,
              small: 18,
              large: 18,
            ),
          ),
        ),
      ),
      body: BlocConsumer<UserBloc, user_states.UserState>(
        listener: (context, state) {
          if (state is user_states.UserUpdateSuccess) {
            // Update local controls immediately from current inputs
            setState(() => _isEditing = false);
            // Ask AuthBloc to refresh and save to storage (Profile UI reads from UserStorage)
            context.read<AuthBloc>().add(GetUserProfileRequested());
            DialogUtils.showSuccessDialog(context: context, message: 'Profile updated successfully');
          } else if (state is user_states.UserError) {
            DialogUtils.showErrorDialog(context: context, message: state.message);
          }
        },
        builder: (context, userState) {
          final isLoading = userState is user_states.UserLoading;
          final authState = context.watch<AuthBloc>().state;

          if (authState is! AuthAuthenticated || authState.userEntity == null) {
            return const Center(child: Text('No profile available'));
          }

          final u = authState.userEntity!;

          return Stack(
            children: [
              ListView(
                padding: context.responsivePadding(
                  horizontal: context.responsive(
                    verySmall: 16,
                    small: 18,
                    large: 20,
                  ),
                  vertical: context.responsive(
                    verySmall: 12,
                    small: 14,
                    large: 16,
                  ),
                ),
                children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_isEditing) {
                        _pickAvatar();
                      } else {
                        _openAvatarPreview(
                          filePath: _avatarPath,
                          url: u.hasValidAvatar ? u.avatar : null,
                          initials: u.avatarInitials,
                        );
                      }
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: context.responsive(
                            verySmall: 40,
                            small: 44,
                            large: 48,
                          ),
                          backgroundColor: AppColors.bellBackground,
                          backgroundImage: _avatarPath != null
                              ? FileImage(File(_avatarPath!))
                              : (u.hasValidAvatar ? NetworkImage(u.avatar!) as ImageProvider : null),
                          child: _avatarPath == null && !u.hasValidAvatar ? Text(
                            u.avatarInitials,
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 20,
                                small: 24,
                                large: 28,
                              ),
                            ),
                          ) : null,
                        ),
                        if (_isEditing) ...[
                          SizedBox(height: context.responsiveSpacing(
                            verySmall: 8,
                            small: 10,
                            large: 10,
                          )),
                          Text(
                            'Change Profile Picture',
                            style: TextStyle(
                              color: AppColors.accentOrange, 
                              fontWeight: FontWeight.w600,
                              fontSize: context.responsiveFontSize(
                                verySmall: 12,
                                small: 14,
                                large: 14,
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 12,
                  small: 14,
                  large: 16,
                )),
                _label('Name'),
                _filledField(controller: _nameCtrl, readOnly: !_isEditing),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 10,
                  small: 12,
                  large: 12,
                )),
                _label('Email'),
                _filledField(controller: TextEditingController(text: u.email), readOnly: true),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 10,
                  small: 12,
                  large: 12,
                )),
                _label('Phone'),
                _filledField(controller: _phoneCtrl, readOnly: !_isEditing, keyboardType: TextInputType.phone),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 10,
                  small: 12,
                  large: 12,
                )),
                _label('Address'),
                _filledField(controller: _addressCtrl, readOnly: !_isEditing),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 10,
                  small: 12,
                  large: 12,
                )),
                _label('Date of Birth'),
                TextFormField(
                  controller: _dobCtrl,
                  readOnly: true,
                  onTap: _isEditing ? _pickDate : null,
                  decoration: _filledDecoration(hint: 'dd/MM/yyyy'),
                ),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 10,
                  small: 12,
                  large: 12,
                )),
                _label('Gender'),
                _genderRadios(readOnly: !_isEditing),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 16,
                  small: 18,
                  large: 20,
                )),
                if (!_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.responsive(
                            verySmall: 10,
                            small: 12,
                            large: 12,
                          )),
                        ),
                        padding: context.responsivePadding(
                          vertical: context.responsive(
                            verySmall: 12,
                            small: 14,
                            large: 14,
                          ),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 14,
                            small: 16,
                            large: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _onCancel(u),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentOrange,
                            side: const BorderSide(color: AppColors.accentOrange, width: 1.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.responsive(
                                verySmall: 10,
                                small: 12,
                                large: 12,
                              )),
                            ),
                            padding: context.responsivePadding(
                              vertical: context.responsive(
                                verySmall: 12,
                                small: 14,
                                large: 14,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 14,
                                small: 16,
                                large: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing(
                        verySmall: 10,
                        small: 12,
                        large: 12,
                      )),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.responsive(
                                verySmall: 10,
                                small: 12,
                                large: 12,
                              )),
                            ),
                            padding: context.responsivePadding(
                              vertical: context.responsive(
                                verySmall: 12,
                                small: 14,
                                large: 14,
                              ),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 14,
                                small: 16,
                                large: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: context.responsiveSpacing(
                  verySmall: 6,
                  small: 8,
                  large: 8,
                )),
                ],
              ),
              LoadingOverlay(isLoading: isLoading),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onSave() async {
    context.read<UserBloc>().add(user_events.UpdateUserProfileRequested(
          dateOfBirth: _toIsoFromDisplay(_dobCtrl.text.trim()),
          address: _addressCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          gender: _gender,
          avatarFilePath: _avatarPath,
        ));
  }

  void _onCancel(dynamic u) {
    // Reset fields to current user values
    _nameCtrl.text = u.name;
    _phoneCtrl.text = u.phoneNumber;
    _addressCtrl.text = u.address;
    _dobCtrl.text = _formatDob(u.dateOfBirth);
    _gender = u.gender.isNotEmpty ? u.gender : 'Male';
    _avatarPath = null;
    setState(() => _isEditing = false);
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.responsiveFontSize(
            verySmall: 12,
            small: 13,
            large: 13,
          ),
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
  
  InputDecoration _filledDecoration({String? hint}) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.responsive(
        verySmall: 10,
        small: 12,
        large: 12,
      )),
      borderSide: BorderSide(color: AppColors.accentOrange.withValues(alpha: 0.4), width: 1.2),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: baseBorder,
      border: baseBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.responsive(
          verySmall: 10,
          small: 12,
          large: 12,
        )),
        borderSide: const BorderSide(color: AppColors.accentOrange, width: 1.6),
      ),
      contentPadding: context.responsivePadding(
        horizontal: context.responsive(
          verySmall: 14,
          small: 16,
          large: 16,
        ),
        vertical: context.responsive(
          verySmall: 12,
          small: 14,
          large: 14,
        ),
      ),
    );
  }

  Widget _filledField({
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: _filledDecoration(),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _pickedDob ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _pickedDob = picked;
        _dobCtrl.text = _format(d: picked);
      });
    }
  }

  String _formatDob(String isoOrPlain) {
    try {
      DateTime d;
      if (isoOrPlain.contains('-')) {
        d = DateTime.parse(isoOrPlain);
      } else if (isoOrPlain.contains('/')) {
        final parts = isoOrPlain.split('/');
        if (parts.length == 3) {
          d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          return isoOrPlain;
        }
      } else {
        return isoOrPlain;
      }
      return _format(d: d);
    } catch (_) {
      return isoOrPlain;
    }
  }

  String _toIsoFromDisplay(String ddmmyyyy) {
    try {
      final parts = ddmmyyyy.split('/');
      if (parts.length == 3) {
        final d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        return d.toIso8601String();
      }
    } catch (_) {}
    return ddmmyyyy;
  }

  String _format({required DateTime d}) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Widget _genderRadios({bool readOnly = false}) {
    return Row(
      children: [
        _genderRadio('Male', readOnly: readOnly),
        SizedBox(width: context.responsiveSpacing(
          verySmall: 10,
          small: 12,
          large: 12,
        )),
        _genderRadio('Female', readOnly: readOnly),
      ],
    );
  }

  Widget _genderRadio(String value, {bool readOnly = false}) {
    return Expanded(
      child: InkWell(
        onTap: readOnly ? null : () => setState(() => _gender = value),
        child: Container(
          height: context.responsive(
            verySmall: 44,
            small: 48,
            large: 48,
          ),
          decoration: BoxDecoration(
            color: AppColors.bellBackground,
            borderRadius: BorderRadius.circular(context.responsive(
              verySmall: 10,
              small: 12,
              large: 12,
            )),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: value,
                groupValue: _gender,
                onChanged: readOnly ? null : (v) => setState(() => _gender = v ?? _gender),
                fillColor: WidgetStateProperty.all(AppColors.accentOrange),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 14,
                    small: 16,
                    large: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
    }
  }

  void _openAvatarPreview({String? filePath, String? url, required String initials}) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) {
        Widget imageWidget;
        if (filePath != null && filePath.isNotEmpty) {
          imageWidget = Image.file(File(filePath), fit: BoxFit.contain);
        } else if (url != null && url.isNotEmpty) {
          imageWidget = Image.network(url, fit: BoxFit.contain);
        } else {
          imageWidget = Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w700),
            ),
          );
        }

        return GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  child: imageWidget,
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


