import 'package:dia_room/models/enums/file_type.dart';
import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/screens/authorization/registration_screen.dart';
import 'package:dia_room/screens/diary/diary_screen.dart';
import 'package:dia_room/screens/diary/select_folder_diary.dart';
import 'package:dia_room/screens/room/room_settings_screen.dart';
import 'package:dia_room/screens/publication/full_image_screen.dart';
import 'package:dia_room/screens/publication/full_video_screen.dart';
import 'package:dia_room/screens/authorization/login_screen.dart';
import 'package:dia_room/screens/main_page_screen.dart';
import 'package:dia_room/screens/publication/new_public_post_screen.dart';
import 'package:dia_room/screens/publication/personal_posts_screen.dart';
import 'package:dia_room/screens/publication/post_preview_screen.dart';
import 'package:dia_room/screens/room/room_screen.dart';
import 'package:dia_room/screens/publication/set_settings_for_post_screen.dart';
import 'package:dia_room/screens/publication/showing_post_screen.dart';
import 'package:dia_room/screens/authorization/verify_code_screen.dart';
import 'package:dia_room/screens/workshop/select_folder_screen.dart';
import 'package:dia_room/screens/workshop/workshop_screen.dart';
import 'package:dia_room/services/diary/upload_manager.dart';
import 'package:dia_room/services/workshop/uploader_manager.dart';
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
        ChangeNotifierProvider(create: (_) => UploaderManager()),
        ChangeNotifierProvider(create: (_) => UploadManager()),
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
            builder: (context, state) => DiaryScreen(roomId: "64a13030-7175-463f-9f7e-5a7b80382017"),
          ),

          GoRoute(
            path: '/diary/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return DiaryScreen(roomId: roomId);
            },
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
          // GoRoute(
          //   path: '/room_list/:roomId',
          //   builder: (context, state) {
          //     final roomId = state.pathParameters['roomId']!;
          //     return RoomListScreen(title: '', loadAction: (int page, int limit) {  },);
          //   },
          // ),
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
          GoRoute(
            path: '/workshop/:roomId',
            builder: (context, state) {
              final String roomId = state.pathParameters['roomId']!;
              return WorkshopScreen(roomId: roomId, folderId: null);
            },
            routes: [
              GoRoute(
                path: ':folderId', // Дочерний маршрут: /workshop/:roomId/:folderId
                builder: (context, state) {
                  final String roomId = state.pathParameters['roomId']!;
                  final String? folderId = state.pathParameters['folderId'];
                  return WorkshopScreen(roomId: roomId, folderId: folderId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/select-folder/:roomId/:targetId',
            builder: (context, state) => SelectFolderScreen(
              roomId: state.pathParameters['roomId']!,
              targetId: state.pathParameters['targetId']!,
              currentFolderId: null,
            ),
            routes: [
              GoRoute(
                path: ':currentFolderId',
                builder: (context, state) => SelectFolderScreen(
                  roomId: state.pathParameters['roomId']!,
                  targetId: state.pathParameters['targetId']!,
                  currentFolderId: state.pathParameters['currentFolderId'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/select-folder-diary/:roomId',
            builder: (context, state) => SelectFolderDiaryScreen(
              roomId: state.pathParameters['roomId']!,
              currentFolderId: null,
            ),
            routes: [
              GoRoute(
                path: ':currentFolderId',
                builder: (context, state) => SelectFolderDiaryScreen(
                  roomId: state.pathParameters['roomId']!,
                  currentFolderId: state.pathParameters['currentFolderId'],
                ),
              ),
            ],
          ),
        ],
      ),
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
    );
  }
}
