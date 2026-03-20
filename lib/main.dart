import 'package:dia_room/models/post_creator/post_creating.dart';
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
  // Гарантируем инициализацию связей с нативной платформой перед асинхронными вызовами
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // // Создаем экземпляр провайдера и предварительно загружаем данные пользователя из хранилища
  // final authProvider = AuthProvider();
  // await authProvider.loadUser();

  runApp(
    // Оборачиваем все приложение в провайдер для доступа к состоянию авторизации
    // ChangeNotifierProvider.value(
    //   value: authProvider,
    //   child: App(authProvider: authProvider),
    // ),]
    App()
  );
}

class App extends StatelessWidget {
  // final AuthProvider authProvider;

  // const App({super.key, required this.authProvider});
  const App();


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Настройка навигации через GoRouter
      routerConfig: GoRouter(
        // Перенаправляем пользователя автоматически при изменении состояния в AuthProvider
        // refreshListenable: authProvider,
        initialLocation: '/',
        // redirect: (context, state) {
        //   final bool loggedIn = authProvider.isAuthenticated;
        //   // Список путей, доступных без авторизации
        //   final publicRoutes = ['/login', '/registration', '/verifyCode'];
        //   final bool isPublicPage = publicRoutes.contains(
        //     state.matchedLocation,
        //   );
        //
        //   // Если пользователь не в системе и пытается зайти на закрытый экран — на логин
        //   if (!loggedIn && !isPublicPage) {
        //     return '/login';
        //   }
        //
        //   // Если пользователь уже авторизован, не пускаем его на страницы входа/регистрации
        //   if (loggedIn && isPublicPage) {
        //     return '/';
        //   }
        //
        //   // В остальных случаях оставляем пользователя там, куда он шел
        //   return null;
        // },
        routes: [
          // Главный экран ленты
          GoRoute(
            path: '/',
            builder: (context, state) => const NewPublicPostScreen(),
          ),

          // Экран верификации с передачей userId через аргумент extra
          GoRoute(
            path: '/verifyCode',
            builder: (context, state) {
              final id = state.extra as String;
              return VerifyCode(userId: id);
            },
          ),
          GoRoute(path: '/post_preview',
            builder: (context, state) {
              // Извлекаем наш список блоков, который мы передадим при навигации
              final post = state.extra as PostCreateRequest;

              // Возвращаем экран и передаем ему данные
              return PostPreviewScreen(post: post);
            },),

          // Экраны регистрации и входа
          GoRoute(
            path: '/registration',
            builder: (context, state) => const Registration(),
          ),
          GoRoute(path: '/login', builder: (context, state) => const Login()),

          // Экран просмотра конкретного поста
          GoRoute(
            path: "/showPost",
            builder: (context, state) => const ShowingPostScreen(),
          ),
          GoRoute(
            path: '/set_settings',
            builder: (context, state) {
              final post = state.extra as PostCreateRequest;
              return SetSettingsForPostScreen(post: post);
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
