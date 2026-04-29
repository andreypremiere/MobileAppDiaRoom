import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final IconData errorIcon;

  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24.0,
    this.errorIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        child:  CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: context.ui.primaryColor,
      child: Icon(errorIcon, color: Colors.white, size: radius),
    );
  }
}