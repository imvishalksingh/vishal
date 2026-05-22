import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class AdminChallengeForm extends StatefulWidget {
  final Challenge? existingChallenge;
  const AdminChallengeForm({super.key, this.existingChallenge});

  @override
  State<AdminChallengeForm> createState() => _AdminChallengeFormState();
}

class _AdminChallengeFormState extends State<AdminChallengeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _prizeCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _durationCtrl;
  
  List<ChallengeQuestion> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existingChallenge;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _prizeCtrl = TextEditingController(text: c?.prizeText ?? '');
    _imageCtrl = TextEditingController(text: c?.imageUrl ?? '');
    _durationCtrl = TextEditingController(text: (c?.durationMinutes ?? 5).toString());
    _questions = c != null ? List.from(c.questions) : [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _prizeCtrl.dispose();
    _imageCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _addQuestion() async {
    final newQ = await showDialog<ChallengeQuestion>(
      context: context,
      builder: (_) => const _QuestionEditDialog(),
    );
    if (newQ != null) {
      setState(() => _questions.add(newQ));
    }
  }

  void _editQuestion(int index) async {
    final q = _questions[index];
    final updated = await showDialog<ChallengeQuestion>(
      context: context,
      builder: (_) => _QuestionEditDialog(question: q),
    );
    if (updated != null) {
      setState(() => _questions[index] = updated);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final challenge = Challenge(
        id: widget.existingChallenge?.id ?? '',
        name: _nameCtrl.text,
        description: _descCtrl.text,
        prizeText: _prizeCtrl.text,
        imageUrl: _imageCtrl.text.isNotEmpty ? _imageCtrl.text : null,
        durationMinutes: int.tryParse(_durationCtrl.text) ?? 5,
        questions: _questions,
        startTime: widget.existingChallenge?.startTime ?? DateTime.now().toUtc(),
        endTime: widget.existingChallenge?.endTime ?? DateTime.now().toUtc().add(const Duration(days: 7)), 
      );
      
      if (widget.existingChallenge != null) {
        await ApiService.updateChallenge(challenge.id, challenge);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge updated!')));
      } else {
        await ApiService.createChallenge(challenge);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge created!')));
      }
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingChallenge != null;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Arena Challenge' : 'Create Arena Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.rocket_launch_rounded, size: 18),
              label: Text(isEdit ? 'Update' : 'Launch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
      body: PremiumBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionTitle('CHALLENGE IDENTITY', Icons.badge_outlined),
              const SizedBox(height: 12),
              GlassPanel(
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    _buildPremiumField('Challenge Name', _nameCtrl, 'e.g. Weekly Grammar Blitz'),
                    const SizedBox(height: 16),
                    _buildPremiumField('Short Description', _descCtrl, 'Quick overview...', maxLines: 2),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildPremiumField('Duration', _durationCtrl, 'Mins', type: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPremiumField('Prize', _prizeCtrl, 'e.g. Gold Badge')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumField('Thumbnail URL', _imageCtrl, 'https://...'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('ARENA QUESTIONS (${_questions.length})', Icons.quiz_outlined),
                  TextButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Add New'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_questions.isEmpty)
                _buildEmptyQuestionsState()
              else
                ..._questions.asMap().entries.map((entry) => _buildQuestionCard(entry.key, entry.value)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 14),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildPremiumField(String label, TextEditingController controller, String? hint, {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: type,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.01),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildEmptyQuestionsState() {
    return GlassPanel(
      padding: const EdgeInsets.all(40),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.grey.withOpacity(0.4), size: 48),
          const SizedBox(height: 16),
          const Text('No Questions Added', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Tap "Add New" to build your arena questions.', style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, ChallengeQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    q.questionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.grey),
                  onPressed: () => _editQuestion(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  onPressed: () => setState(() => _questions.removeAt(index)),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: q.options.asMap().entries.map((e) {
                final isCorrect = e.key == q.correctOptionIndex;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.transparent),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                      color: isCorrect ? Colors.green : Colors.grey.shade600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionEditDialog extends StatefulWidget {
  final ChallengeQuestion? question;
  const _QuestionEditDialog({this.question});

  @override
  State<_QuestionEditDialog> createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<_QuestionEditDialog> {
  late TextEditingController _qCtrl;
  late TextEditingController _cCtrl;
  late List<TextEditingController> _optCtrls;
  late int _correctIndex;

  @override
  void initState() {
    super.initState();
    _qCtrl = TextEditingController(text: widget.question?.questionText ?? '');
    _cCtrl = TextEditingController(text: widget.question?.category ?? 'General');
    _optCtrls = List.generate(4, (i) => TextEditingController(text: widget.question?.options[i] ?? ''));
    _correctIndex = widget.question?.correctOptionIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.question == null ? 'Draft New Question' : 'Refine Question',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),
              _buildField('Category', _cCtrl),
              const SizedBox(height: 16),
              _buildField('Question Text', _qCtrl, maxLines: 3),
              const SizedBox(height: 24),
              const Text('Options & Correct Answer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              ...List.generate(4, (i) {
                final isSelected = _correctIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _correctIndex,
                        activeColor: AppTheme.primary,
                        onChanged: (v) => setState(() => _correctIndex = v!),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _optCtrls[i],
                          decoration: InputDecoration(
                            hintText: 'Option ${i + 1}',
                            filled: true,
                            fillColor: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.black.withOpacity(0.01),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_qCtrl.text.isEmpty || _optCtrls.any((c) => c.text.isEmpty)) return;
                        Navigator.pop(
                          context,
                          ChallengeQuestion(
                            id: widget.question?.id ?? '',
                            category: _cCtrl.text,
                            questionText: _qCtrl.text,
                            options: _optCtrls.map((c) => c.text).toList(),
                            correctOptionIndex: _correctIndex,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Commit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: Colors.black.withOpacity(0.01),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
