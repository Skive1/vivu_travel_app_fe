import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'social_auth_button.dart';

class SocialAuthSection extends StatefulWidget {
  final Function(String)? onSocialLogin;

  const SocialAuthSection({super.key, this.onSocialLogin});

  @override
  State<SocialAuthSection> createState() => _SocialAuthSectionState();
}

class _SocialAuthSectionState extends State<SocialAuthSection> {
  String? _loadingProvider;

  Future<void> _handleSocialLogin(String provider) async {
    if (_loadingProvider != null) return;

    setState(() {
      _loadingProvider = provider;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (widget.onSocialLogin != null) {
        widget.onSocialLogin!(provider);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logging in with $provider...'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to login with $provider'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingProvider = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SocialAuthButton(
          icon: SvgPicture.string(
            '''<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="100" height="100" viewBox="0 0 48 48">
<path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"></path><path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z"></path><path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"></path><path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"></path>
</svg>''',
            fit: BoxFit.contain,
          ),
          onPressed: () => _handleSocialLogin('Google'),
          tooltip: 'Continue with Google',
          isLoading: _loadingProvider == 'Google',
        ),
        SocialAuthButton(
          icon: SvgPicture.string(
            '''<svg width="44" height="44" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M44 22C44 9.84973 34.1503 0 22 0C9.84973 0 0 9.84973 0 22C0 32.9808 8.04507 42.0823 18.5625 43.7328V28.3594H12.9766V22H18.5625V17.1531C18.5625 11.6394 21.8469 8.59376 26.8722 8.59376C29.2792 8.59376 31.7969 9.02344 31.7969 9.02344V14.4375H29.0227C26.2898 14.4375 25.4375 16.1334 25.4375 17.8732V22H31.5391L30.5637 28.3594H25.4375V43.7328C35.9549 42.0823 44 32.9808 44 22Z" fill="#1877F2"/>
<path d="M30.5637 28.3594L31.5391 22H25.4375V17.8731C25.4375 16.1334 26.2898 14.4375 29.0227 14.4375H31.7969V9.02343C31.7969 9.02343 29.2792 8.59375 26.8722 8.59375C21.8469 8.59375 18.5625 11.6394 18.5625 17.1531V22H12.9766V28.3594H18.5625V43.7327C19.6997 43.9109 20.849 44.0003 22 44C23.1694 44 24.3174 43.9085 25.4375 43.7327V28.3594H30.5637Z" fill="white"/>
</svg>

''',
            fit: BoxFit.contain,
          ),
          onPressed: () => _handleSocialLogin('Facebook'),
          tooltip: 'Continue with Facebook',
          isLoading: _loadingProvider == 'Facebook',
        ),
        SocialAuthButton(
          icon: SvgPicture.string(
            '''<svg width="44" height="44" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle opacity="0.7" cx="22" cy="22" r="22" fill="url(#paint0_linear_2002_342)"/>
<path d="M28.5379 16.6624C28.5379 15.9977 27.9991 15.461 27.3369 15.461C26.6747 15.461 26.1355 15.9977 26.1355 16.6624C26.1355 17.3247 26.6747 17.8614 27.3369 17.8614C27.9991 17.8614 28.5379 17.3247 28.5379 16.6624Z" fill="white"/>
<path d="M30.1386 26.0404C30.0941 27.0155 29.931 27.5453 29.7956 27.8971C29.6137 28.3637 29.3968 28.6972 29.0449 29.0471C28.697 29.397 28.3634 29.6135 27.8968 29.7934C27.545 29.9308 27.0132 30.0944 26.0382 30.1408C24.984 30.1873 24.6717 30.1972 21.9985 30.1972C19.3278 30.1972 19.013 30.1873 17.9589 30.1408C16.9838 30.0944 16.4545 29.9308 16.1026 29.7934C15.6336 29.6135 15.3025 29.397 14.9526 29.0471C14.6003 28.6972 14.3833 28.3637 14.2039 27.8971C14.0685 27.5453 13.903 27.0155 13.8609 26.0404C13.8095 24.9863 13.8001 24.669 13.8001 22.0013C13.8001 19.3281 13.8095 19.0133 13.8609 17.9591C13.903 16.9841 14.0685 16.4548 14.2039 16.0999C14.3833 15.6339 14.6003 15.3023 14.9526 14.9524C15.3025 14.603 15.6336 14.386 16.1026 14.2042C16.4545 14.0663 16.9838 13.9052 17.9589 13.8587C19.013 13.8123 19.3278 13.8004 21.9985 13.8004C24.6717 13.8004 24.984 13.8123 26.0382 13.8587C27.0132 13.9052 27.545 14.0663 27.8968 14.2042C28.3634 14.386 28.697 14.603 29.0449 14.9524C29.3968 15.3023 29.6137 15.6339 29.7956 16.0999C29.931 16.4548 30.0941 16.9841 30.1386 17.9591C30.1875 19.0133 30.1993 19.3281 30.1993 22.0013C30.1993 24.669 30.1875 24.9863 30.1386 26.0404ZM31.939 17.8771C31.89 16.8116 31.722 16.0836 31.4724 15.4496C31.2184 14.7918 30.8779 14.2343 30.3204 13.6769C29.7655 13.1219 29.208 12.7814 28.5502 12.5244C27.9137 12.2773 27.1881 12.1073 26.1221 12.0608C25.0561 12.0094 24.7157 12 21.9985 12C19.2838 12 18.9409 12.0094 17.8749 12.0608C16.8113 12.1073 16.0863 12.2773 15.4468 12.5244C14.7915 12.7814 14.2341 13.1219 13.6791 13.6769C13.1216 14.2343 12.7811 14.7918 12.5246 15.4496C12.2775 16.0836 12.1095 16.8116 12.0581 17.8771C12.0116 18.9431 11.9998 19.2841 11.9998 22.0013C11.9998 24.7159 12.0116 25.0564 12.0581 26.1224C12.1095 27.186 12.2775 27.9134 12.5246 28.5505C12.7811 29.2058 13.1216 29.7657 13.6791 30.3207C14.2341 30.8757 14.7915 31.2187 15.4468 31.4752C16.0863 31.7223 16.8113 31.8903 17.8749 31.9392C18.9409 31.9882 19.2838 32 21.9985 32C24.7157 32 25.0561 31.9882 26.1221 31.9392C27.1881 31.8903 27.9137 31.7223 28.5502 31.4752C29.208 31.2187 29.7655 30.8757 30.3204 30.3207C30.8779 29.7657 31.2184 29.2058 31.4724 28.5505C31.722 27.9134 31.89 27.186 31.939 26.1224C31.9879 25.0564 31.9998 24.7159 31.9998 22.0013C31.9998 19.2841 31.9879 18.9431 31.939 17.8771Z" fill="white"/>
<path d="M21.9983 25.3317C20.1584 25.3317 18.6654 23.8411 18.6654 22.0012C18.6654 20.1583 20.1584 18.6659 21.9983 18.6659C23.8387 18.6659 25.3337 20.1583 25.3337 22.0012C25.3337 23.8411 23.8387 25.3317 21.9983 25.3317ZM21.9983 16.863C19.162 16.863 16.865 19.165 16.865 22.0012C16.865 24.835 19.162 27.1346 21.9983 27.1346C24.8345 27.1346 27.1341 24.835 27.1341 22.0012C27.1341 19.165 24.8345 16.863 21.9983 16.863Z" fill="white"/>
<defs>
<linearGradient id="paint0_linear_2002_342" x1="0.396874" y1="0.400136" x2="40.368" y2="40.3713" gradientUnits="userSpaceOnUse">
<stop stop-color="#FFD521"/>
<stop offset="0.05" stop-color="#FFD521"/>
<stop offset="0.501119" stop-color="#F50000"/>
<stop offset="0.95" stop-color="#B900B4"/>
<stop offset="0.950079" stop-color="#B900B4"/>
<stop offset="1" stop-color="#B900B4"/>
</linearGradient>
</defs>
</svg>
''',
            fit: BoxFit.contain,
          ),
          onPressed: () => _handleSocialLogin('Instagram'),
          tooltip: 'Continue with Instagram',
          isLoading: _loadingProvider == 'Instagram',
        ),
      ],
    );
  }
}
