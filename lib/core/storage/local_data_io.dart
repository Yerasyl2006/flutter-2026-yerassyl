import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<File> _documentsFile(String name) async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}${Platform.pathSeparator}$name');
}

Future<String?> readUsersJson() async {
  final file = await _documentsFile('users.json');
  return await file.exists() ? file.readAsString() : null;
}

Future<void> writeUsersJson(String json) async {
  final file = await _documentsFile('users.json');
  final pending = File('${file.path}.tmp');
  await pending.writeAsString(json, flush: true);
  await pending.rename(file.path);
}

Future<ImageProvider?> readAvatar() async {
  final path = await SharedPreferencesAsync().getString('avatarPath') ?? '';
  if (path.isEmpty) return null;
  final file = File(path);
  return await file.exists() ? FileImage(file) : null;
}

Future<ImageProvider> writeAvatar(XFile picked) async {
  final target = await _documentsFile('avatar.jpg');
  final saved = await File(picked.path).copy(target.path);
  await SharedPreferencesAsync().setString('avatarPath', saved.path);
  final image = FileImage(saved);
  await image.evict();
  return image;
}
