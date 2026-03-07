import 'package:dia_room/screens/login_screen.dart';
import 'package:dia_room/screens/main_page_screen.dart';
import 'package:dia_room/screens/personal_posts_screen.dart';
import 'package:dia_room/screens/registration_screen.dart';
import 'package:dia_room/screens/room_screen.dart';
import 'package:dia_room/screens/showing_post_screen.dart';
import 'package:dia_room/screens/verify_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
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

// Настройка маршрутов
final _router = GoRouter(
  initialLocation: '/',
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

    // Пример маршрута с параметром
    // GoRoute(
    //   path: '/welcome/:name',
    //   builder: (context, state) {
    //     final name = state.pathParameters['name']!; // Достаем данные из URL
    //     return WelcomeScreen(userName: name);
    //   },
    // ),
  ],
);
