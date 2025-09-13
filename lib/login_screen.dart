import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/home3.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Header Section
                _buildHeader(),

                const SizedBox(height: 40),

                // Login Form
                _buildLoginForm(),

                const SizedBox(height: 30),

                // Support Link
                _buildSupportLink(),
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
        // Moon icon in top right corner would be positioned differently in real app
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

        const SizedBox(height: 40),

        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 40),
        ),

        const SizedBox(height: 24),

        // Title and Subtitle
        const Text(
          'Welcome to SCHOOL MANAGENGENT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Login to manage academics, finance, and school activities',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: MediaQuery.sizeOf(context).width * .4,
      padding: const EdgeInsets.all(32),
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
            // Role Selection
            const Text(
              'Select Your Role',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            _buildRoleSelection(),

            const SizedBox(height: 24),

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

  Widget _buildRoleSelection() {
    return Row(
      children: [
        _buildRoleCard('Admin', Icons.admin_panel_settings),
        const SizedBox(width: 12),
        _buildRoleCard('Teacher', Icons.co_present),
        const SizedBox(width: 12),
        _buildRoleCard('Accountant', Icons.calculate),
      ],
    );
  }

  Widget _buildRoleCard(String role, IconData icon) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF6366F1).withOpacity(0.2)
                    : const Color(0xFF374151),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF4B5563),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF9CA3AF),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                role,
                style: TextStyle(
                  color:
                      isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
    return Row(
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
            // Handle forgot password
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
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
            onPressed: () async{
              if (_formKey.currentState!.validate()) {
                // Handle login
               Map<String, String> body = {
              'email': _emailController.text,
            
              'password': _passwordController.text
            };
                  ref.read(RiverpodProvider.authProvider).login(context, 
                  ref.read(RiverpodProvider.profileProvider),body: body);
                
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
    return Row(
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
    );
  }

  void _handleLogin()async {



    
                                    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => SchoolAdminDashboard3()),
    // );
    // Implement login logic here
    
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
