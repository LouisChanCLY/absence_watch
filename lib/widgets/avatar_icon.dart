// Flutter imports:
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? profileImageUrl;

  const ProfileAvatar({
    super.key,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Icon(Icons.account_circle, size: 10),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: CircleAvatar(
        backgroundImage: NetworkImage(
          profileImageUrl!,
        ),
      ),
    );
  }
}
