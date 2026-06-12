import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../configuration/constants.dart';
import '../diary/link_button.dart';

class PostWorkshopLink extends StatelessWidget {
  final String? workshopLink;
  final String roomId;

  const PostWorkshopLink({super.key, this.workshopLink, required this.roomId});

  @override
  Widget build(BuildContext context) {
    if (workshopLink == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 6),
      child: CustomLinkButton(
        icon: Icons.burst_mode_outlined,
        label: 'Открыть каталог',
        onTap: () {
          final String path = (workshopLink == uuidNil)
              ? '/workshop/$roomId'
              : '/workshop/$roomId/$workshopLink';

          context.push(path);
        },
      ),
    );
  }
}