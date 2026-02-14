import 'package:flutter/material.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/themes/font_weight_helper.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/modern_loading_indicator.dart';
import '../../data/models/question.dart';
import '../../data/models/subject.dart';
import '../../data/services/question_service.dart';

class EditQuestionBottomSheet extends StatefulWidget {
  final Question question;
  final VoidCallback? onQuestionUpdated;

  const EditQuestionBottomSheet({
    super.key,
    required this.question,
    this.onQuestionUpdated,
  });

  @override
  State<EditQuestionBottomSheet> createState() =>
      _EditQuestionBottomSheetState();
}

class _EditQuestionBottomSheetState extends State<EditQuestionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Subject>? _subjects;
  Subject? _selectedSubject;
  bool _isLoadingSubjects = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.question.title;
    _descriptionController.text = widget.question.description;
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final questionService = sl<QuestionService>();
      final subjects = await questionService.getSubjects();

      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoadingSubjects = false;

          // Find and select current subject
          _selectedSubject = subjects.firstWhere(
            (s) => s.id == widget.question.subjectId,
            orElse: () => subjects.first,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSubjects = false;
        });
        _showError('فشل في تحميل المواد الدراسية');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: context.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'تعديل السؤال',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeightHelper.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: _isLoadingSubjects
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: ModernLoadingIndicator(
                      message: 'جاري التحميل...',
                      type: LoadingType.pulse,
                    ),
                  )
                : _buildForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'عنوان السؤال',
              hintText: 'أدخل عنوان السؤال',
              prefixIcon: const Icon(Icons.title_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال عنوان السؤال';
              }
              if (value.trim().length < 10) {
                return 'العنوان يجب أن يكون 10 أحرف على الأقل';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'تفاصيل السؤال',
              hintText: 'اشرح سؤالك بالتفصيل',
              prefixIcon: const Icon(Icons.description_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال تفاصيل السؤال';
              }
              if (value.trim().length < 20) {
                return 'التفاصيل يجب أن تكون 20 حرف على الأقل';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Subject Dropdown
          if (_subjects != null && _subjects!.isNotEmpty)
            DropdownButtonFormField<Subject>(
              value: _selectedSubject,
              decoration: InputDecoration(
                labelText: 'المادة الدراسية',
                prefixIcon: const Icon(Icons.book_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _subjects!.map((subject) {
                return DropdownMenuItem<Subject>(
                  value: subject,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'الرجاء اختيار المادة الدراسية';
                }
                return null;
              },
            ),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'حفظ التعديلات',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeightHelper.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final questionService = sl<QuestionService>();

      await questionService.updateQuestion(
        id: widget.question.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subjectId: _selectedSubject?.id,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccess('تم تحديث السؤال بنجاح');
        widget.onQuestionUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('فشل في تحديث السؤال: ${e.toString()}');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
