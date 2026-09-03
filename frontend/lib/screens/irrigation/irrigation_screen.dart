import 'package:flutter/material.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  // ==========================================================
  // DEMO SENSOR DATA
  // ==========================================================

  // Temporary values.
  // Later these will come from the ESP32/backend.

  double soilMoisture = 49.0;
  double temperature = 30.5;
  double humidity = 84.9;

  bool waterAvailable = true;
  bool rainDetected = false;

  // ==========================================================
  // IRRIGATION STATE
  // ==========================================================

  // false = AUTO
  // true  = MANUAL
  bool manualMode = false;

  // Motor state
  bool motorOn = false;

  // Rain lockout
  bool rainLockout = false;

  // Demo lockout time
  int lockoutSeconds = 0;

  // ==========================================================
  // MANUAL MODE TOGGLE
  // ==========================================================

  void changeManualMode(bool value) {
    setState(() {
      manualMode = value;

      // Motor always starts OFF when changing mode.
      motorOn = false;
    });
  }

  // ==========================================================
  // MOTOR TOGGLE
  // ==========================================================

  void changeMotorState(bool value) {
    // Motor can only be controlled in manual mode.
    if (!manualMode) {
      return;
    }

    // Rain protection
    if (rainDetected || rainLockout) {
      return;
    }

    // Water protection
    if (!waterAvailable) {
      return;
    }

    setState(() {
      motorOn = value;
    });
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> refreshData() async {
    // Temporary delay.
    //
    // Later:
    // GET /api/sensors/latest

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
          'Irrigation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: refreshData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // CURRENT STATUS
              // ==================================================

              _buildPumpStatus(),

              const SizedBox(height: 24),

              // ==================================================
              // CONTROLS
              // ==================================================
              const Text(
                'Irrigation Controls',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildControlCard(),

              const SizedBox(height: 24),

              // ==================================================
              // FIELD CONDITIONS
              // ==================================================
              const Text(
                'Field Conditions',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildSensorGrid(),

              const SizedBox(height: 24),

              // ==================================================
              // SAFETY & ENVIRONMENT
              // ==================================================
              const Text(
                'Safety & Environment',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Rain status
              _buildRainStatus(),

              const SizedBox(height: 10),

              // Rain lockout
              _buildLockoutStatus(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PUMP STATUS
  // ==========================================================

  Widget _buildPumpStatus() {
    final Color statusColor = motorOn ? Colors.blue : Colors.grey.shade600;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: motorOn
              ? [Colors.blue.shade50, Colors.white]
              : [Colors.white, Colors.grey.shade50],
        ),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: motorOn ? Colors.blue.shade100 : Colors.grey.shade200,
                ),

                child: Icon(
                  Icons.water_drop_rounded,
                  size: 31,
                  color: statusColor,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Motor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      motorOn ? 'Running' : 'Stopped',

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(
                motorOn ? 'ON' : 'OFF',

                motorOn ? Colors.blue : Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),

            decoration: BoxDecoration(
              color: Colors.grey.shade100,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Row(
              children: [
                Icon(
                  manualMode
                      ? Icons.touch_app_rounded
                      : Icons.auto_awesome_rounded,

                  size: 19,

                  color: manualMode
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                ),

                const SizedBox(width: 8),

                Text(
                  manualMode
                      ? 'Manual control active'
                      : 'Automatic irrigation active',

                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
  // CONTROL CARD
  // ==========================================================

  Widget _buildControlCard() {
    final bool motorControlAvailable =
        manualMode && waterAvailable && !rainDetected && !rainLockout;

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          // --------------------------------------------------
          // MANUAL MODE
          // --------------------------------------------------

          Padding(
            padding: const EdgeInsets.fromLTRB(17, 17, 12, 15),

            child: Row(
              children: [
                _controlIcon(Icons.tune_rounded, Colors.orange),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Manual Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        manualMode
                            ? 'You control the motor'
                            : 'ESP32 controls irrigation',

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Switch(value: manualMode, onChanged: changeManualMode),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // --------------------------------------------------
          // MOTOR
          // --------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 15, 12, 17),

            child: Row(
              children: [
                _controlIcon(
                  Icons.power_settings_new_rounded,

                  motorControlAvailable ? Colors.blue : Colors.grey,
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Motor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        !manualMode
                            ? 'Enable Manual Mode first'
                            : !waterAvailable
                            ? 'Water unavailable'
                            : rainDetected || rainLockout
                            ? 'Blocked by rain protection'
                            : motorOn
                            ? 'Motor is running'
                            : 'Motor is stopped',

                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Switch(
                  value: motorOn,

                  onChanged: motorControlAvailable ? changeMotorState : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SENSOR GRID
  // ==========================================================

  Widget _buildSensorGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _sensorCard(
                icon: Icons.grass_rounded,
                iconColor: Colors.green,
                title: 'Soil Moisture',

                value: '${soilMoisture.toStringAsFixed(0)}%',

                subtitle: soilMoisture < 30
                    ? 'Dry'
                    : soilMoisture < 60
                    ? 'Moderate'
                    : 'Moist',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _sensorCard(
                icon: Icons.thermostat_rounded,
                iconColor: Colors.orange,
                title: 'Temperature',

                value: '${temperature.toStringAsFixed(1)}°C',

                subtitle: 'Current',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _sensorCard(
                icon: Icons.water_rounded,
                iconColor: Colors.indigo,
                title: 'Humidity',

                value: '${humidity.toStringAsFixed(1)}%',

                subtitle: 'Air humidity',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _sensorCard(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blue,
                title: 'Water Supply',

                value: waterAvailable ? 'Available' : 'Unavailable',

                subtitle: 'Tank status',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // SENSOR CARD
  // ==========================================================

  Widget _sensorCard({
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
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: iconColor.withValues(alpha: 0.12),
            ),

            child: Icon(icon, color: iconColor, size: 23),
          ),

          const SizedBox(height: 14),

          Text(
            title,

            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,

            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RAIN STATUS
  // ==========================================================

  Widget _buildRainStatus() {
    return _environmentCard(
      icon: rainDetected ? Icons.umbrella_rounded : Icons.wb_sunny_rounded,

      iconColor: rainDetected ? Colors.blue : Colors.amber.shade700,

      title: 'Rain Status',

      value: rainDetected ? 'Rain detected' : 'No rain',

      description: rainDetected
          ? 'Irrigation is temporarily blocked'
          : 'Weather conditions are clear',
    );
  }

  // ==========================================================
  // RAIN LOCKOUT
  // ==========================================================

  Widget _buildLockoutStatus() {
    if (!rainLockout) {
      return _environmentCard(
        icon: Icons.lock_open_rounded,

        iconColor: Colors.green,

        title: 'Rain Lockout',

        value: 'Inactive',

        description: 'No rain lockout is active',
      );
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.orange.shade50,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.orange.shade200),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: Colors.orange.shade100,
            ),

            child: Icon(
              Icons.lock_clock_rounded,
              color: Colors.orange.shade800,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Rain Lockout',

                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  'Active • '
                  '${_formatDuration(lockoutSeconds)} '
                  'remaining',

                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ENVIRONMENT CARD
  // ==========================================================

  Widget _environmentCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: iconColor.withValues(alpha: 0.12),
            ),

            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  description,

                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          Icon(Icons.check_circle_rounded, color: iconColor, size: 21),
        ],
      ),
    );
  }

  // ==========================================================
  // CONTROL ICON
  // ==========================================================

  Widget _controlIcon(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: color.withValues(alpha: 0.12),
      ),

      child: Icon(icon, color: color, size: 22),
    );
  }

  // ==========================================================
  // STATUS BADGE
  // ==========================================================

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        text,

        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  // ==========================================================
  // FORMAT LOCKOUT TIME
  // ==========================================================

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;

    final int remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
