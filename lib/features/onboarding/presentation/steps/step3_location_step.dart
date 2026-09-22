import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/location_data.dart';

class Step3LocationStep extends StatefulWidget {
  final String selectedCountry;
  final String selectedCity;
  final ValueChanged<CountryData> onSelectCountry;
  final ValueChanged<String> onSelectCity;
  final VoidCallback onContinue;

  const Step3LocationStep({
    super.key,
    required this.selectedCountry,
    required this.selectedCity,
    required this.onSelectCountry,
    required this.onSelectCity,
    required this.onContinue,
  });

  @override
  State<Step3LocationStep> createState() => _Step3LocationStepState();
}

class _Step3LocationStepState extends State<Step3LocationStep> {
  late TextEditingController _customCityController;

  @override
  void initState() {
    super.initState();
    _customCityController = TextEditingController(text: widget.selectedCity);
  }

  @override
  void didUpdateWidget(covariant Step3LocationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCity != widget.selectedCity &&
        _customCityController.text != widget.selectedCity) {
      _customCityController.text = widget.selectedCity;
    }
  }

  @override
  void dispose() {
    _customCityController.dispose();
    super.dispose();
  }

  CountryData get _currentCountry {
    return LocationRepository.countries.firstWhere(
      (c) => c.name.toLowerCase() == widget.selectedCountry.toLowerCase(),
      orElse: () => LocationRepository.defaultCountry,
    );
  }

  void _showCitySearchBottomSheet(BuildContext context, CountryData country) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCities = country.cities
                .where((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cities in ${country.flag} ${country.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredCities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_off_outlined,
                                    size: 48, color: AppColors.textSecondary),
                                const SizedBox(height: 8),
                                Text(
                                  'No city found matching "$searchQuery"',
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    widget.onSelectCity(searchQuery);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Use "$searchQuery" as Custom City'),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredCities.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final city = filteredCities[index];
                              final isSelected = widget.selectedCity.toLowerCase() ==
                                  city.toLowerCase();
                              return ListTile(
                                leading: Icon(
                                  Icons.location_city,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.textSecondary,
                                ),
                                title: Text(
                                  city,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: AppColors.primaryGreen)
                                    : null,
                                onTap: () {
                                  widget.onSelectCity(city);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCountry = _currentCountry;
    final topCities = currentCountry.cities.take(8).toList();
    final bool isSelectedCityInList = currentCountry.cities.any(
        (c) => c.toLowerCase() == widget.selectedCity.toLowerCase());

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WHERE'S YOUR KITCHEN?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Used for exact Suhoor/Iftar prayer clocks and local market grocery prices.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Country Selection Dropdown Header
                  const Text(
                    'SELECT YOUR COUNTRY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Country Dropdown Form Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CountryData>(
                        value: currentCountry,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_circle,
                            color: AppColors.primaryGreen),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        items: LocationRepository.countries.map((country) {
                          return DropdownMenuItem<CountryData>(
                            value: country,
                            child: Row(
                              children: [
                                Text(country.flag, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${country.name} (${country.marketLabel})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newCountry) {
                          if (newCountry != null) {
                            widget.onSelectCountry(newCountry);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SELECT YOUR CITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showCitySearchBottomSheet(context, currentCountry),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 14, color: AppColors.primaryGreen),
                              const SizedBox(width: 4),
                              Text(
                                'Search All (${currentCountry.cities.length} cities)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Complete Cities Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: isSelectedCityInList
                            ? currentCountry.cities.firstWhere((c) =>
                                c.toLowerCase() == widget.selectedCity.toLowerCase())
                            : null,
                        hint: Text(
                          widget.selectedCity.isNotEmpty
                              ? widget.selectedCity
                              : 'Select from complete cities list...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.unfold_more, color: AppColors.medicalBlue),
                        items: currentCountry.cities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newCity) {
                          if (newCity != null) {
                            widget.onSelectCity(newCity);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Quick Top City Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topCities.map((city) {
                      final bool isSelected =
                          widget.selectedCity.toLowerCase() == city.toLowerCase();
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) widget.onSelectCity(city);
                        },
                        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primaryGreen : AppColors.medicalBlue,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryGreen : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Custom Input fallback
                  TextField(
                    controller: _customCityController,
                    onChanged: widget.onSelectCity,
                    decoration: const InputDecoration(
                      hintText: 'Or type custom city...',
                      prefixIcon: Icon(Icons.location_city, color: AppColors.border),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CONTINUE'),
            ),
          ),
        ],
      ),
    );
  }
}
