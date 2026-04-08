import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/screens/login_screen.dart';
import 'package:dia_room/screens/main_page_screen.dart';
import 'package:dia_room/screens/new_public_post_screen.dart';
import 'package:dia_room/screens/personal_posts_screen.dart';
import 'package:dia_room/screens/post_preview_screen.dart';
import 'package:dia_room/screens/registration_screen.dart';
import 'package:dia_room/screens/room_screen.dart';
import 'package:dia_room/screens/set_settings_for_post_screen.dart';
import 'package:dia_room/screens/showing_post_screen.dart';
import 'package:dia_room/screens/verify_code_screen.dart';
import 'package:dia_room/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/post_creator/block_post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadSession();

  print('Пользователь аутентифицирован?\nuserId: ${authProvider.userId}\nroomId: ${authProvider.roomId}\n'
      'isAuthenticated: ${authProvider.isAuthenticated}\nisConfigured: ${authProvider.isConfigured} ');

  runApp(
    // Оборачиваем все приложение в провайдер для доступа к состоянию авторизации
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
          final location = state.uri.path;
          final publicRoutes = ['/login', '/registration', '/verifyCode'];

          final bool isPublicPage = publicRoutes.any((route) => location.startsWith(route));

          print('Текущий location: $location, Публичная: $isPublicPage, Авторизован: $loggedIn');

          // if (!loggedIn && !isPublicPage) {
          //   return '/login';
          // }
          //
          // // На экран настройки комнаты
          // if (loggedIn && !authProvider.isConfigured) {
          //   return '/configureRoom';
          // }
          //
          // if (loggedIn && isPublicPage) {
          //   return '/';
          // }

          return null;
        },
        routes: [
          // Главный экран ленты
          GoRoute(
            path: '/',
            builder: (context, state) => const RoomScreen(roomId: 'djkl'),
          ),

          GoRoute(
            name: 'verifyCode',
            path: '/verifyCode/:userId', // :userId — это динамический параметр
            builder: (context, state) {
              // Извлекаем параметр из state.pathParameters
              final userId = state.pathParameters['userId']!;
              final email = state.uri.queryParameters['email'] ?? '';
              return VerifyCode(userId: userId, email: email);
            },
          ),
          GoRoute(path: '/post_preview',
            builder: (context, state) {
              // Извлекаем наш список блоков, который мы передадим при навигации
              final post = state.extra as PostDraft;

              // Возвращаем экран и передаем ему данные
              return PostPreviewScreen(postDraft: post);
            },),

          // Экраны регистрации и входа
          GoRoute(
            name: 'registration',
            path: '/registration',
            builder: (context, state) => const Registration(),
          ),
          GoRoute(name: 'login', path: '/login', builder: (context, state) => const Login()),

          // Экран просмотра конкретного поста
          GoRoute(
            path: "/showPost",
            builder: (context, state) => const ShowingPostScreen(),
          ),
          GoRoute(
            path: '/set_settings',
            builder: (context, state) {
              final post = state.extra as PostDraft;
              return SetSettingsForPostScreen(postDraft: post);
            },
          ),

          // Профиль комнаты
          GoRoute(
            path: '/room',
            builder: (context, state) {
              final roomId = state.extra as String;
              return RoomScreen(roomId: roomId);
            },
          ),

          // Список постов внутри комнаты
          GoRoute(
            path: '/roomPosts',
            builder: (context, state) => const PersonalPostsScreen(),
          ),

          // Новый пост для витрины
          GoRoute(path: '/newPublicPost',
          builder: (context, state) => const NewPublicPostScreen())
        ],
      ),
      debugShowCheckedModeBanner: false,
      // Глобальная настройка темы приложения
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF990000),
          surface: const Color(0xFFE1DFDA),
        ),
      ),
    );
  }
}
