import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/measurement_conversion.dart';

class MeasurementConverterPage extends StatefulWidget {
  const MeasurementConverterPage({super.key});

  @override
  State<MeasurementConverterPage> createState() => _MeasurementConverterPageState();
}

class _MeasurementConverterPageState extends State<MeasurementConverterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Volume
  final TextEditingController _volumeController = TextEditingController();
  String _fromVolumeUnit = 'cup';
  String _toVolumeUnit = 'ml';
  String _volumeResult = '';

  // Weight
  final TextEditingController _weightController = TextEditingController();
  String _fromWeightUnit = 'oz';
  String _toWeightUnit = 'g';
  String _weightResult = '';

  // Temperature
  final TextEditingController _tempController = TextEditingController();
  String _fromTempUnit = 'fahrenheit';
  String _toTempUnit = 'celsius';
  String _tempResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _volumeController.addListener(_convertVolume);
    _weightController.addListener(_convertWeight);
    _tempController.addListener(_convertTemperature);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _volumeController.dispose();
    _weightController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  void _convertVolume() {
    final input = _volumeController.text.trim();
    if (input.isEmpty) {
      setState(() => _volumeResult = '');
      return;
    }
    try {
      final amount = double.parse(input);
      final result = MeasurementConversion.convert(amount, _fromVolumeUnit, _toVolumeUnit);
      setState(() {
        _volumeResult = result == null ? 'Cannot convert' : _formatResult(result);
      });
    } catch (e) {
      setState(() => _volumeResult = 'Invalid input');
    }
  }

  void _convertWeight() {
    final input = _weightController.text.trim();
    if (input.isEmpty) {
      setState(() => _weightResult = '');
      return;
    }
    try {
      final amount = double.parse(input);
      final result = MeasurementConversion.convert(amount, _fromWeightUnit, _toWeightUnit);
      setState(() {
        _weightResult = result == null ? 'Cannot convert' : _formatResult(result);
      });
    } catch (e) {
      setState(() => _weightResult = 'Invalid input');
    }
  }

  void _convertTemperature() {
    final input = _tempController.text.trim();
    if (input.isEmpty) {
      setState(() => _tempResult = '');
      return;
    }
    try {
      final amount = double.parse(input);
      final result = MeasurementConversion.convert(amount, _fromTempUnit, _toTempUnit);
      setState(() {
        _tempResult = result == null ? 'Cannot convert' : _formatResult(result);
      });
    } catch (e) {
      setState(() => _tempResult = 'Invalid input');
    }
  }

  String _formatResult(double result) {
    return (result == result.roundToDouble())
        ? result.toInt().toString()
        : result.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Measurement Converter'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Volume', icon: Icon(Icons.local_drink, size: 20)),
            Tab(text: 'Weight', icon: Icon(Icons.scale, size: 20)),
            Tab(text: 'Temperature', icon: Icon(Icons.thermostat, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVolumeConverter(),
          _buildWeightConverter(),
          _buildTemperatureConverter(),
        ],
      ),
    );
  }

  Widget _buildVolumeConverter() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConverterCard(
            title: 'Volume Conversion',
            subtitle: 'Convert between different volume measurements',
            controller: _volumeController,
            fromUnit: _fromVolumeUnit,
            toUnit: _toVolumeUnit,
            result: _volumeResult,
            units: MeasurementConversion.getVolumeUnits(),
            onFromUnitChanged: (unit) {
              setState(() => _fromVolumeUnit = unit);
              _convertVolume();
            },
            onToUnitChanged: (unit) {
              setState(() => _toVolumeUnit = unit);
              _convertVolume();
            },
            inputHint: 'Enter volume amount',
          ),
          const SizedBox(height: 24),
          _buildQuickReference('Volume Quick Reference', [
            '1 cup = 240 ml = 16 tbsp',
            '1 tbsp = 15 ml = 3 tsp',
            '1 liter = 1000 ml = 4.2 cups (approx)',
            '1 fl oz = 30 ml = 2 tbsp',
            '1 pint = 473 ml = 2 cups',
            '1 quart = 946 ml = 4 cups',
          ]),
        ],
      ),
    );
  }

  Widget _buildWeightConverter() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConverterCard(
            title: 'Weight Conversion',
            subtitle: 'Convert between different weight measurements',
            controller: _weightController,
            fromUnit: _fromWeightUnit,
            toUnit: _toWeightUnit,
            result: _weightResult,
            units: MeasurementConversion.getWeightUnits(),
            onFromUnitChanged: (unit) {
              setState(() => _fromWeightUnit = unit);
              _convertWeight();
            },
            onToUnitChanged: (unit) {
              setState(() => _toWeightUnit = unit);
              _convertWeight();
            },
            inputHint: 'Enter weight amount',
          ),
          const SizedBox(height: 24),
          _buildQuickReference('Weight Quick Reference', [
            '1 lb = 453.6 g = 16 oz',
            '1 oz = 28.35 g',
            '1 kg = 1000 g = 2.2 lbs',
            '1 cup flour ≈ 125g',
            '1 cup sugar ≈ 200g',
            '1 cup butter ≈ 225g',
          ]),
        ],
      ),
    );
  }

  Widget _buildTemperatureConverter() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConverterCard(
            title: 'Temperature Conversion',
            subtitle: 'Convert between Celsius, Fahrenheit, and Kelvin',
            controller: _tempController,
            fromUnit: _fromTempUnit,
            toUnit: _toTempUnit,
            result: _tempResult,
            units: MeasurementConversion.getTemperatureUnits(),
            onFromUnitChanged: (unit) {
              setState(() => _fromTempUnit = unit);
              _convertTemperature();
            },
            onToUnitChanged: (unit) {
              setState(() => _toTempUnit = unit);
              _convertTemperature();
            },
            inputHint: 'Enter temperature',
          ),
          const SizedBox(height: 24),
          _buildQuickReference('Common Cooking Temperatures', [
            'Water freezes: 0°C = 32°F',
            'Water boils: 100°C = 212°F',
            'Low oven: 150°C = 300°F',
            'Medium oven: 180°C = 350°F',
            'High oven: 220°C = 425°F',
            'Very hot oven: 250°C = 480°F',
          ]),
        ],
      ),
    );
  }

  Widget _buildConverterCard({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String fromUnit,
    required String toUnit,
    required String result,
    required List<String> units,
    required Function(String) onFromUnitChanged,
    required Function(String) onToUnitChanged,
    required String inputHint,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // From input
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: inputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: fromUnit,
                  decoration: InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  items: units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) onFromUnitChanged(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Swap button
          Center(
            child: GestureDetector(
              onTap: () {
                final temp = fromUnit;
                onFromUnitChanged(toUnit);
                onToUnitChanged(temp);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_vert,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // To output
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    result.isEmpty ? '0' : result,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: result.isEmpty ? Colors.grey[500] : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: toUnit,
                  decoration: InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  items: units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) onToUnitChanged(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReference(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}