import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart';
import '../../core/storage/local_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  ImageProvider? _avatar;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  Future<void> _restore() async {
    try {
      final avatar = await readAvatar();
      if (!mounted || _avatar != null || avatar == null) return;
      setState(() => _avatar = avatar);
    } catch (_) {
      _message('Could not restore the photo.');
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cameraBlocked() async {
    final open = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Camera access is blocked'),
            content: const Text(
              'Allow Camera in app settings to take a profile photo. You can still choose one from your gallery.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open settings'),
              ),
            ],
          ),
    );
    if (open == true && mounted) {
      final opened = await openAppSettings();
      if (!opened) _message('Could not open app settings.');
    }
  }

  Future<void> _choose(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (!kIsWeb && source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!mounted) return;
        switch (status) {
          case PermissionStatus.granted:
            break;
          case PermissionStatus.denied:
            _message(
              'Allow camera access to take a photo, or use the gallery.',
            );
            return;
          case PermissionStatus.permanentlyDenied:
            await _cameraBlocked();
            return;
          case PermissionStatus.restricted:
          case PermissionStatus.limited:
          case PermissionStatus.provisional:
            _message('Camera access is unavailable on this device.');
            return;
        }
      }
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final image = await writeAvatar(picked);
      if (!mounted) return;
      setState(() => _avatar = image);
    } catch (_) {
      _message('Could not save the photo. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 52,
            foregroundImage: _avatar,
            child: const Text('U'),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _busy ? null : () async => _choose(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choose photo'),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : () async => _choose(ImageSource.camera),
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text(kIsWeb ? 'Use camera or file' : 'Take photo'),
        ),
      ],
    ),
  );
}
