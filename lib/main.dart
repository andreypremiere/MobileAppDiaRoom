import 'package:dia_room/screens/login_screen.dart';
import 'package:dia_room/screens/main_page_screen.dart';
import 'package:dia_room/screens/personal_posts_screen.dart';
import 'package:dia_room/screens/registration_screen.dart';
import 'package:dia_room/screens/room_screen.dart';
import 'package:dia_room/screens/showing_post_screen.dart';
import 'package:dia_room/screens/verify_code_screen.dart';
import 'package:dia_room/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadUser();

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: App(authProvider: authProvider),
    ),
  );
}

class App extends StatelessWidget {
  final AuthProvider authProvider;
  const App({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        refreshListenable: authProvider,
        initialLocation: '/',
        redirect: (context, state) {
          final bool loggedIn = authProvider.isAuthenticated;

          final publicRoutes = ['/login', '/registration', '/verifyCode'];

          final bool isPublicPage = publicRoutes.contains(state.matchedLocation);

          if (!loggedIn && !isPublicPage) {
            return '/login';
          }

          if (loggedIn && isPublicPage) {
            return '/';
          }

          return null;
        },
        routes: [
          // Главный экран (рекомендуемые посты)
          GoRoute(path: '/',
              builder: (context, state) => const MainPageScreen()),
          // Экран ввода кода
          GoRoute(
            path: '/verifyCode',
            builder: (context, state) {
              final id = state.extra as String;

              return VerifyCode(userId: id);
            },
          ),
          // Экран регистрации
          GoRoute(
            path: '/registration',
            builder: (context, state) => const Registration(),
          ),
          // Экран ввода телефона или room_name_id
          GoRoute(
            path: '/login',
            builder: (context, state) => const Login(),
          ),
          // Страница поста
          GoRoute(path: "/showPost",
              builder: (context, state) => const ShowingPostScreen()),
          // Страница комнаты
          GoRoute(
            path: '/room',
            builder: (context, state) => const RoomScreen(),
          ),
          // Страница постов комнаты
          GoRoute(
            path: '/roomPosts',
            builder: (context, state) => const PersonalPostsScreen(),
          ),
        ],
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF990000),
          surface: const Color(0xFFE1DFDA),
        ),
      ),
      // home: VerifyCode()
    );
  }
}

