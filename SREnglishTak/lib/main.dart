import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/home_library.dart';
import 'screens/login_screen.dart';
import 'screens/test_series_screen.dart';
import 'screens/arena_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_shell.dart';
import 'screens/onboarding_screen.dart';
import 'widgets/custom_bottom_nav.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_data_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/xp_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => XpProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProxyProvider<UserDataProvider, AuthProvider>(
          create: (context) => AuthProvider(context.read<UserDataProvider>()),
          update: (context, userDataProvider, authProvider) =>
              authProvider ?? AuthProvider(userDataProvider),
        ),
      ],
      child: const SREnglishTakApp(),
    ),
  );
}

class SREnglishTakApp extends StatelessWidget {
  const SREnglishTakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SR English Tak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeProvider>().themeMode,
      // Initial route logic: If logged in, show AdminShell for admins, Onboarding for first-time students, or MainLayout
      initialRoute: AuthService.isLoggedIn
          ? (AuthService.isAdmin
              ? '/admin'
              : (AuthService.hasCompletedOnboarding ? '/' : '/onboarding'))
          : '/login',
      routes: {
        '/': (context) => const MainLayout(),
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminShell(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    HomeScreen(
      onLibraryTap: () => _onTabTapped(2),
      onTestSeriesTap: () => _onTabTapped(1),
      onProfileTap: () => _onTabTapped(4),
    ),
    TestSeriesScreen(onProfileTap: () => _onTabTapped(4)),
    HomeLibrary(onProfileTap: () => _onTabTapped(4)),
    ArenaScreen(onProfileTap: () => _onTabTapped(4)),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens;
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
