import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/springy_scale_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late TextEditingController _nameController;
  final TextEditingController _customClassController = TextEditingController();
  final TextEditingController _customGoalController = TextEditingController();
  
  String? _selectedClass;
  String? _selectedGoal;
  bool _isLoading = false;

  final List<String> _classOptions = ['Class 10th', 'Class 12th', 'Other'];
  final List<Map<String, dynamic>> _goalOptions = [
    {'title': 'Board Exams', 'icon': Icons.menu_book_rounded},
    {'title': 'Spoken English', 'icon': Icons.record_voice_over_rounded},
    {'title': 'Competitive Exams', 'icon': Icons.campaign_rounded},
    {'title': 'General English', 'icon': Icons.auto_awesome_rounded},
    {'title': 'Other', 'icon': Icons.edit_note_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?['full_name'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customClassController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    if (_selectedClass == null) {
      _showError('Please select your academic class');
      return;
    }

    final finalClass = _selectedClass == 'Other' 
        ? _customClassController.text.trim() 
        : _selectedClass;

    if (finalClass == null || finalClass.isEmpty) {
      _showError('Please specify your class');
      return;
    }

    if (_selectedGoal == null) {
      _showError('Please select a learning goal');
      return;
    }

    final finalGoal = _selectedGoal == 'Other' 
        ? _customGoalController.text.trim() 
        : _selectedGoal;

    if (finalGoal == null || finalGoal.isEmpty) {
      _showError('Please specify your learning goal');
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<AuthProvider>().updateProfile(
      fullName: name,
      className: finalClass,
      learningGoal: finalGoal,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome onboard! Your profile is set.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.accent2,
          ),
        );
        Navigator.pushReplacementNamed(context, '/');
      } else {
        _showError('Failed to save details. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accent3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Welcome Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Setup Your Journey',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.backgroundDark,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us customize your learning materials to best fit your requirements.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Onboarding Glass Card
                  GlassPanel(
                    padding: const EdgeInsets.all(24),
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 1: Full Name
                        _buildSectionHeader('1. YOUR FULL NAME', Icons.person_outline_rounded),
                        const SizedBox(height: 12),
                        _buildTextField('Full Name', _nameController, Icons.badge_outlined),
                        const SizedBox(height: 28),

                        // Section 2: Academic Class
                        _buildSectionHeader('2. ACADEMIC CLASS', Icons.school_outlined),
                        const SizedBox(height: 12),
                        _buildClassSelector(),
                        if (_selectedClass == 'Other') ...[
                          const SizedBox(height: 12),
                          _buildTextField('Enter your Class (e.g. B.A., Class 9th)', _customClassController, Icons.edit_calendar_outlined),
                        ],
                        const SizedBox(height: 28),

                        // Section 3: Learning Goal
                        _buildSectionHeader('3. CHOOSE LEARNING GOAL', Icons.star_border_rounded),
                        const SizedBox(height: 12),
                        _buildGoalSelector(),
                        if (_selectedGoal == 'Other') ...[
                          const SizedBox(height: 12),
                          _buildTextField('Write your learning goal...', _customGoalController, Icons.edit_note_outlined),
                        ],
                        const SizedBox(height: 36),

                        // Submit Button
                        SpringyScaleButton(
                          onTap: _isLoading ? () {} : _submitOnboarding,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Let\'s Start Learn!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: AppTheme.primary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildClassSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: _classOptions.map((option) {
        final isSelected = _selectedClass == option;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SpringyScaleButton(
              onTap: () {
                setState(() {
                  _selectedClass = option;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primary 
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _goalOptions.map((goal) {
        final title = goal['title'] as String;
        final icon = goal['icon'] as IconData;
        final isSelected = _selectedGoal == title;
        
        return SpringyScaleButton(
          onTap: () {
            setState(() {
              _selectedGoal = title;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.15)
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppTheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppTheme.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
