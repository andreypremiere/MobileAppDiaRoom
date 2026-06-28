import 'package:dia_room/models/enums/file_type.dart';
import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/screens/authorization/registration_screen.dart';
import 'package:dia_room/screens/comments_screen.dart';
import 'package:dia_room/screens/diary/diary_screen.dart';
import 'package:dia_room/screens/diary/list_diaries_screen.dart';
import 'package:dia_room/screens/diary/search_messages.dart';
import 'package:dia_room/screens/diary/select_folder_diary.dart';
import 'package:dia_room/screens/diary/select_post_diary.dart';
import 'package:dia_room/screens/global_search_screen.dart';
import 'package:dia_room/screens/main_page_v2.dart';
import 'package:dia_room/screens/publication_v2/create_post_v2_screen.dart';
import 'package:dia_room/screens/publication_v2/personal_posts_screen_v2.dart';
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
import 'package:dia_room/screens/room/settings_screen.dart';
import 'package:dia_room/screens/version_update_screen.dart';
import 'package:dia_room/screens/workshop/select_folder_screen.dart';
import 'package:dia_room/screens/workshop/workshop_screen.dart';
import 'package:dia_room/services/diary/upload_manager.dart';
import 'package:dia_room/services/workshop/uploader_manager.dart';
import 'package:dia_room/utils/auth_service.dart';
import 'package:dia_room/utils/dio_service.dart';
import 'package:dia_room/utils/draft_provider.dart';
import 'package:dia_room/utils/theme_provider.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'api/diary_api.dart';
import 'api/post_v2_api.dart';
import 'components/diary/select_post_v2.dart';
import 'components/post-v2/post_view_v2_screen.dart';
import 'contracts/diary/response/comment_response.dart' as message_contract;
import 'contracts/posts_v2/responses/comment_response.dart' as post_contract;
import 'contracts/posts_v2/responses/post_response.dart';
import 'models/enums/diary/search_method.dart';
import 'models/enums/global_search/global_search_method.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final authProvider = AuthProvider();
  ApiService.init(authProvider);
  await authProvider.loadSession();

  await authProvider.checkApplicationVersion();

  print(
    'Пользователь аутентифицирован?\nuserId: ${authProvider.userId}\nroomId: ${authProvider.roomId}\n'
    'isAuthenticated: ${authProvider.isAuthenticated}\nisConfigured: ${authProvider.isConfigured} ',
  );

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
      localizationsDelegates: const [
        // Стандартные делегаты для работы компонентов Flutter (кнопки, даты, инпуты)
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

        // Делегат flutter_quill
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],

      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
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

          if (auth.versionStatus == 'UPDATE_CRITICAL') {
            return '/update_critical';
          }

          if (auth.versionStatus == 'UPDATE' &&
              !auth.isOptionalUpdateDismissed &&
              location != '/update_optional') {
            return '/update_optional';
          }

          final publicRoutes = ['/login', '/registration', '/verifyCode'];

          final bool isPublicPage = publicRoutes.any(
            (route) => location.startsWith(route),
          );

          print(
            'Текущий location: $location, Публичная: $isPublicPage, Авторизован: $loggedIn',
          );

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
          GoRoute(path: '/', builder: (context, state) => MainPageScreenV2()),

          GoRoute(
            path: '/update_critical',
            builder: (context, state) => VersionUpdateScreen(
              message: auth.versionMessage,
              isCritical: true,
            ),
          ),
          GoRoute(
            path: '/update_optional',
            builder: (context, state) => VersionUpdateScreen(
              message: auth.versionMessage,
              isCritical: false,
            ),
          ),

          GoRoute(
            path: '/settings',
            builder: (context, state) {
              return SettingsScreen();
            },
          ),
          GoRoute(
            path: '/create_post_v2',
            builder: (context, state) {
              return CreateInstagramPostScreen();
            },
          ),

          GoRoute(
            path: '/diary/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return DiaryScreen(roomId: roomId);
            },
          ),
          GoRoute(
            path: '/search-messages/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;

              final extra = state.extra as Map<String, dynamic>?;

              final text = extra?['text'] as String?;
              final method = extra?['method'] as SearchMethod?;

              return SearchMessagesScreen(
                roomId: roomId,
                text: text,
                method: method,
              );
            },
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) {
              final textParam = state.uri.queryParameters['text'];

              final methodParamStr = state.uri.queryParameters['method'];

              GlobalSearchMethod? methodParam;
              if (methodParamStr != null) {
                methodParam = GlobalSearchMethod.values.firstWhere(
                      (e) => e.name == methodParamStr,
                  orElse: () => GlobalSearchMethod.room,
                );
              }

              return GlobalSearchScreen(
                text: textParam,
                method: methodParam,
              );
            },
          ),
          GoRoute(
            name: 'verifyCode',
            path: '/verifyCode/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              final email = state.uri.queryParameters['email'] ?? '';
              return VerifyCode(userId: userId, email: email);
            },
          ),
          GoRoute(
            path: '/post_preview',
            builder: (context, state) {
              PostDraft? draft = context.read<DraftProvider>().currentDraft;
              if (draft == null) return NewPublicPostScreen();
              return PostPreviewScreen(postDraft: draft);
            },
          ),
          GoRoute(
            path: '/configureRoom',
            builder: (context, state) {
              return RoomSettingsScreen();
            },
          ),
          GoRoute(path: "/diaries",
            builder: (context, state) {
              return DiaryListScreen();
            },
          ),

          GoRoute(
            name: 'registration',
            path: '/registration',
            builder: (context, state) => const Registration(),
          ),
          GoRoute(
            name: 'login',
            path: '/login',
            builder: (context, state) => const Login(),
          ),

          GoRoute(
            path: "/showPost/:roomId/:postId",
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              final postId = state.pathParameters['postId']!;
              return ShowingPostScreen(postId: postId, roomId: roomId,);
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

          GoRoute(
            path: '/room/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return RoomScreen(roomId: roomId);
            },
          ),

          GoRoute(
            path: '/personalRoomPosts/:roomId',
            builder: (context, state) {
              final String roomId = state.pathParameters['roomId']!;

              return PersonalPostsScreen(roomId: roomId);
            },
          ),
          GoRoute(
            path: '/personalRoomPostsV2/:roomId',
            builder: (context, state) {
              final String roomId = state.pathParameters['roomId']!;

              return PersonalPostsScreenV2(roomId: roomId);
            },
          ),
          GoRoute(
            path: '/posts_v2/comments/:postId',
            builder: (context, state) {
              final postId = state.pathParameters['postId']!;
              return CommentsScreen<post_contract.CommentResponse>(
                targetId: postId,
                fromMap: post_contract.CommentResponse.fromMap,
                onLoadCommentsApi: ({required id, required page, required limit}) =>
                    getComments(postId: id, page: page, limit: limit),
                onSendCommentApi: ({required id, required text}) =>
                    createComment(postId: id, text: text),
              );
            },
          ),
          GoRoute(
            path: '/message/comments/:messageId',
            builder: (context, state) {
              final messageId = state.pathParameters['messageId']!;
              return CommentsScreen<message_contract.CommentResponse>(
                targetId: messageId,
                fromMap: message_contract.CommentResponse.fromMap,
                onLoadCommentsApi: ({required id, required page, required limit}) =>
                    getMessageComments(messageId: id, page: page, limit: limit),
                onSendCommentApi: ({required id, required text}) =>
                    createMessageComment(messageId: id, text: text),
              );
            },
          ),

          GoRoute(
            path: '/share/post/:id',
            redirect: (context, state) {
              final postId = state.pathParameters['id'] ?? '';
              return '/post_v2/$postId';
            },
          ),

          GoRoute(
            path: '/post_v2/:id',
            builder: (context, state) {
              final postId = state.pathParameters['id'] ?? '';
              final postResponse = state.extra as PostResponse?;

              return PostViewScreen(
                postId: postId,
                post: postResponse,
              );
            },
          ),

          GoRoute(
            path: '/select_post_v2',
            builder: (context, state) {
              return SelectPostV2();
            },
          ),

          GoRoute(
            path: '/newPublicPost',
            builder: (context, state) => const NewPublicPostScreen(),
          ),

          GoRoute(
            path: '/full_image_screen',
            builder: (context, state) {
              final Map<String, dynamic> params =
                  state.extra as Map<String, dynamic>;
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

              return FullScreenVideoScreen(videoUrl: videoUrl, type: type);
            },
          ),
          GoRoute(
            path: '/select_post_diary',
            builder: (context, state) {
              return SelectPostDiary();
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
                path: ':folderId',
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
            builder: (context, state) {
              final filterFoldersStr =
                  state.uri.queryParameters['filterFolders'] ?? 'false';
              final filterFolders = filterFoldersStr == 'true';

              return SelectFolderScreen(
                roomId: state.pathParameters['roomId']!,
                targetId: state.pathParameters['targetId']!,
                currentFolderId: null,
                filterFolders: filterFolders,
              );
            },
            routes: [
              GoRoute(
                path: ':currentFolderId',
                builder: (context, state) {
                  final filterFoldersStr =
                      state.uri.queryParameters['filterFolders'] ?? 'false';
                  final filterFolders = filterFoldersStr == 'true';

                  return SelectFolderScreen(
                    roomId: state.pathParameters['roomId']!,
                    targetId: state.pathParameters['targetId']!,
                    currentFolderId: state.pathParameters['currentFolderId'],
                    filterFolders: filterFolders,
                  );
                },
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
