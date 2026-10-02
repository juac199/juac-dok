import 'package:flutter/material.dart';

import 'screens/admin_dashboard_page.dart';
import 'screens/lecturer_dashboard_page.dart';
import 'screens/student_dashboard_page.dart';
import 'services/api_service.dart';
import 'widgets/option3_design.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(const StudentManagementApp());
}

class StudentManagementApp extends StatefulWidget {
  const StudentManagementApp({super.key});

  @override
  State<StudentManagementApp> createState() => _StudentManagementAppState();
}

class _StudentManagementAppState extends State<StudentManagementApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.addListener(_themeChanged);
  }

  void _themeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _themeController.removeListener(_themeChanged);
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Management System',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeController.mode,
        home: LoginPage(themeController: _themeController),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final ThemeController themeController;

  const LoginPage({super.key, required this.themeController});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.login(email, password);

      if (!mounted) return;

      if (result['role'] == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardPage(user: result),
          ),
        );
        return;
      }

      if (result['role'] == 'lecturer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LecturerDashboardPage(user: result),
          ),
        );
        return;
      }

      if (result['role'] == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDashboardPage(user: result),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unknown user role: ${result['role']}')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: widget.themeController.isDark
                ? 'Switch to Light Theme'
                : 'Switch to Black Theme',
            onPressed: AppThemeScope.of(context).toggle,
            icon: Icon(
              widget.themeController.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Option3.pageBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 22 : 32,
                vertical: 28,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: isCompact
                    ? _buildCompactLayout()
                    : _buildDesktopLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 55),
            child: _buildBranding(),
          ),
        ),
        SizedBox(width: 410, child: _buildLoginCard()),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      children: [
        _buildBranding(compact: true),
        const SizedBox(height: 28),
        _buildLoginCard(),
      ],
    );
  }

  Widget _buildBranding({bool compact = false}) {
    return Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            gradient: Option3.headerGradientFor(context),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x220E3559),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'STUDENT MANAGEMENT',
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: compact ? 27 : 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: Option3.textColor(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'SYSTEM',
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: compact ? 27 : 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: Option3.blueColor(context),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: compact ? 330 : 440,
          child: Text(
            'Your central university portal for academic information, student services, and campus support.',
            textAlign: compact ? TextAlign.center : TextAlign.left,
            style: Option3.body(size: 15)
                .copyWith(color: Option3.mutedColor(context)),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: compact ? WrapAlignment.center : WrapAlignment.start,
          spacing: 9,
          runSpacing: 9,
          children: [
            _buildBrandChip(Icons.verified_user_outlined, 'Secure Portal'),
            _buildBrandChip(Icons.school_outlined, 'University Services'),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Option3.borderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Option3.blueColor(context)),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Option3.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: Option3.themedCard(context, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Option3.blueLightColor(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.login_rounded,
                color: Option3.blueColor(context),
                size: 27,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Welcome back',
              style: Option3.title(size: 25)
                  .copyWith(color: Option3.textColor(context)),
            ),
          ),
          const SizedBox(height: 7),
          Center(
            child: Text(
              'Sign in to access your university account',
              textAlign: TextAlign.center,
              style: Option3.body(size: 13)
                  .copyWith(color: Option3.mutedColor(context)),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Email address',
            style: Option3.label().copyWith(color: Option3.textColor(context)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'Enter your university email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 19),
          Text(
            'Password',
            style: Option3.label().copyWith(color: Option3.textColor(context)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onSubmitted: (_) {
              if (!_isLoading) {
                _login();
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: _isLoading ? null : _login,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Theme.of(context).colorScheme.primary
                    .withValues(alpha: .55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 9),
                        Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 21),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: Option3.mutedColor(context),
                ),
                const SizedBox(width: 6),
                Text(
                  'Protected university access',
                  style: Option3.body(size: 11.5)
                      .copyWith(color: Option3.mutedColor(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
