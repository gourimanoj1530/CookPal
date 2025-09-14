class MeasurementConversion {
  static const Map<String, Map<String, double>> _conversions = {
    // Volume conversions (to ml)
    'volume': {
      'ml': 1.0,
      'l': 1000.0,
      'tsp': 5.0,
      'tbsp': 15.0,
      'cup': 240.0,
      'fl oz': 30.0,
      'pint': 473.0,
      'quart': 946.0,
      'gallon': 3785.0,
    },
    // Weight conversions (to grams)
    'weight': {
      'g': 1.0,
      'kg': 1000.0,
      'oz': 28.35,
      'lb': 453.6,
      'mg': 0.001,
    },
    // Temperature conversions
    'temperature': {
      'celsius': 1.0,
      'fahrenheit': 1.0, // Special handling needed
      'kelvin': 1.0, // Special handling needed
    }
  };

  static double? convert(double amount, String fromUnit, String toUnit) {
    fromUnit = fromUnit.toLowerCase();
    toUnit = toUnit.toLowerCase();

    if (fromUnit == toUnit) return amount;

    // Check volume conversions
    if (_conversions['volume']!.containsKey(fromUnit) &&
        _conversions['volume']!.containsKey(toUnit)) {
      double mlValue = amount * _conversions['volume']![fromUnit]!;
      return mlValue / _conversions['volume']![toUnit]!;
    }

    // Check weight conversions
    if (_conversions['weight']!.containsKey(fromUnit) &&
        _conversions['weight']!.containsKey(toUnit)) {
      double gramValue = amount * _conversions['weight']![fromUnit]!;
      return gramValue / _conversions['weight']![toUnit]!;
    }

    // Temperature conversions
    if (fromUnit == 'celsius' && toUnit == 'fahrenheit') {
      return (amount * 9/5) + 32;
    }
    if (fromUnit == 'fahrenheit' && toUnit == 'celsius') {
      return (amount - 32) * 5/9;
    }
    if (fromUnit == 'celsius' && toUnit == 'kelvin') {
      return amount + 273.15;
    }
    if (fromUnit == 'kelvin' && toUnit == 'celsius') {
      return amount - 273.15;
    }

    return null; // No conversion found
  }

  static List<String> getVolumeUnits() {
    return _conversions['volume']!.keys.toList();
  }

  static List<String> getWeightUnits() {
    return _conversions['weight']!.keys.toList();
  }

  static List<String> getTemperatureUnits() {
    return ['celsius', 'fahrenheit', 'kelvin'];
  }

  static String getUnitCategory(String unit) {
    unit = unit.toLowerCase();
    if (_conversions['volume']!.containsKey(unit)) return 'volume';
    if (_conversions['weight']!.containsKey(unit)) return 'weight';
    if (_conversions['temperature']!.containsKey(unit)) return 'temperature';
    return 'unknown';
  }
}