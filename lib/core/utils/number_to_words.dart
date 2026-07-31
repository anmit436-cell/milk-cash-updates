/// Converts a number to Indian English words
/// e.g., 97000 → "Ninety Seven Thousand Rupees Only"
class NumberToWords {
  static const List<String> _ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen',
  ];

  static const List<String> _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety',
  ];

  /// Convert [number] to Indian English words with "Rupees Only" suffix
  static String convert(int number) {
    if (number == 0) return 'Zero Rupees Only';
    if (number < 0) return 'Minus ${convert(-number)}';

    String words = _convertToWords(number).trim();
    return '$words Rupees Only';
  }

  static String _convertToWords(int number) {
    if (number == 0) return '';

    String result = '';

    // Crores (1,00,00,000)
    if (number >= 10000000) {
      result += '${_convertToWords(number ~/ 10000000)} Crore ';
      number %= 10000000;
    }

    // Lakhs (1,00,000)
    if (number >= 100000) {
      result += '${_convertToWords(number ~/ 100000)} Lakh ';
      number %= 100000;
    }

    // Thousands (1,000)
    if (number >= 1000) {
      result += '${_convertToWords(number ~/ 1000)} Thousand ';
      number %= 1000;
    }

    // Hundreds (100)
    if (number >= 100) {
      result += '${_convertToWords(number ~/ 100)} Hundred ';
      number %= 100;
    }

    // Tens and ones
    if (number > 0) {
      if (number < 20) {
        result += _ones[number];
      } else {
        result += _tens[number ~/ 10];
        if (number % 10 > 0) {
          result += ' ${_ones[number % 10]}';
        }
      }
    }

    return result.trim();
  }
}
