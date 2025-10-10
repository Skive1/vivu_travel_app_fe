import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../presentation/bloc/user_bloc.dart';
import '../../presentation/bloc/user_event.dart' as user_events;
import '../../presentation/bloc/user_state.dart' as user_states;
import '../../../../core/widgets/loading_overlay.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String _gender = 'Male';
  String? _avatarPath;

  DateTime? _pickedDob;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && state.userEntity != null) {
      final u = state.userEntity!;
      _nameCtrl.text = u.name;
      _phoneCtrl.text = u.phoneNumber;
      _addressCtrl.text = u.address;
      _dobCtrl.text = u.dateOfBirth;
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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() != true) return;
              context.read<UserBloc>().add(user_events.UpdateUserProfileRequested(
                    dateOfBirth: _dobCtrl.text.trim(),
                    address: _addressCtrl.text.trim(),
                    name: _nameCtrl.text.trim(),
                    phoneNumber: _phoneCtrl.text.trim(),
                    gender: _gender,
                    avatarFilePath: _avatarPath,
                  ));
            },
            child: const Text('Done', style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.w600)),
          )
        ],
      ),
      body: BlocConsumer<UserBloc, user_states.UserState>(
        listener: (context, state) {
          if (state is user_states.UserUpdateSuccess) {
            // After user update succeeds, refresh auth profile and close
            context.read<AuthBloc>().add(GetUserProfileRequested());
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is user_states.UserLoading;
          return Stack(
            children: [
              SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.bellBackground,
                            backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                            child: _avatarPath == null ? const Icon(Icons.person, size: 40) : null,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Change Profile Picture',
                            style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _label('First Name'),
                    _filledField(
                      controller: _nameCtrl,
                      hint: 'Leonardo',
                    ),
                    const SizedBox(height: 14),
                    _label('Last Name'),
                    _filledField(
                      controller: TextEditingController(),
                      hint: 'Optional',
                    ),
                    const SizedBox(height: 14),
                    _label('Location'),
                    _filledField(
                      controller: _addressCtrl,
                      hint: 'Your address',
                    ),
                    const SizedBox(height: 14),
                    _label('Mobile Number'),
                    _filledField(
                      controller: _phoneCtrl,
                      hint: '+84 0123-456-789',
                      keyboardType: TextInputType.phone,
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Text('+84', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _label('Date of Birth'),
                    TextFormField(
                      controller: _dobCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _filledDecoration(hint: 'dd/MM/yyyy'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _label('Gender'),
                    _genderRadios(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() != true) return;
                          context.read<UserBloc>().add(user_events.UpdateUserProfileRequested(
                                dateOfBirth: _dobCtrl.text.trim(),
                                address: _addressCtrl.text.trim(),
                                name: _nameCtrl.text.trim(),
                                phoneNumber: _phoneCtrl.text.trim(),
                                gender: _gender,
                                avatarFilePath: _avatarPath,
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
              ),
              LoadingOverlay(isLoading: isLoading),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _filledDecoration({String? hint, Widget? prefix}) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.accentOrange.withValues(alpha: 0.4), width: 1.2),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: baseBorder,
      border: baseBorder,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.accentOrange, width: 1.6),
      ),
      prefixIcon: prefix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _filledField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    Widget? prefix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _filledDecoration(hint: hint, prefix: prefix),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
        _dobCtrl.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Widget _genderRadios() {
    return Row(
      children: [
        _genderRadio('Male'),
        const SizedBox(width: 12),
        _genderRadio('Female'),
        const SizedBox(width: 12),
        _genderRadio('Other'),
      ],
    );
  }

  Widget _genderRadio(String value) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _gender = value),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.bellBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: value,
                groupValue: _gender,
                onChanged: (v) => setState(() => _gender = v ?? _gender),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}


