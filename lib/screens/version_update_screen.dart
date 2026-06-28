import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/auth_service.dart';

class VersionUpdateScreen extends StatelessWidget {
  final String message;
  final bool isCritical;

  const VersionUpdateScreen({
    super.key,
    required this.message,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    const String downloadUrl = 'https://diaroom.me';

    return PopScope(
      canPop: !isCritical,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (!isCritical)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 28),
                onPressed: () {
                  context.read<AuthProvider>().dismissOptionalUpdate();
                },
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isCritical ? Icons.gpp_bad_outlined : Icons.system_update_outlined,
                  size: 90,
                  color: isCritical ? Colors.redAccent : context.ui.primaryColor,
                ),
                const SizedBox(height: 32),

                Text(
                  isCritical ? 'Внимание!' : 'Доступно обновление',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  isCritical ? message : "Но можно обновить и потом",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const Spacer(),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: context.ui.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse(downloadUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text(
                    'Обновить',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}