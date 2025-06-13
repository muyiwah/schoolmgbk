import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/login_screen.dart';
import 'package:schmgtsystem/providers/user_provider.dart';

AppBar buildAppBar(context) {
  return AppBar(toolbarHeight: 70,
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LoveSpring Admin',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'School Management',
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
      Text(Provider.of<UserProvider>(
      listen: true,
      context,
    ).userRole.toString()),
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
        onPressed: () {

  Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OakwoodLoginScreen()));

        },
      ),
      GestureDetector(
        onTap: () {
          
            Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OakwoodLoginScreen()),
          );
        },
        child: const CircleAvatar(
          backgroundImage: NetworkImage('https://via.placeholder.com/32'),
          radius: 16,
        ),
      ),
      const SizedBox(width: 16),
    ],
  );
}
