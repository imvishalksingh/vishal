import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/springy_scale_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _classController;
  late TextEditingController _goalController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?['full_name'] ?? '');
    _emailController = TextEditingController(text: user?['email'] ?? '');
    _classController = TextEditingController(text: user?['class'] ?? '');
    _goalController = TextEditingController(text: user?['learning_goal'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _classController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    final success = await context.read<AuthProvider>().updateProfile(
      fullName: _nameController.text.trim(),
      className: _classController.text.trim(),
      learningGoal: _goalController.text.trim(),
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildAvatarUpload(),
                      const SizedBox(height: 32),
                      GlassPanel(
                        padding: const EdgeInsets.all(24),
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'PERSONAL DETAILS',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 16),
                            _buildField('Full Name', _nameController, Icons.person_outline),
                            const SizedBox(height: 16),
                            _buildField('Academic Class', _classController, Icons.school_outlined),
                            const SizedBox(height: 16),
                            _buildField('Learning Goal', _goalController, Icons.star_border_rounded),
                            const SizedBox(height: 16),
                            _buildField('Email', _emailController, Icons.email_outlined, readOnly: true),
                            const SizedBox(height: 32),
                            SpringyScaleButton(
                              onTap: _isLoading ? () {} : _saveProfile,
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading 
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarUpload() {
    final user = context.read<AuthProvider>().user;
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 4),
              image: DecorationImage(
                image: NetworkImage(user?['avatar_url'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuCIZExKYngl5nKdaw5iKiY6aTCeNE-6XHL1h2U35H0GCNinInGAJ97pRhpCXCfZuSg5VhqlvLpjWL61hbBpJ8ZWzeX-vEM905vKmtxQXKwOiBzexSMi1_f1KrjNPKIrsI2q5i_aEZHdlwuCdbvTivHOiv3V3C3XFXHEvhCo2zUgPA73ZtqprRYBaICz4fM-sSvbS1u1djA1Nxtzt_bRvso8bE24Dn5MYEiO7K2UD8q2enFF7Nz4Ey5Pw6Pe7nJW_GdUMz7npeXHEp8'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar upload coming soon!')));
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.backgroundDark, width: 3),
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(
        fontWeight: FontWeight.w600, 
        fontSize: 15,
        color: readOnly ? Colors.grey.shade500 : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: readOnly ? Colors.grey.shade600 : AppTheme.primary),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}
