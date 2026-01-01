import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/frost_provider.dart';
import '../providers/location_provider.dart';
import '../models/frost_dates.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final frostDates = ref.watch(frostDatesProvider);
    final autoZone = ref.watch(autoDetectedZoneProvider);
    final allZones = ref.watch(allZonesProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(
          title: Text('Settings'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location section
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(location.name),
                    subtitle: Text(
                      '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () async {
                        final success = await ref.read(locationProvider.notifier).updateFromGPS();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Location updated'
                                    : 'Could not get location',
                              ),
                            ),
                          );
                        }
                      },
                      tooltip: 'Update from GPS',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Frost dates section
                Text(
                  'Frost Dates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.thermostat),
                        title: const Text('Detected Zone'),
                        subtitle: Text('USDA Zone $autoZone'),
                      ),
                      frostDates.when(
                        data: (dates) {
                          if (dates == null) {
                            return const ListTile(
                              title: Text('No frost dates set'),
                              subtitle: Text('Select a zone below'),
                            );
                          }
                          return Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.wb_sunny),
                                title: const Text('Last Spring Frost'),
                                subtitle: Text(_formatDate(dates.lastSpringFrost)),
                              ),
                              ListTile(
                                leading: const Icon(Icons.ac_unit),
                                title: const Text('First Fall Frost'),
                                subtitle: Text(_formatDate(dates.firstFallFrost)),
                              ),
                              ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: const Text('Growing Season'),
                                subtitle: Text('${dates.growingSeasonDays} days'),
                              ),
                              if (dates.isManuallySet)
                                const ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Custom dates'),
                                  dense: true,
                                ),
                            ],
                          );
                        },
                        loading: () => const ListTile(
                          title: Text('Loading...'),
                        ),
                        error: (e, _) => ListTile(
                          title: const Text('Error'),
                          subtitle: Text(e.toString()),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Change Zone'),
                        trailing: DropdownButton<String>(
                          value: autoZone,
                          items: allZones.map((zone) {
                            return DropdownMenuItem(
                              value: zone,
                              child: Text('Zone $zone'),
                            );
                          }).toList(),
                          onChanged: (zone) {
                            if (zone != null) {
                              ref.read(frostDatesProvider.notifier).setFromZone(zone);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Auto-detect from GPS'),
                        onTap: () async {
                          await ref.read(frostDatesProvider.notifier).autoDetect();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Frost dates updated from location'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // About section
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.eco),
                        title: Text('Cultivar'),
                        subtitle: Text('Garden planning made simple'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Version'),
                        subtitle: const Text('1.0.0'),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Cultivar',
                            applicationVersion: '1.0.0',
                            applicationLegalese: 'A comprehensive garden planning app',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
