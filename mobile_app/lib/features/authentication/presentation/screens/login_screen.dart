import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/constants/validators.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/core/widgets/index.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (user) {
          context.go('/dashboard');
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing24,
              vertical: AppTheme.spacing32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo with gradient
                Center(
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacing20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.shadowMedium,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: AppColors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: AppTheme.spacing32),

                // Header
                Text(
                  'Welcome Back',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: AppTheme.spacing8),
                Text(
                  'Sign in to continue managing your finances',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
                
                SizedBox(height: AppTheme.spacing40),

                // Form Card
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppTheme.shadowCard,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing20),
                        AppEmailField(
                          label: 'Email Address',
                          controller: _emailController,
                          validator: (value) =>
                              AppValidators.validateEmail(value),
                          required: true,
                        ),
                        SizedBox(height: AppTheme.spacing20),
                        AppPasswordField(
                          label: 'Password',
                          controller: _passwordController,
                          validator: (value) => AppValidators.validateNotEmpty(
                              value,
                              fieldName: 'Password'),
                          required: true,
                        ),
                        SizedBox(height: AppTheme.spacing12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/forgot-password');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.darkTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.spacing24),

                // Login Button
                CustomButton(
                  text: 'Sign In',
                  onPressed: isLoading ? null : _handleLogin,
                  isLoading: isLoading,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  leadingIcon: isLoading
                      ? null
                      : Icon(Icons.login, color: AppColors.white, size: 20),
                ),

                SizedBox(height: AppTheme.spacing24),

                // Divider with text
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing16,
                      ),
                      child: Text(
                        'Or continue with',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.border,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing24),

                // Social Login Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Google',
                        variant: ButtonVariant.outline,
                        leadingIcon: Icon(
                          Icons.g_mobiledata,
                          color: AppColors.darkTeal,
                          size: 28,
                        ),
                        onPressed: () {
                          // TODO: Google sign in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google Sign In coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: CustomButton(
                        text: 'Apple',
                        variant: ButtonVariant.outline,
                        leadingIcon: Icon(
                          Icons.apple,
                          color: AppColors.darkTeal,
                          size: 24,
                        ),
                        onPressed: () {
                          // TODO: Apple sign in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Apple Sign In coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing40),

                // Sign Up Link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkTeal,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push('/register');
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.spacing20),

                // Privacy info
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms & Privacy Policy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
