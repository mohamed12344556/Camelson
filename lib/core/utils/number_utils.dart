class NumberUtils {
  // Map English digits to Arabic digits
  static const Map<String, String> _englishToArabicDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  // Map Arabic digits to English digits
  static const Map<String, String> _arabicToEnglishDigits = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// تحويل الأرقام من English إلى Arabic
  /// Converts English digits (0-9) to Arabic digits (٠-٩)
  static String toArabicDigits(String text) {
    String result = text;
    _englishToArabicDigits.forEach((english, arabic) {
      result = result.replaceAll(english, arabic);
    });
    return result;
  }

  /// تحويل الأرقام من Arabic إلى English
  /// Converts Arabic digits (٠-٩) to English digits (0-9)
  static String toEnglishDigits(String text) {
    String result = text;
    _arabicToEnglishDigits.forEach((arabic, english) {
      result = result.replaceAll(arabic, english);
    });
    return result;
  }

  /// تحويل رقم إلى Arabic حسب اللغة الحالية
  /// Convert number to localized format based on language
  static String formatNumber(dynamic number, {bool isArabic = false}) {
    final numberStr = number.toString();
    return isArabic ? toArabicDigits(numberStr) : numberStr;
  }

  /// تحويل رقم عشري مع تحديد عدد الخانات
  /// Format decimal number with specific decimal places
  static String formatDecimal(
    double number, {
    int decimalPlaces = 2,
    bool isArabic = false,
  }) {
    final formatted = number.toStringAsFixed(decimalPlaces);
    return isArabic ? toArabicDigits(formatted) : formatted;
  }

  /// تحويل سعر مع رمز العملة
  /// Format price with currency symbol
  static String formatPrice(
    double price, {
    String currency = '\$',
    int decimalPlaces = 2,
    bool isArabic = false,
    bool currencyAtStart = true,
  }) {
    final priceStr = price.toStringAsFixed(decimalPlaces);
    final localizedPrice = isArabic ? toArabicDigits(priceStr) : priceStr;

    if (currencyAtStart) {
      return '$currency$localizedPrice';
    } else {
      return '$localizedPrice $currency';
    }
  }

  /// تحويل رقم كبير مع فواصل
  /// Format large numbers with separators (e.g., 1,000,000)
  static String formatWithSeparator(
    int number, {
    String separator = ',',
    bool isArabic = false,
  }) {
    final numberStr = number.toString();
    final buffer = StringBuffer();
    final digits = numberStr.split('').reversed.toList();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(digits[i]);
    }

    final result = buffer.toString().split('').reversed.join();
    return isArabic ? toArabicDigits(result) : result;
  }

  /// تحويل نسبة مئوية
  /// Format percentage
  static String formatPercentage(
    double percentage, {
    int decimalPlaces = 0,
    bool isArabic = false,
    bool includeSymbol = true,
  }) {
    final percentStr = percentage.toStringAsFixed(decimalPlaces);
    final localized = isArabic ? toArabicDigits(percentStr) : percentStr;
    return includeSymbol ? '$localized%' : localized;
  }

  /// تحويل رقم إلى كلمات بالعربية (للأرقام من 0-99)
  /// Convert number to Arabic words (0-99)
  static String toArabicWords(int number) {
    if (number < 0 || number > 99) {
      return number.toString();
    }

    const ones = [
      'صفر',
      'واحد',
      'اثنان',
      'ثلاثة',
      'أربعة',
      'خمسة',
      'ستة',
      'سبعة',
      'ثمانية',
      'تسعة',
    ];

    const teens = [
      'عشرة',
      'أحد عشر',
      'اثنا عشر',
      'ثلاثة عشر',
      'أربعة عشر',
      'خمسة عشر',
      'ستة عشر',
      'سبعة عشر',
      'ثمانية عشر',
      'تسعة عشر',
    ];

    const tens = [
      '',
      'عشرة',
      'عشرون',
      'ثلاثون',
      'أربعون',
      'خمسون',
      'ستون',
      'سبعون',
      'ثمانون',
      'تسعون',
    ];

    if (number < 10) {
      return ones[number];
    } else if (number < 20) {
      return teens[number - 10];
    } else {
      final tensDigit = number ~/ 10;
      final onesDigit = number % 10;
      if (onesDigit == 0) {
        return tens[tensDigit];
      } else {
        return '${ones[onesDigit]} و${tens[tensDigit]}';
      }
    }
  }

  /// تحويل رقم هندي إلى English (للدول اللي بتستخدم الأرقام الهندية)
  /// Convert Hindi-Arabic digits to English (for countries using Hindi numerals)
  static String hindiToEnglish(String text) {
    const hindiToEnglish = {
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };

    String result = text;
    hindiToEnglish.forEach((hindi, english) {
      result = result.replaceAll(hindi, english);
    });
    return result;
  }

  /// تحويل أي نوع أرقام (عربي/هندي) إلى English
  /// Normalize any digit format to English
  static String normalizeDigits(String text) {
    String result = text;

    // Convert Arabic digits
    result = toEnglishDigits(result);

    // Convert Hindi digits
    result = hindiToEnglish(result);

    return result;
  }

  /// Parse string to double safely (handles Arabic and Hindi digits)
  static double? parseDouble(String text) {
    final normalized = normalizeDigits(text);
    return double.tryParse(normalized);
  }

  /// Parse string to int safely (handles Arabic and Hindi digits)
  static int? parseInt(String text) {
    final normalized = normalizeDigits(text);
    return int.tryParse(normalized);
  }
}
