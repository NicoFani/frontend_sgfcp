import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
 
  Future<void> launchUserManual(BuildContext context, String url) async {
  final Uri urlUri = Uri.parse(url);
    if (!await launchUrl(urlUri, mode: LaunchMode.externalApplication)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estadísticas - En desarrollo')),
              );
    }
  }