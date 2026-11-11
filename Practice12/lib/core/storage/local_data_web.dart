import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> readUsersJson() =>
    SharedPreferencesAsync().getString('usersCache');

Future<void> writeUsersJson(String json) =>
    SharedPreferencesAsync().setString('usersCache', json);

Future<ImageProvider?> readAvatar() async {
  final base64 = await SharedPreferencesAsync().getString('avatarBytes') ?? '';
  return base64.isEmpty ? null : MemoryImage(base64Decode(base64));
}

Future<ImageProvider> writeAvatar(XFile picked) async {
  final bytes = await picked.readAsBytes();
  await SharedPreferencesAsync().setString('avatarBytes', base64Encode(bytes));
  return MemoryImage(bytes);
}
