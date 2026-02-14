import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/user_service.dart';
import '../../data/models/community_constants.dart';
import '../../data/models/question.dart';
import '../../data/models/subject.dart';
import '../../data/services/question_service.dart';

class AskQuestionBottomSheet extends StatefulWidget {
  final Function(Question) onQuestionSubmitted;
  final VoidCallback? onDismissed;

  const AskQuestionBottomSheet({
    super.key,
    required this.onQuestionSubmitted,
    this.onDismissed,
  });

  @override
  State<AskQuestionBottomSheet> createState() => _AskQuestionBottomSheetState();
}

class _AskQuestionBottomSheetState extends State<AskQuestionBottomSheet> {
  final TextEditingController _questionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedGrade;
  Subject? _selectedSubject;
  List<Subject>? _subjects;
  bool _isLoadingSubjects = true;
  final List<File> _attachments = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
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
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSubjects = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'اسأل سؤال جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grade Selection
                  _buildSectionTitle('اختر الصف الدراسي'),
                  _buildGradeSelector(),

                  SizedBox(height: 24),

                  // Subject Selection
                  _buildSectionTitle('اختر المادة'),
                  _buildSubjectSelector(),

                  SizedBox(height: 24),

                  // Question Input
                  _buildSectionTitle('اكتب سؤالك'),
                  _buildQuestionInput(),

                  SizedBox(height: 24),

                  // Attachments
                  _buildSectionTitle('إرفاق ملفات (اختياري)'),
                  _buildAttachmentSection(),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Submit Button
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child:
                    _isSubmitting
                        ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'إرسال السؤال (+5 XP)',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildGradeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGrade,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: 'اختر الصف الدراسي',
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        items:
            CommunityConstants.grades.map((grade) {
              return DropdownMenuItem(value: grade, child: Text(grade));
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGrade = value;
          });
        },
      ),
    );
  }

  Widget _buildSubjectSelector() {
    if (_isLoadingSubjects) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_subjects == null || _subjects!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'فشل في تحميل المواد الدراسية',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Subject>(
        value: _selectedSubject,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: 'اختر المادة',
          hintStyle: TextStyle(color: Colors.grey[500]),
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
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _questionController,
        maxLines: 5,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'اكتب سؤالك هنا...',
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAttachmentButton(
              icon: Icons.image,
              label: 'صورة',
              onTap: _pickImage,
            ),
            SizedBox(width: 12),
            _buildAttachmentButton(
              icon: Icons.picture_as_pdf,
              label: 'PDF',
              onTap: _pickPDF,
            ),
          ],
        ),

        if (_attachments.isNotEmpty) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الملفات المرفقة:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                ..._attachments.map((file) => _buildAttachmentItem(file)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: Colors.grey[600]),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(File file) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            file.path.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
            size: 20,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              file.path.split('/').last,
              style: TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _removeAttachment(file),
            icon: Icon(Icons.close, size: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _attachments.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('فشل في تحديد الصورة');
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _attachments.add(File(result.files.single.path!));
        });
      }
    } catch (e) {
      _showErrorSnackBar('فشل في تحديد الملف');
    }
  }

  void _removeAttachment(File file) {
    setState(() {
      _attachments.remove(file);
    });
  }

  bool _canSubmit() {
    return _selectedGrade != null &&
        _selectedSubject != null &&
        _questionController.text.trim().isNotEmpty &&
        !_isSubmitting;
  }

  Future<void> _submitQuestion() async {
    if (!_canSubmit()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final questionService = sl<QuestionService>();

      // Get current user ID from token
      final userData = await UserService.getUserDataFromToken();
      if (userData == null || userData.id == null) {
        _showErrorSnackBar('يجب تسجيل الدخول أولاً');
        return;
      }

      // Get image file if attached (only first image)
      File? imageFile;
      for (final file in _attachments) {
        if (!file.path.endsWith('.pdf')) {
          imageFile = file;
          break;
        }
      }

      // Call the API to create question
      final question = await questionService.createQuestion(
        subjectId: _selectedSubject!.id,
        creatorId: userData.id!,
        title: _questionController.text.trim(),
        description: _questionController.text.trim(),
        imageFile: imageFile,
      );

      // Close bottom sheet first
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('تم إرسال السؤال بنجاح!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Call the callback after closing to refresh data
      widget.onQuestionSubmitted(question);
    } catch (e) {
      // Close bottom sheet on failure
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('فشل في إرسال السؤال، حاول مرة أخرى')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Notify parent to refresh data even on failure
      widget.onDismissed?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
