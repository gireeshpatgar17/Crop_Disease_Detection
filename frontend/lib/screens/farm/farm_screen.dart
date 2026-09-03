import 'package:flutter/material.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  // ==========================================================
  // DEMO FARM DATA
  // ==========================================================

  // Later these values will come from the database.

  String cropName = 'Paddy';
  String variety = 'BPT 5204';

  int cropAge = 68;
  String growthStage = 'Vegetative';

  // Overall crop health.
  double cropHealth = 87;

  // Soil data
  double soilMoisture = 49;
  double averageTemperature = 29.4;

  // ==========================================================
  // IRRIGATION DATA
  // ==========================================================

  int irrigationCount = 18;

  // Total time the crop has been irrigated.
  int irrigationDuration = 42;

  String lastIrrigation = 'Today, 7:30 AM';

  // ==========================================================
  // DISEASE DATA
  // ==========================================================

  int diseasesDetected = 1;
  int diseasesTreated = 1;

  String lastDisease = 'Leaf Blast';
  String diseaseStatus = 'Treated';

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> refreshFarmData() async {
    // Temporary delay.
    //
    // Later:
    //
    // GET /api/crop/summary
    // GET /api/irrigation/history
    // GET /api/disease/history

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {});
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F3),
        elevation: 0,

        title: const Text(
          'Farm Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: refreshFarmData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: refreshFarmData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // CROP OVERVIEW
              // ==================================================

              _buildCropOverview(),

              const SizedBox(height: 22),

              // ==================================================
              // CROP HEALTH
              // ==================================================
              const Text(
                'Crop Health',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildHealthCard(),

              const SizedBox(height: 22),

              // ==================================================
              // FIELD DATA
              // ==================================================
              const Text(
                'Field Overview',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildFieldOverview(),

              const SizedBox(height: 22),

              // ==================================================
              // IRRIGATION SUMMARY
              // ==================================================
              const Text(
                'Irrigation Summary',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildIrrigationSummary(),

              const SizedBox(height: 22),

              // ==================================================
              // DISEASE SUMMARY
              // ==================================================
              const Text(
                'Disease & Treatment',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildDiseaseSummary(),

              const SizedBox(height: 22),

              // ==================================================
              // RECENT ACTIVITY
              // ==================================================
              const Text(
                'Recent Farm Activity',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildActivityTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CROP OVERVIEW
  // ==========================================================

  Widget _buildCropOverview() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Colors.green.shade700, Colors.green.shade500],
        ),

        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: Colors.white.withValues(alpha: 0.18),
            ),

            child: const Icon(
              Icons.grass_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  cropName,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Variety: $variety',

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),

                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$cropAge days • $growthStage stage',

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),

                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEALTH CARD
  // ==========================================================

  Widget _buildHealthCard() {
    Color healthColor;

    if (cropHealth >= 80) {
      healthColor = Colors.green;
    } else if (cropHealth >= 60) {
      healthColor = Colors.orange;
    } else {
      healthColor = Colors.red;
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: healthColor.withValues(alpha: 0.12),
                ),

                child: Icon(
                  Icons.favorite_rounded,
                  color: healthColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Overall Crop Health',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      cropHealth >= 80
                          ? 'Healthy'
                          : cropHealth >= 60
                          ? 'Needs attention'
                          : 'At risk',

                      style: TextStyle(
                        fontSize: 12,
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${cropHealth.toStringAsFixed(0)}%',

                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: healthColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: cropHealth / 100,

              minHeight: 9,

              backgroundColor: Colors.grey.shade200,

              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),

          const SizedBox(height: 13),

          Text(
            'Health score is calculated from field '
            'conditions, irrigation activity and '
            'disease history.',

            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FIELD OVERVIEW
  // ==========================================================

  Widget _buildFieldOverview() {
    return Row(
      children: [
        Expanded(
          child: _dataCard(
            icon: Icons.water_drop_rounded,
            iconColor: Colors.blue,
            title: 'Soil Moisture',
            value: '${soilMoisture.toStringAsFixed(0)}%',
            subtitle: 'Current',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _dataCard(
            icon: Icons.thermostat_rounded,
            iconColor: Colors.orange,
            title: 'Avg. Temperature',
            value: '${averageTemperature.toStringAsFixed(1)}°C',
            subtitle: 'Recent average',
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // IRRIGATION SUMMARY
  // ==========================================================

  Widget _buildIrrigationSummary() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Row(
            children: [
              _summaryIcon(Icons.water_drop_rounded, Colors.blue),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Irrigation Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _miniStat(
                  '$irrigationCount',
                  'Irrigations',
                  Icons.water_rounded,
                ),
              ),

              Expanded(
                child: _miniStat(
                  '$irrigationDuration min',
                  'Irrigation time',
                  Icons.timer_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),

            decoration: BoxDecoration(
              color: Colors.blue.shade50,

              borderRadius: BorderRadius.circular(13),
            ),

            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: Colors.blue.shade700,
                ),

                const SizedBox(width: 8),

                Text(
                  'Last irrigation: $lastIrrigation',

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DISEASE SUMMARY
  // ==========================================================

  Widget _buildDiseaseSummary() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Row(
            children: [
              _summaryIcon(Icons.health_and_safety_rounded, Colors.green),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Disease History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              _statusBadge(
                diseasesDetected == 0 ? 'No issues' : 'Monitored',

                diseasesDetected == 0 ? Colors.green : Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _miniStat(
                  '$diseasesDetected',
                  'Detected',
                  Icons.search_rounded,
                ),
              ),

              Expanded(
                child: _miniStat(
                  '$diseasesTreated',
                  'Treated',
                  Icons.medical_services_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (diseasesDetected > 0)
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(13),

              decoration: BoxDecoration(
                color: Colors.orange.shade50,

                borderRadius: BorderRadius.circular(14),
              ),

              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          lastDisease,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Status: $diseaseStatus',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'No disease has been recorded.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // ACTIVITY TIMELINE
  // ==========================================================

  Widget _buildActivityTimeline() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          _activityItem(
            icon: Icons.water_drop_rounded,
            iconColor: Colors.blue,
            title: 'Irrigation completed',
            subtitle: 'Motor operated automatically',
            time: 'Today, 7:30 AM',
            isLast: false,
          ),

          _activityItem(
            icon: Icons.health_and_safety_rounded,
            iconColor: Colors.green,
            title: 'Disease treatment recorded',
            subtitle: '$lastDisease marked as treated',
            time: 'Yesterday, 5:20 PM',
            isLast: false,
          ),

          _activityItem(
            icon: Icons.eco_rounded,
            iconColor: Colors.green,
            title: 'Crop health updated',
            subtitle:
                'Health score: '
                '${cropHealth.toStringAsFixed(0)}%',
            time: 'Yesterday, 8:00 AM',
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DATA CARD
  // ==========================================================

  Widget _dataCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: iconColor.withValues(alpha: 0.12),
            ),

            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(height: 12),

          Text(
            title,

            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,

            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY ICON
  // ==========================================================

  Widget _summaryIcon(IconData icon, Color color) {
    return Container(
      width: 43,
      height: 43,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: color.withValues(alpha: 0.12),
      ),

      child: Icon(icon, color: color, size: 23),
    );
  }

  // ==========================================================
  // MINI STAT
  // ==========================================================

  Widget _miniStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 21, color: Colors.grey.shade600),

        const SizedBox(height: 6),

        Text(
          value,

          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 2),

        Text(
          label,

          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ==========================================================
  // ACTIVITY ITEM
  // ==========================================================

  Widget _activityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: iconColor.withValues(alpha: 0.12),
              ),

              child: Icon(icon, color: iconColor, size: 21),
            ),

            if (!isLast)
              Container(width: 2, height: 42, color: Colors.grey.shade200),
          ],
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,

                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 3),

                Text(
                  time,

                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STATUS BADGE
  // ==========================================================

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        text,

        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}
