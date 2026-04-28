import 'package:dia_room/models/enums/file_type.dart';
import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/screens/followers_screen.dart';
import 'package:dia_room/screens/full_image_screen.dart';
import 'package:dia_room/screens/full_video_screen.dart';
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
import 'package:dia_room/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final authProvider = AuthProvider();
  ApiService.init(authProvider);
  await authProvider.loadSession();

  print('Пользователь аутентифицирован?\nuserId: ${authProvider.userId}\nroomId: ${authProvider.roomId}\n'
      'isAuthenticated: ${authProvider.isAuthenticated}\nisConfigured: ${authProvider.isConfigured} ');

  print(authProvider.accessToken);

  runApp(
    MultiProvider(
      providers: [
        // Передаем уже созданный экземпляр, чтобы сохранить состояние сессии
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => DraftProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
            systemStatusBarContrastEnforced: false,
          ),
          child: child!,
        );
      },
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
            path: '/verifyCode/:userId',
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
            path: "/showPost/:postId",
            builder: (context, state) {
              final postId = state.pathParameters['postId']!;
              return ShowingPostScreen(postId: postId);
            },
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
            path: '/room/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return RoomScreen(roomId: roomId);
            },
          ),
          GoRoute(
            path: '/followers/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return FollowersScreen(roomId: roomId);
            },
          ),
          // Список постов внутри комнаты
          GoRoute(
            path: '/personalRoomPosts/:roomId',
            builder: (context, state) {
              final String roomId = state.pathParameters['roomId']!;

              return PersonalPostsScreen(roomId: roomId);
            },
          ),

          // Новый пост для витрины
          GoRoute(path: '/newPublicPost',
          builder: (context, state) => const NewPublicPostScreen()),

          GoRoute(
            path: '/full_image_screen',
            builder: (context, state) {
              // Достаем параметры из extra
              final Map<String, dynamic> params = state.extra as Map<String, dynamic>;
              final List<String> paths = params['urls'] as List<String>;
              final int initIdx = params['index'] as int;
              final FileType fileType = params['type'];

              return FullImageScreen(
                imageUrls: paths,
                initialIndex: initIdx,
                type: fileType,
              );
            },
          ),
          GoRoute(
            path: '/full_screen_video',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;

              final String videoUrl = extra['url'] as String;
              final FileType type = extra['type'] as FileType;

              return FullScreenVideoScreen(videoUrl: videoUrl, type: type,);
            },
          ),
        ],
      ),
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
    );
  }
}
