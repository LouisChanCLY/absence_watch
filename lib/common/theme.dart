import 'package:flutter/material.dart';

Color pageBackgroundColor = const Color(0xFFFBFBFB);
Color primaryColor = const Color(0xFF3D5A6C);
Color primaryColorDisabled = const Color(0xFFb8cbd7);
Color primaryElementBackgroundColor = const Color(0xFFFFFFFF);
Color primaryElementBorderColor = const Color(0xFFE7E8EC);
MaterialColor secondaryColor = Colors.yellow;

Color secondaryTextColor = const Color(0xFF919191);

BorderSide primaryElementBorderSide = BorderSide(
  color: primaryElementBorderColor,
  width: 1.0,
);

ButtonStyle primaryButtonStyle = FilledButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
);

ButtonStyle primaryDisabledButtonStyle = FilledButton.styleFrom(
  backgroundColor: primaryColorDisabled,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
);

ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: primaryElementBackgroundColor,
  foregroundColor: primaryColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
);

ButtonStyle secondaryButtonStyle = FilledButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
);

ButtonStyle accentButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: Colors.white,
  side: BorderSide(color: primaryColor),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
);

TextStyle subtitleStyle =
    const TextStyle(color: Color(0xFF919198), fontSize: 12);
