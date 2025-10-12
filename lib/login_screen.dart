import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/providers/auth_state_provider.dart';
import 'package:schmgtsystem/screens/auth/forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum userRole { Admin, Parent, Teacher }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Admin';
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Load saved credentials from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final savedRole = prefs.getString('saved_role');

      if (rememberMe && savedEmail != null && savedPassword != null) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
          _rememberMe = rememberMe;
          _selectedRole = savedRole ?? 'Admin';
        });

        // Set the authentication state in the provider if credentials are loaded
        if (savedRole != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(authStateProvider.notifier)
                .setAuthenticated(
                  userRole: savedRole.toLowerCase(),
                  token: '', // Token will be set during actual login
                );
          });
        }
      }
    } catch (e) {
      // Handle error silently
      print('Error loading saved credentials: $e');
    }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text);
        await prefs.setString('saved_password', _passwordController.text);
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_role', _selectedRole);
      } else {
        // Clear saved credentials if remember me is unchecked
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
        await prefs.remove('saved_role');
      }
    } catch (e) {
      // Handle error silently
      print('Error saving credentials: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height > 600 ? 20 : 10,
                ),

                // Header Section
                _buildHeader(),

                SizedBox(
                  height: MediaQuery.of(context).size.height > 600 ? 40 : 24,
                ),

                // Login Form
                Center(child: _buildLoginForm()),

                SizedBox(
                  height: MediaQuery.of(context).size.height > 600 ? 30 : 20,
                ),

                // Support Link
                _buildSupportLink(),

                SizedBox(
                  height: MediaQuery.of(context).size.height > 600 ? 20 : 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Moon icon in top right corner
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tertiary2.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.nightlight_round,
                color: AppColors.tertiary2,
                size: 20,
              ),
            ),
          ],
        ),

        SizedBox(height: MediaQuery.of(context).size.height > 600 ? 40 : 20),

        // Logo
        Container(
          width: MediaQuery.of(context).size.width > 600 ? 80 : 60,
          height: MediaQuery.of(context).size.width > 600 ? 80 : 60,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width > 600 ? 40 : 30,
            ),
          ),
          child: Icon(
            Icons.school,
            color: Colors.white,
            size: MediaQuery.of(context).size.width > 600 ? 40 : 30,
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height > 600 ? 24 : 16),

        // Title and Subtitle
        Text(
          'Welcome to LOVESPRING',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Login to manage academics, finance, and school activities',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF9CA3AF),
            fontSize: MediaQuery.of(context).size.width > 600 ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width:
          MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width > 600 ? 32 : 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF374151), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Field
            const Text(
              'Email / Username',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            _buildEmailField(),

            const SizedBox(height: 20),

            // Password Field
            const Text(
              'Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            _buildPasswordField(),

            const SizedBox(height: 20),

            // Remember Me and Forgot Password
            _buildRememberMeSection(),

            const SizedBox(height: 32),

            // Login Button
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter your email or username',
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.person_outline, color: Color(0xFF6B7280)),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email or username';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6B7280),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeSection() {
    return MediaQuery.of(context).size.width > 400
        ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF6366F1),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF6B7280)),
                ),
                const Text(
                  'Remember me',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
              ),
            ),
          ],
        )
        : Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF6366F1),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF6B7280)),
                ),
                const Text(
                  'Remember me',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
                ),
              ),
            ),
          ],
        );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Handle login
            Map<String, String> body = {
              'email': _emailController.text,

              'password': _passwordController.text,
            };

            // Save credentials if remember me is checked
            await _saveCredentials();

            // Role will be set by the authentication provider after successful login

            ref
                .read(RiverpodProvider.authProvider)
                .login(
                  context,
                  ref.read(RiverpodProvider.profileProvider),
                  body: body,
                );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'Login',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSupportLink() {
    return MediaQuery.of(context).size.width > 300
        ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Need help? ',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
            TextButton(
              onPressed: () {
                // Handle contact support
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
              ),
            ),
          ],
        )
        : Column(
          children: [
            const Text(
              'Need help?',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                // Handle contact support
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
              ),
            ),
          ],
        );
  }

  // You would typically call an authentication service here
}

// Example usage in main.dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
