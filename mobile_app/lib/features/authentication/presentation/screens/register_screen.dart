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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to terms and conditions'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (user) {
          // Check if profile is complete
          if (user.profileComplete) {
            context.go('/dashboard');
          } else {
            context.go('/onboarding/welcome');
          }
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
              vertical: AppTheme.spacing20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.darkGrey,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),

                SizedBox(height: AppTheme.spacing24),

                // Logo with gradient
                Center(
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.shadowMedium,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 40,
                      color: AppColors.white,
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.spacing24),

                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Create Account',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Join FinAI to start managing your finances',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.spacing32),

                // Form Card
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing20),
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
                          'Personal Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing16),
                        
                        // Name fields
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'First Name',
                                controller: _firstNameController,
                                validator: (value) =>
                                    AppValidators.validateNotEmpty(value,
                                        fieldName: 'First name'),
                                required: true,
                              ),
                            ),
                            SizedBox(width: AppTheme.spacing12),
                            Expanded(
                              child: AppTextField(
                                label: 'Last Name',
                                controller: _lastNameController,
                                validator: (value) =>
                                    AppValidators.validateNotEmpty(value,
                                        fieldName: 'Last name'),
                                required: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacing16),

                        // Email
                        AppEmailField(
                          label: 'Email Address',
                          controller: _emailController,
                          validator: (value) =>
                              AppValidators.validateEmail(value),
                          required: true,
                        ),
                        SizedBox(height: AppTheme.spacing16),

                        // Password
                        AppPasswordField(
                          label: 'Password',
                          hint: 'Minimum 8 characters',
                          controller: _passwordController,
                          validator: (value) =>
                              AppValidators.validatePassword(value),
                          required: true,
                        ),
                        SizedBox(height: AppTheme.spacing16),

                        // Confirm Password
                        AppPasswordField(
                          label: 'Confirm Password',
                          controller: _confirmPasswordController,
                          validator: (value) =>
                              AppValidators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          required: true,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.spacing20),

                // Terms checkbox in a card
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _agreeToTerms
                          ? AppColors.success
                          : AppColors.border,
                      width: _agreeToTerms ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                        activeColor: AppColors.darkTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: AppTheme.spacing12,
                            left: AppTheme.spacing8,
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'I agree to the ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.darkGrey,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppColors.darkTeal,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: Show terms
                                    },
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppColors.darkTeal,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: Show privacy policy
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.spacing24),

                // Register Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: isLoading ? null : _handleRegister,
                  isLoading: isLoading,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  leadingIcon: isLoading
                      ? null
                      : Icon(
                          Icons.person_add,
                          color: AppColors.white,
                          size: 20,
                        ),
                ),

                SizedBox(height: AppTheme.spacing24),

                // Divider
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
                        'Or sign up with',
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

                // Social buttons
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google Sign Up coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing12),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Apple Sign Up coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing32),

                // Sign In Link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGrey,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkTeal,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.pop();
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.spacing20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
