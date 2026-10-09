import 'package:flutter/material.dart';
import '../../core/services/feedback_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/chunky_button.dart';
import '../../core/widgets/kalikoot_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  late bool _sound;
  late bool _haptic;

  @override
  void initState() {
    super.initState();
    _sound = _storage.soundEnabled;
    _haptic = _storage.hapticEnabled;
  }

  void _toggleSound(bool val) async {
    setState(() => _sound = val);
    await _storage.setSoundEnabled(val);
    FeedbackService().playTap();
  }

  void _toggleHaptic(bool val) async {
    setState(() => _haptic = val);
    await _storage.setHapticEnabled(val);
    FeedbackService().triggerHapticMedium();
  }

  void _confirmResetStats() {
    FeedbackService().playTap();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.primaryNavy, width: 3),
        ),
        title: const Text('Reset All Records?', style: AppTypography.titleLarge),
        content: const Text(
          'This will permanently reset your personal bests, high scores, and match statistics.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          ChunkyButton(
            label: 'RESET',
            backgroundColor: AppColors.coral,
            height: 44,
            onPressed: () async {
              await _storage.resetAllStats();
              if (mounted) setState(() {});
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All local game records have been reset.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uriyadiBest = _storage.getHighScore('uriyadi');
    final goliBest = _storage.getHighScore('goli_kali');
    final totalMatches = _storage.getStat('matches_played');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const KaliKootHeader(
              title: 'SETTINGS',
              showBack: true,
              showSettings: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Preferences Section
                  _buildSectionHeader('AUDIO & HAPTICS'),
                  _buildToggleCard(
                    title: 'Sound Effects',
                    subtitle: 'Play audio cues for hits, misses & actions',
                    value: _sound,
                    icon: Icons.volume_up_rounded,
                    onChanged: _toggleSound,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Haptic Feedback',
                    subtitle: 'Vibrate on taps and gameplay impacts',
                    value: _haptic,
                    icon: Icons.vibration_rounded,
                    onChanged: _toggleHaptic,
                  ),

                  const SizedBox(height: 24),

                  // Statistics Section
                  _buildSectionHeader('MATCH RECORDS'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryNavy, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryNavy,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('Uriyadi High Score', '$uriyadiBest pts'),
                        const Divider(color: AppColors.trackInactive),
                        _buildStatRow('Goli Kali High Score', '$goliBest pts'),
                        const Divider(color: AppColors.trackInactive),
                        _buildStatRow('Total Matches Played', '$totalMatches'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ChunkyButton(
                            label: 'RESET LOCAL RECORDS',
                            backgroundColor: AppColors.white,
                            textColor: AppColors.coral,
                            borderColor: AppColors.coral,
                            height: 46,
                            onPressed: _confirmResetStats,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader('ABOUT KALIKOOT'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryNavy, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryNavy,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KaliKoot Mobile Game Collection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Inspired by Kerala’s vibrant village culture, festival games, and playful rivalries. 100% offline, zero ads, no sign-ups.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryText,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Version',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mutedText,
                              ),
                            ),
                            Text(
                              '1.0.0 (Release)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.mutedText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryNavy, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primaryNavy,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryNavy, width: 2),
            ),
            child: Icon(icon, color: AppColors.primaryNavy, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNavy,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.green,
            activeTrackColor: AppColors.primaryNavy,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
