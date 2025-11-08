import 'package:flutter/material.dart';

/// Centralized app styles for performance optimization
/// All TextStyles and BoxDecorations are const to prevent recreation on every build
class AppStyles {
  AppStyles._(); // Private constructor to prevent instantiation

  // ============================================================================
  // COLORS
  // ============================================================================
  static const Color primaryBackground = Color(0xFF0F1419);
  static const Color cardBackground = Color(0xFF1A1F26);
  static const Color borderColor = Color(0xFF2C3E50);
  static const Color accentBlue = Color(0xFF539DF3);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE74C3C);

  // ============================================================================
  // TEXT STYLES - Headers
  // ============================================================================
  static const TextStyle headerLarge = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headerMedium = TextStyle(
    color: textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headerSmall = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ============================================================================
  // TEXT STYLES - Body
  // ============================================================================
  static const TextStyle bodyLarge = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodySmall = TextStyle(
    color: textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyRegular = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // ============================================================================
  // TEXT STYLES - Special
  // ============================================================================
  static const TextStyle caption = TextStyle(
    color: textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle captionSmall = TextStyle(
    color: textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelBold = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle labelSemiBold = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelMedium = TextStyle(
    color: textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelLight = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );

  // ============================================================================
  // TEXT STYLES - Numbers/Data
  // ============================================================================
  static const TextStyle numberLarge = TextStyle(
    color: textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle numberMedium = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle numberSmall = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ============================================================================
  // TEXT STYLES - Status/Badge
  // ============================================================================
  static const TextStyle statusActive = TextStyle(
    color: successGreen,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle statusInactive = TextStyle(
    color: textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle badge = TextStyle(
    color: textPrimary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  // ============================================================================
  // BOX DECORATIONS - Cards
  // ============================================================================
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground.withOpacity(0.6),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: borderColor.withOpacity(0.4),
      width: 1,
    ),
  );

  static final BoxDecoration cardDecorationElevated = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: borderColor.withOpacity(0.6),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static final BoxDecoration cardDecorationSmall = BoxDecoration(
    color: cardBackground.withOpacity(0.6),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: borderColor.withOpacity(0.4),
      width: 1,
    ),
  );

  // ============================================================================
  // BOX DECORATIONS - Buttons
  // ============================================================================
  static final BoxDecoration buttonPrimary = BoxDecoration(
    color: accentBlue,
    borderRadius: BorderRadius.circular(8),
  );

  static final BoxDecoration buttonSecondary = BoxDecoration(
    color: borderColor.withOpacity(0.6),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: borderColor,
      width: 1,
    ),
  );

  static final BoxDecoration buttonOutlined = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: accentBlue,
      width: 1,
    ),
  );

  // ============================================================================
  // BOX DECORATIONS - Input Fields
  // ============================================================================
  static final BoxDecoration inputDecoration = BoxDecoration(
    color: cardBackground.withOpacity(0.4),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: borderColor.withOpacity(0.6),
      width: 1,
    ),
  );

  static final BoxDecoration inputDecorationFocused = BoxDecoration(
    color: cardBackground.withOpacity(0.6),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: accentBlue,
      width: 2,
    ),
  );

  // ============================================================================
  // BOX DECORATIONS - Badges
  // ============================================================================
  static final BoxDecoration badgeSuccess = BoxDecoration(
    color: successGreen.withOpacity(0.2),
    borderRadius: BorderRadius.circular(4),
    border: Border.all(
      color: successGreen,
      width: 1,
    ),
  );

  static final BoxDecoration badgeError = BoxDecoration(
    color: errorRed.withOpacity(0.2),
    borderRadius: BorderRadius.circular(4),
    border: Border.all(
      color: errorRed,
      width: 1,
    ),
  );

  static final BoxDecoration badgeNeutral = BoxDecoration(
    color: borderColor.withOpacity(0.3),
    borderRadius: BorderRadius.circular(4),
    border: Border.all(
      color: borderColor,
      width: 1,
    ),
  );

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(16));

  // ============================================================================
  // SPACING
  // ============================================================================
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // ============================================================================
  // EDGE INSETS
  // ============================================================================
  static const EdgeInsets paddingXSmall = EdgeInsets.all(4);
  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);

  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: 24);
}
