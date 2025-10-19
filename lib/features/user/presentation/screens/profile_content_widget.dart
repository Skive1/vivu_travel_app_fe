import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/profile_container.dart';

class ProfileContentWidget extends StatefulWidget {
  const ProfileContentWidget({super.key});

  @override
  State<ProfileContentWidget> createState() => _ProfileContentWidgetState();
}

class _ProfileContentWidgetState extends State<ProfileContentWidget> {
  @override
  void initState() {
    super.initState();
    // Refresh user profile when entering profile screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(GetUserProfileRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => curr is AuthError,
      listener: (context, state) {
        if (state is AuthError) {
          DialogUtils.showErrorDialog(context: context, title: state.title ?? 'Error', message: state.message);
        }
      },
      child: const ProfileContainer(),
    );
  }
}
