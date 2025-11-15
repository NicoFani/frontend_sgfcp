import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff465d91),
      surfaceTint: Color(0xff465d91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd9e2ff),
      onPrimaryContainer: Color(0xff2e4578),
      secondary: Color(0xff825513),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffddb8),
      onSecondaryContainer: Color(0xff653e00),
      tertiary: Color(0xff33618d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffd0e4ff),
      onTertiaryContainer: Color(0xff164974),
      error: Color(0xff904a46),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad7),
      onErrorContainer: Color(0xff733330),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff171d1e),
      onSurfaceVariant: Color(0xff3f484a),
      outline: Color(0xff6f797a),
      outlineVariant: Color(0xffbfc8ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff001944),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff2e4578),
      secondaryFixed: Color(0xffffddb8),
      onSecondaryFixed: Color(0xff2a1700),
      secondaryFixedDim: Color(0xfff8bb71),
      onSecondaryFixedVariant: Color(0xff653e00),
      tertiaryFixed: Color(0xffd0e4ff),
      onTertiaryFixed: Color(0xff001d35),
      tertiaryFixedDim: Color(0xff9ecafc),
      onTertiaryFixedVariant: Color(0xff164974),
      surfaceDim: Color(0xffd5dbdc),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe9eff0),
      surfaceContainerHigh: Color(0xffe3e9ea),
      surfaceContainerHighest: Color(0xffdee3e5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff475d91),
      surfaceTint: Color(0xff465d91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff556ca1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff4f2f00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff936321),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00385f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff43709d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e2321),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa15854),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff0c1213),
      onSurfaceVariant: Color(0xff2f3839),
      outline: Color(0xff4b5456),
      outlineVariant: Color(0xff656f70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xff556ca1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3d5487),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff936321),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff774b08),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff43709d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff285883),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c7c9),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f6),
      surfaceContainer: Color(0xffe3e9ea),
      surfaceContainerHigh: Color(0xffd8dedf),
      surfaceContainerHighest: Color(0xffcdd3d4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff475d92),
      surfaceTint: Color(0xff465d91),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff30487b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff412600),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff684000),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002e4f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff194c77),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff511918),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff763632),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fafb),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e2f),
      outlineVariant: Color(0xff414b4c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3133),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xff30487b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff173162),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff684000),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4a2c00),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff194c77),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff00355a),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4babb),
      surfaceBright: Color(0xfff5fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2f3),
      surfaceContainer: Color(0xffdee3e5),
      surfaceContainerHigh: Color(0xffcfd5d6),
      surfaceContainerHighest: Color(0xffc2c7c9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb0c6ff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff142e60),
      primaryContainer: Color(0xff2e4578),
      onPrimaryContainer: Color(0xffd9e2ff),
      secondary: Color(0xfff8bb71),
      onSecondary: Color(0xff472a00),
      secondaryContainer: Color(0xff653e00),
      onSecondaryContainer: Color(0xffffddb8),
      tertiary: Color(0xff9ecafc),
      onTertiary: Color(0xff003256),
      tertiaryContainer: Color(0xff164974),
      onTertiaryContainer: Color(0xffd0e4ff),
      error: Color(0xffffb3ae),
      onError: Color(0xff571e1c),
      errorContainer: Color(0xff733330),
      onErrorContainer: Color(0xffffdad7),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffdee3e5),
      onSurfaceVariant: Color(0xffbfc8ca),
      outline: Color(0xff899294),
      outlineVariant: Color(0xff3f484a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff465d91),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff001944),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff2e4578),
      secondaryFixed: Color(0xffffddb8),
      onSecondaryFixed: Color(0xff2a1700),
      secondaryFixedDim: Color(0xfff8bb71),
      onSecondaryFixedVariant: Color(0xff653e00),
      tertiaryFixed: Color(0xffd0e4ff),
      onTertiaryFixed: Color(0xff001d35),
      tertiaryFixedDim: Color(0xff9ecafc),
      onTertiaryFixedVariant: Color(0xff164974),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff343a3b),
      surfaceContainerLowest: Color(0xff090f10),
      surfaceContainerLow: Color(0xff171d1e),
      surfaceContainer: Color(0xff1b2122),
      surfaceContainerHigh: Color(0xff252b2c),
      surfaceContainerHighest: Color(0xff303637),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffafc6ff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff052355),
      primaryContainer: Color(0xff7990c7),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd5a6),
      onSecondary: Color(0xff382000),
      secondaryContainer: Color(0xffbc8641),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffc5dfff),
      onTertiary: Color(0xff002745),
      tertiaryContainer: Color(0xff6894c3),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2ce),
      onError: Color(0xff481312),
      errorContainer: Color(0xffcb7b75),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd4dee0),
      outline: Color(0xffaab4b5),
      outlineVariant: Color(0xff889294),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff2f4779),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff000f30),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff1b3466),
      secondaryFixed: Color(0xffffddb8),
      onSecondaryFixed: Color(0xff1c0e00),
      secondaryFixedDim: Color(0xfff8bb71),
      onSecondaryFixedVariant: Color(0xff4f2f00),
      tertiaryFixed: Color(0xffd0e4ff),
      onTertiaryFixed: Color(0xff001224),
      tertiaryFixedDim: Color(0xff9ecafc),
      onTertiaryFixedVariant: Color(0xff00385f),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff3f4647),
      surfaceContainerLowest: Color(0xff040809),
      surfaceContainerLow: Color(0xff191f20),
      surfaceContainer: Color(0xff23292a),
      surfaceContainerHigh: Color(0xff2d3435),
      surfaceContainerHighest: Color(0xff393f40),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb0c6ff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffabc2fd),
      onPrimaryContainer: Color(0xff000a24),
      secondary: Color(0xffffeddc),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xfff3b76d),
      onSecondaryContainer: Color(0xff140900),
      tertiary: Color(0xffe8f1ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff9ac6f8),
      onTertiaryContainer: Color(0xff000c1a),
      error: Color(0xffffecea),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea8),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f3),
      outlineVariant: Color(0xffbbc4c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee3e5),
      inversePrimary: Color(0xff2f4779),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff000f30),
      secondaryFixed: Color(0xffffddb8),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xfff8bb71),
      onSecondaryFixedVariant: Color(0xff1c0e00),
      tertiaryFixed: Color(0xffd0e4ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff9ecafc),
      onTertiaryFixedVariant: Color(0xff001224),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff4b5152),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2122),
      surfaceContainer: Color(0xff2b3133),
      surfaceContainerHigh: Color(0xff363c3e),
      surfaceContainerHighest: Color(0xff424849),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,

     // ===== BOTONES SQUARED (GLOBAL) =====
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            fixedSize: WidgetStatePropertyAll(
              const Size(double.infinity, 56), // 👈 altura global
            ),
            iconSize: const WidgetStatePropertyAll(24),
            textStyle: WidgetStatePropertyAll(textTheme.titleMedium),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            fixedSize: WidgetStatePropertyAll(
              const Size(double.infinity, 56), // 👈 altura global
            ),
            iconSize: const WidgetStatePropertyAll(24),
            textStyle: WidgetStatePropertyAll(textTheme.titleMedium),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            fixedSize: WidgetStatePropertyAll(
              const Size(double.infinity, 56), // 👈 altura global
            ),
            iconSize: const WidgetStatePropertyAll(24),
            textStyle: WidgetStatePropertyAll(textTheme.titleMedium),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            fixedSize: WidgetStatePropertyAll(
              const Size(double.infinity, 56), // 👈 altura global
            ),
            iconSize: const WidgetStatePropertyAll(24),
            textStyle: WidgetStatePropertyAll(textTheme.titleMedium),
          ),
        ),
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
