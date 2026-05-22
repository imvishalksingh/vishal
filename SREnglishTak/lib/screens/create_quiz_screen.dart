import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/book.dart';
import '../models/quiz.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class CreateQuizScreen extends StatefulWidget {
  final Book? selectedBook;
  final Quiz? existingQuiz;

  const CreateQuizScreen({super.key, this.selectedBook, this.existingQuiz});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _quizTitleController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingQuiz != null) {
      _quizTitleController.text = widget.existingQuiz!.title;
      if (widget.existingQuiz!.questions != null) {
        for (var q in widget.existingQuiz!.questions!) {
          _questions.add({
            'question_text': q.questionText,
            'correct_option_index': q.correctOptionIndex,
            'options': q.options.map((o) => {'label': o.label, 'text': o.text}).toList(),
            'explanation': q.explanation,
          });
        }
      }
    }
  }

  void _saveQuiz() async {
    if (_quizTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a quiz series title')));
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must add at least one question')));
      return;
    }

    try {
      final quizData = {
        if (widget.selectedBook != null) 'book_id': widget.selectedBook!.id,
        'title': _quizTitleController.text,
        'type': widget.existingQuiz?.type ?? (widget.selectedBook == null ? 'general' : 'book'),
        'questions': _questions,
      };

      if (widget.existingQuiz != null) {
        await ApiService.updateQuiz(widget.existingQuiz!.id, quizData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz updated successfully!')));
      } else {
        await ApiService.createQuiz(quizData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz created successfully!')));
      }
      
      Navigator.pop(context, true); // Pop back to admin panel
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving quiz: $e')));
    }
  }

  void _openQuestionEditor() async {
    final newQuestion = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _QuestionEditorModal(),
    );

    if (newQuestion != null) {
      setState(() {
        _questions.add(newQuestion);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.selectedBook == null ? 'General Quiz' : 'Quiz for ${widget.selectedBook!.title}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _saveQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildQuizDetails(),
              const SizedBox(height: 16),
              _buildQuestionsHeader(),
              Expanded(
                child: _questions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _questions.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final q = _questions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GlassPanel(
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppTheme.primary,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          q['question_text'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${(q['options'] as List).length} options configured",
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() => _questions.removeAt(index));
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassPanel(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QUIZ SERIES DETAILS',
              style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quizTitleController,
              decoration: InputDecoration(
                labelText: 'Quiz Title',
                hintText: 'e.g. Chapter 1 Vocabulary',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.05) 
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'QUESTIONS (${_questions.length})',
            style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          InkWell(
            onTap: _openQuestionEditor,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.add, color: AppTheme.primary, size: 16),
                  SizedBox(width: 4),
                  Text('Add New', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.quiz_outlined, color: AppTheme.primary, size: 48),
          ),
          const SizedBox(height: 16),
          const Text('No Questions Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Tap "Add New" to insert the first question\ninto this quiz series.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _QuestionEditorModal extends StatefulWidget {
  const _QuestionEditorModal();

  @override
  State<_QuestionEditorModal> createState() => _QuestionEditorModalState();
}

class _QuestionEditorModalState extends State<_QuestionEditorModal> {
  String text = "";
  int correctIdx = 0;
  String explanation = "";
  List<String> options = ["", "", "", ""];

  @override
  Widget build(BuildContext context) {
    // A highly polished bottom sheet
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Create Question', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionLabel('QUESTION PROMPT'),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 3,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: _inputDecoration('Enter the question text here...'),
                  onChanged: (val) => text = val,
                ),
                const SizedBox(height: 32),
                _buildSectionLabel('ANSWER OPTIONS (Tap circle to mark correct)'),
                const SizedBox(height: 12),
                ...List.generate(4, (idx) {
                  final isCorrect = correctIdx == idx;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => correctIdx = idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCorrect ? AppTheme.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200),
                              shape: BoxShape.circle,
                              border: Border.all(color: isCorrect ? AppTheme.primary : Colors.transparent),
                            ),
                            child: isCorrect 
                                ? const Icon(Icons.check, size: 16, color: Colors.white) 
                                : Center(child: Text(String.fromCharCode(65 + idx), style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: _inputDecoration('Option ${String.fromCharCode(65 + idx)}'),
                            onChanged: (val) => options[idx] = val,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
                _buildSectionLabel('LEARNING EXPLANATION (Optional)'),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 2,
                  decoration: _inputDecoration('Why is this rule or answer correct?'),
                  onChanged: (val) => explanation = val,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (text.isEmpty || options.any((o) => o.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out the question and all 4 options.')));
                        return;
                      }
                      Navigator.pop(context, {
                        'question_text': text,
                        'correct_option_index': correctIdx,
                        'options': options.asMap().entries.map((e) => {'label': String.fromCharCode(65 + e.key), 'text': e.value}).toList(),
                        'explanation': explanation,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Add to Quiz Suite', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
