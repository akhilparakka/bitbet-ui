import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: Text(
          "Profile Section",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
