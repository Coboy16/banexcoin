import 'package:flutter/material.dart';

class AppColors {
  // ============ DARK THEME COLORS ============
  // Base colors
  static const Color primaryBackground = Color(0xFF0B0E11);
  static const Color secondaryBackground = Color(0xFF161A1E);
  static const Color cardBackground = Color(0xFF1E2329);
  static const Color surfaceColor = Color(0xFF2B3139);

  // Trading colors
  static const Color buyGreen = Color(0xFF0ECB81);
  static const Color sellRed = Color(0xFFFF6B6B);
  static const Color buyGreenLight = Color(0xFF2ECC71);
  static const Color sellRedLight = Color(0xFFE74C3C);

  // Accent colors
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color secondaryBlue = Color(0xFF1E40AF);
  static const Color accentYellow = Color(0xFFF59E0B);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB7BDC6);
  static const Color textMuted = Color(0xFF848E9C);
  static const Color textDisabled = Color(0xFF5E6673);

  // Border colors
  static const Color borderPrimary = Color(0xFF2B3139);
  static const Color borderSecondary = Color(0xFF373D47);
  static const Color borderActive = Color(0xFF3B82F6);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ============ LIGHT THEME COLORS ============

  // Base colors - Light
  static const Color primaryBackgroundLight = Color(0xFFF8FAFC);
  static const Color secondaryBackgroundLight = Color(0xFFFFFFFF);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceColorLight = Color(0xFFF1F5F9);

  // Trading colors - Light
  static const Color buyGreenLightTheme = Color(0xFF059669);
  static const Color sellRedLightTheme = Color(0xFFDC2626);
  static const Color buyGreenLightAccent = Color(0xFF10B981);
  static const Color sellRedLightAccent = Color(0xFFEF4444);

  // Accent colors - Light
  static const Color primaryBlueLight = Color(0xFF2563EB);
  static const Color secondaryBlueLight = Color(0xFF1D4ED8);
  static const Color accentYellowLight = Color(0xFFD97706);

  // Text colors - Light
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color textDisabledLight = Color(0xFF94A3B8);

  // Border colors - Light
  static const Color borderPrimaryLight = Color(0xFFE2E8F0);
  static const Color borderSecondaryLight = Color(0xFFCBD5E1);
  static const Color borderActiveLight = Color(0xFF2563EB);

  // Status colors - Light
  static const Color successLight = Color(0xFF059669);
  static const Color warningLight = Color(0xFFD97706);
  static const Color errorLight = Color(0xFFDC2626);
  static const Color infoLight = Color(0xFF2563EB);

  // ============ THEME-AWARE GETTERS ============

  // Método para obtener colores según el tema actual
  static Color getPrimaryBackground(bool isDark) =>
      isDark ? primaryBackground : primaryBackgroundLight;

  static Color getSecondaryBackground(bool isDark) =>
      isDark ? secondaryBackground : secondaryBackgroundLight;

  static Color getCardBackground(bool isDark) =>
      isDark ? cardBackground : cardBackgroundLight;

  static Color getSurfaceColor(bool isDark) =>
      isDark ? surfaceColor : surfaceColorLight;

  static Color getBuyGreen(bool isDark) =>
      isDark ? buyGreen : buyGreenLightTheme;

  static Color getSellRed(bool isDark) => isDark ? sellRed : sellRedLightTheme;

  static Color getPrimaryBlue(bool isDark) =>
      isDark ? primaryBlue : primaryBlueLight;

  static Color getSecondaryBlue(bool isDark) =>
      isDark ? secondaryBlue : secondaryBlueLight;

  static Color getAccentYellow(bool isDark) =>
      isDark ? accentYellow : accentYellowLight;

  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimary : textPrimaryLight;

  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondary : textSecondaryLight;

  static Color getTextMuted(bool isDark) => isDark ? textMuted : textMutedLight;

  static Color getTextDisabled(bool isDark) =>
      isDark ? textDisabled : textDisabledLight;

  static Color getBorderPrimary(bool isDark) =>
      isDark ? borderPrimary : borderPrimaryLight;

  static Color getBorderSecondary(bool isDark) =>
      isDark ? borderSecondary : borderSecondaryLight;

  static Color getBorderActive(bool isDark) =>
      isDark ? borderActive : borderActiveLight;

  static Color getSuccess(bool isDark) => isDark ? success : successLight;

  static Color getWarning(bool isDark) => isDark ? warning : warningLight;

  static Color getError(bool isDark) => isDark ? error : errorLight;

  static Color getInfo(bool isDark) => isDark ? info : infoLight;
}
