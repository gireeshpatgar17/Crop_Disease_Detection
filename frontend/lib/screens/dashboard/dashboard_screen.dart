import 'package:flutter/material.dart';

import '../../widgets/sensor_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Agriculture')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Dashboard',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Monitor your farm in real time',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Sensor cards
            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    title: 'Temperature',
                    value: '28°C',
                    icon: Icons.thermostat,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SensorCard(
                    title: 'Humidity',
                    value: '72%',
                    icon: Icons.water,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SensorCard(
                    title: 'Soil Moisture',
                    value: '64%',
                    icon: Icons.grass,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SensorCard(
                    title: 'Water Level',
                    value: '82%',
                    icon: Icons.water_drop,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Irrigation status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, size: 40, color: Colors.blue),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Irrigation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text('Pump is currently OFF'),
                        ],
                      ),
                    ),

                    Switch(value: false, onChanged: null),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Crop health
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.eco)),

                title: const Text(
                  'Crop Health',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: const Text('No disease detected'),

                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
