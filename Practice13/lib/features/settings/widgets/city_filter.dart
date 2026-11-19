import 'package:flutter/material.dart';

class CityFilter extends StatelessWidget {
  const CityFilter({
    required this.cities,
    required this.selectedCity,
    required this.onChanged,
    super.key,
  });

  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: DropdownButtonFormField<String>(
      value: selectedCity ?? '',
      decoration: const InputDecoration(labelText: 'City filter'),
      items: [
        const DropdownMenuItem(value: '', child: Text('All cities')),
        for (final city in cities)
          DropdownMenuItem(value: city, child: Text(city)),
      ],
      onChanged: (city) => onChanged(city == '' ? null : city),
    ),
  );
}
