import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/screens/login_screen.dart';
import 'package:dia_room/screens/main_page_screen.dart';
import 'package:dia_room/screens/new_public_post_screen.dart';
import 'package:dia_room/screens/personal_posts_screen.dart';
import 'package:dia_room/screens/post_preview_screen.dart';
import 'package:dia_room/screens/registration_screen.dart';
import 'package:dia_room/screens/room_screen.dart';
import 'package:dia_room/screens/room_settings_screen.dart';
import 'package:dia_room/screens/set_settings_for_post_screen.dart';
import 'package:dia_room/screens/showing_post_screen.dart';
import 'package:dia_room/screens/verify_code_screen.dart';
import 'package:dia_room/utils/auth_service.dart';
import 'package:dia_room/utils/dio_service.dart';
import 'package:dia_room/utils/draft_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/post_creator/block_post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  ApiService.init(authProvider);
  await authProvider.loadSession();

  print('Пользователь аутентифицирован?\nuserId: ${authProvider.userId}\nroomId: ${authProvider.roomId}\n'
      'isAuthenticated: ${authProvider.isAuthenticated}\nisConfigured: ${authProvider.isConfigured} ');

  runApp(
    MultiProvider(
      providers: [
        // Передаем уже созданный экземпляр, чтобы сохранить состояние сессии
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => DraftProvider()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return MaterialApp.router(
      routerConfig: GoRouter(
        refreshListenable: auth,
        initialLocation: '/',
        redirect: (context, state) {
          final bool loggedIn = auth.isAuthenticated;
          final location = state.uri.path;
          final publicRoutes = ['/login', '/registration', '/verifyCode'];

          final bool isPublicPage = publicRoutes.any((route) => location.startsWith(route));

          print('Текущий location: $location, Публичная: $isPublicPage, Авторизован: $loggedIn');

          if (!loggedIn && !isPublicPage) {
            return '/login';
          }

          if (loggedIn && !auth.isConfigured) {
            return '/configureRoom';
          }

          if (loggedIn && isPublicPage) {
            return '/';
          }

          return null;
        },
        routes: [
          // Главный экран ленты
          GoRoute(
            path: '/',
            builder: (context, state) => MainPageScreen(),
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
              PostDraft? draft = context.read<DraftProvider>().currentDraft;
              // Если вдруг зашли сюда напрямую без черновика — редирект на начало
              if (draft == null) return NewPublicPostScreen();
              return PostPreviewScreen(postDraft: draft);
            },),
          GoRoute(path: '/configureRoom',
            builder: (context, state) {
              return RoomSettingsScreen();
            }),

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
              PostDraft? draft = context.read<DraftProvider>().currentDraft;
              if (draft == null) return MainPageScreen();
              return SetSettingsForPostScreen(postDraft: draft);
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
