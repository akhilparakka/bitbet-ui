import 'package:bitbet/domain/app_routes.dart';
import 'package:bitbet/domain/services/web3_client.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isGoogleLoading = false;
  bool isEmailLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loginGoogle() async {
    setState(() {
      isGoogleLoading = true;
    });

    final web3Client = Web3BetClient();
    final result = await web3Client.loginWithGoogle();

    setState(() {
      isGoogleLoading = false;
    });

    if (!mounted) return;

    if (result.success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // Show error dialog (same as before)
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(result.error ?? 'Login failed. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _loginWithEmail() async {
    // Validate email
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Color(0xFFFF2882),
        ),
      );
      return;
    }

    setState(() {
      isEmailLoading = true;
    });

    final web3Client = Web3BetClient();
    final result = await web3Client.loginWithEmail(email);

    setState(() {
      isEmailLoading = false;
    });

    if (!mounted) return;

    if (result.success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Error'),
          content: Text(result.error ?? 'Login failed. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 28),

                    // Title and description
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Continue with Google button
                    _buildGoogleButton(),

                    const SizedBox(height: 12),

                    // Continue with Apple/Placeholder button
                    _buildPlaceholderButton(),

                    const SizedBox(height: 32),

                    // Divider
                    _buildDivider(),

                    const SizedBox(height: 24),

                    // Full Name input
                    _buildInputField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                    ),

                    const SizedBox(height: 16),

                    // Email input
                    _buildInputField(
                      label: 'Email',
                      hint: 'Enter your email address',
                      controller: _emailController,
                    ),

                    const SizedBox(height: 24),

                    // Continue with Email button
                    _buildEmailButton(),

                    const SizedBox(height: 16),

                    // Already have account link
                    _buildLoginLink(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed footer - Terms and conditions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildTermsText(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'Create account',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.12,
            height: 32 / 24,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We happy to see you again. Sign Up to your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8E8E93),
            letterSpacing: 0.08,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: isGoogleLoading ? null : _loginGoogle,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF38384C)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogleLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Image.asset(
                'assets/icons/google_icon.png',
                width: 24,
                height: 24,
              ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.07,
                height: 22 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF38384C)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apple,
            size: 24,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Apple',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.07,
              height: 22 / 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 1,
          color: const Color(0xFF38384C),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Or continue with',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.07,
              height: 22 / 14,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 1,
          color: const Color(0xFF38384C),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.06,
            height: 16 / 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF38384C)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.07,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.07,
                height: 22 / 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailButton() {
    return GestureDetector(
      onTap: isEmailLoading ? null : _loginWithEmail,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF2882),
          borderRadius: BorderRadius.circular(20),
        ),
        child: isEmailLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : const Text(
                'Continue with Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.07,
                  height: 22 / 14,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: () {
        debugPrint('Login tapped');
        // TODO: Navigate to login
      },
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.07,
            height: 22 / 14,
          ),
          children: [
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: Color(0xFF8E8E93)),
            ),
            TextSpan(
              text: 'Login',
              style: TextStyle(color: Color(0xFFFF2882)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.07,
          height: 22 / 14,
        ),
        children: [
          TextSpan(
            text: 'By signing up you agree to our ',
            style: TextStyle(color: Color(0xFF8E8E93)),
          ),
          TextSpan(
            text: 'Terms',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: ' and ',
            style: TextStyle(color: Color(0xFF8E8E93)),
          ),
          TextSpan(
            text: 'Conditions of Use',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
