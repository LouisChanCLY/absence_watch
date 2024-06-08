// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:absence_watch/models/profile.dart';

class ProfileProvider extends InheritedWidget {
  final Profile profile;

  const ProfileProvider(
      {super.key, required this.profile, required super.child});

  static ProfileProvider of(BuildContext context) {
    final ProfileProvider? result =
        context.dependOnInheritedWidgetOfExactType<ProfileProvider>();
    assert(result != null, 'No ProfileProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ProfileProvider oldWidget) =>
      profile != oldWidget.profile;
}
