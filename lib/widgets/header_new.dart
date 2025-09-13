import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/login_screen.dart';
import 'package:schmgtsystem/providers/auth_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/utils/helpers.dart';

AppBar buildAppBar(context, WidgetRef ref) {
  final user = ref.read(RiverpodProvider.profileProvider);
  return AppBar(
    toolbarHeight: 70,
    backgroundColor: Colors.white,
    elevation: 0,
    title: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  user.user?.role.toString().capitalize() ?? '',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
           user.user?.fullName ?? '',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    ),
    actions: [
      Text('Admin'),
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        },
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        },
        child: const CircleAvatar(radius: 16),
      ),
      const SizedBox(width: 16),
    ],
  );
}
