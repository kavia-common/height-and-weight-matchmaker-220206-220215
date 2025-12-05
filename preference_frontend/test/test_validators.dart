import 'package:flutter_test/flutter_test.dart';
import 'package:preference_frontend/utils/validators.dart';

void main() {
  group('isValidInclusiveRange', () {
    test('returns true when min <= max and both finite', () {
      expect(isValidInclusiveRange(0, 0), isTrue);
      expect(isValidInclusiveRange(-10, 10), isTrue);
      expect(isValidInclusiveRange(1.5, 1.6), isTrue);
    });

    test('returns false when min > max', () {
      expect(isValidInclusiveRange(5, 1), isFalse);
    });

    test('returns false when any is null', () {
      expect(isValidInclusiveRange(null, 1), isFalse);
      expect(isValidInclusiveRange(1, null), isFalse);
      expect(isValidInclusiveRange(null, null), isFalse);
    });

    test('returns false when any is not finite', () {
      expect(isValidInclusiveRange(double.infinity, 1), isFalse);
      expect(isValidInclusiveRange(1, double.nan), isFalse);
    });
  });

  group('isValidHeightRangeCm', () {
    test('valid range inside allowed limits', () {
      expect(isValidHeightRangeCm(150, 190), isTrue);
      expect(isValidHeightRangeCm(80, 250), isTrue); // edges inclusive
    });

    test('invalid when min > max', () {
      expect(isValidHeightRangeCm(200, 150), isFalse);
    });

    test('invalid when below minimum or above maximum', () {
      expect(isValidHeightRangeCm(79, 100), isFalse);
      expect(isValidHeightRangeCm(100, 251), isFalse);
    });

    test('invalid when nulls or non-finite', () {
      expect(isValidHeightRangeCm(null, 100), isFalse);
      expect(isValidHeightRangeCm(100, null), isFalse);
      expect(isValidHeightRangeCm(double.nan, 100), isFalse);
      expect(isValidHeightRangeCm(100, double.infinity), isFalse);
    });
  });

  group('isValidWeightRangeKg', () {
    test('valid range inside allowed limits', () {
      expect(isValidWeightRangeKg(55, 90), isTrue);
      expect(isValidWeightRangeKg(30, 250), isTrue); // edges inclusive
    });

    test('invalid when min > max', () {
      expect(isValidWeightRangeKg(100, 80), isFalse);
    });

    test('invalid when below minimum or above maximum', () {
      expect(isValidWeightRangeKg(29, 50), isFalse);
      expect(isValidWeightRangeKg(50, 251), isFalse);
    });

    test('invalid when nulls or non-finite', () {
      expect(isValidWeightRangeKg(null, 50), isFalse);
      expect(isValidWeightRangeKg(50, null), isFalse);
      expect(isValidWeightRangeKg(double.nan, 50), isFalse);
      expect(isValidWeightRangeKg(50, double.infinity), isFalse);
    });
  });

  group('calculateBmiKgCm', () {
    test('computes correct BMI for valid inputs', () {
      // 70 kg, 175 cm => 70 / (1.75^2) = ~22.857
      final bmi = calculateBmiKgCm(70, 175);
      expect(bmi, closeTo(22.857, 0.001));
    });

    test('returns NaN for invalid inputs', () {
      expect(calculateBmiKgCm(0, 175).isNaN, isTrue);
      expect(calculateBmiKgCm(70, 0).isNaN, isTrue);
      expect(calculateBmiKgCm(-1, 175).isNaN, isTrue);
      expect(calculateBmiKgCm(70, -10).isNaN, isTrue);
      expect(calculateBmiKgCm(double.nan, 175).isNaN, isTrue);
      expect(calculateBmiKgCm(70, double.infinity).isNaN, isTrue);
    });
  });

  group('categorizeBmi', () {
    test('returns Unknown for non-finite BMI', () {
      expect(categorizeBmi(double.nan), equals('Unknown'));
      expect(categorizeBmi(double.infinity), equals('Unknown'));
    });

    test('returns category according to WHO ranges', () {
      expect(categorizeBmi(17.0), equals('Underweight'));
      expect(categorizeBmi(18.5), equals('Normal'));
      expect(categorizeBmi(22.0), equals('Normal'));
      expect(categorizeBmi(24.9), equals('Normal'));
      expect(categorizeBmi(25.0), equals('Overweight'));
      expect(categorizeBmi(27.5), equals('Overweight'));
      expect(categorizeBmi(29.9), equals('Overweight'));
      expect(categorizeBmi(30.0), equals('Obesity'));
      expect(categorizeBmi(35.0), equals('Obesity'));
    });
  });
}
