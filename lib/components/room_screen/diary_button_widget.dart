import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dia_room/utils/app_theme.dart';

import '../../api/post_api.dart';
import '../../api/post_v2_api.dart'; // Твой путь к теме

class _StatShimmer extends StatelessWidget {
  final double width;
  const _StatShimmer({required this.width});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}


class DiaryButtonWidget extends StatefulWidget {
  final String roomId;
  const DiaryButtonWidget({super.key, required this.roomId});

  @override
  State<DiaryButtonWidget> createState() => _DiaryButtonWidgetState();
}

class _DiaryButtonWidgetState extends State<DiaryButtonWidget> {
  int? notesCount;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    // _fetchDiaryStats();
  }

  // Future<void> _fetchDiaryStats() async {
  //   try {
  //     // TODO: Твой запрос к API
  //     await Future.delayed(const Duration(milliseconds: 800));
  //     if (mounted) {
  //       setState(() {
  //         notesCount = 12;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //         hasError = true;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.ui.containerColor,
              Color.lerp(context.ui.containerColor, context.ui.primaryColor, 0.25)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/diary/${widget.roomId}'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.speaker_notes_outlined, size: 36, color: context.ui.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Дневник',
                    style: TextStyle(
                      color: context.ui.fontColorPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // const SizedBox(height: 6),
                  // if (isLoading)
                  //   const _StatShimmer(width: 70)
                  // else if (hasError)
                  //   Text(
                  //     'Ошибка',
                  //     style: TextStyle(color: Colors.redAccent.withAlpha(200), fontSize: 13),
                  //   )
                  // else
                  //   Text(
                  //     '$notesCount заметок',
                  //     style: TextStyle(
                  //       color: context.ui.fontColorHint,
                  //       fontSize: 13,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. ВИТРИНА
// ============================================================================
class ShowcaseButtonWidget extends StatefulWidget {
  final String roomId;
  const ShowcaseButtonWidget({super.key, required this.roomId});

  @override
  State<ShowcaseButtonWidget> createState() => _ShowcaseButtonWidgetState();
}

class _ShowcaseButtonWidgetState extends State<ShowcaseButtonWidget> {
  int? postsCount;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchShowcaseStats();
  }

  Future<void> _fetchShowcaseStats() async {
    try {
      final response = await getCountPostsV2(roomId: widget.roomId);

      if (response.success) {
        if (mounted) {
          setState(() {
            postsCount = response.data['count'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: context.ui.containerColor, // Сделали сплошной фон, как у дневника
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            // onTap: () => context.push('/personalRoomPosts/${widget.roomId}'),
            onTap: () => context.push('/personalRoomPostsV2/${widget.roomId}'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.featured_video_outlined, size: 36, color: context.ui.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Витрина',
                    style: TextStyle(
                      color: context.ui.fontColorPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isLoading)
                    const _StatShimmer(width: 65)
                  else if (hasError)
                    Text(
                      'Ошибка',
                      style: TextStyle(color: Colors.redAccent.withAlpha(200), fontSize: 13),
                    )
                  else
                    Text(
                      '$postsCount постов',
                      style: TextStyle(
                        color: context.ui.fontColorHint,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3. МАСТЕРСКАЯ
// ============================================================================
class WorkshopButtonWidget extends StatefulWidget {
  final String roomId;
  const WorkshopButtonWidget({super.key, required this.roomId});

  @override
  State<WorkshopButtonWidget> createState() => _WorkshopButtonWidgetState();
}

class _WorkshopButtonWidgetState extends State<WorkshopButtonWidget> {
  int? foldersCount;
  int? valuesCount;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    // _fetchWorkshopStats();
  }

  // Future<void> _fetchWorkshopStats() async {
  //   try {
  //     // TODO: Твой запрос к API
  //     await Future.delayed(const Duration(milliseconds: 2000));
  //     if (mounted) {
  //       setState(() {
  //         foldersCount = 5;
  //         valuesCount = 42;
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //         hasError = true;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.ui.containerColor, // Сплошной чистый фон
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/workshop/${widget.roomId}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                // Убрана сложная подложка, оставлена лаконичная иконка
                Icon(Icons.storage_outlined, color: context.ui.primaryColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Мастерская',
                        style: TextStyle(
                          color: context.ui.fontColorPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // const SizedBox(height: 6),
                      // if (isLoading)
                      //   const _StatShimmer(width: 120)
                      // else if (hasError)
                      //   Text(
                      //     'Ошибка загрузки',
                      //     style: TextStyle(color: Colors.redAccent.withAlpha(200), fontSize: 13),
                      //   )
                      // else
                      //   Text(
                      //     '$foldersCount папок • $valuesCount значений',
                      //     style: TextStyle(
                      //       color: context.ui.fontColorHint,
                      //       fontSize: 13,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.ui.fontColorHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}