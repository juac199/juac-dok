import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}

class AppThemeScope extends InheritedNotifier<ThemeController> {
  const AppThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();

    assert(scope != null, 'AppThemeScope is missing above this widget.');

    return scope!.notifier!;
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppThemeScope.of(context);

    return IconButton(
      tooltip: controller.isDark
          ? 'Switch to Light Theme'
          : 'Switch to Black Theme',
      onPressed: controller.toggle,
      icon: Icon(
        controller.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      ),
    );
  }
}
