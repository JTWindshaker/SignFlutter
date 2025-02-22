import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sign/core/theme/app_theme.dart';
import 'package:sign/features/requests/presentation/requests_page.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: "/",
          name: "requests",
          builder: (_, _) => const RequestsPage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Sign App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
