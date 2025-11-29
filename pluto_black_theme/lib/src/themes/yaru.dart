import '../../theme.dart';

const _primaryColor = YaruColors.adwaitaRed;

final yaruLight = createYaruLightTheme(
  primaryColor: _primaryColor,
  elevatedButtonColor: YaruColors.light.success,
);

final yaruDark = createYaruDarkTheme(
  primaryColor: _primaryColor,
  // elevatedButtonColor: YaruColors.dark.success,
  elevatedButtonColor: _primaryColor,
);
