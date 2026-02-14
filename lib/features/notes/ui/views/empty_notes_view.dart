import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Notes', elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/empty_notes.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Title
            const Text(
              'Create Your First Note',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'Add a note about anything (your thoughts on climate change, or your history essay) and share it with the world.',
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),

            // Create Note Button
            CustomButton(
              text: 'Create Note',
              onPressed: () async {
                // اروح على شاشة إضافة النوت
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.addNote,
                );

                // إذا تم إضافة النوت بنجاح، اروح على شاشة الـ notes
                if (result == true) {
                  // استبدل الشاشة الحالية بشاشة الـ notes
                  Navigator.pushReplacementNamed(context, AppRoutes.allNotes);
                }
              },
              backgroundColor: const Color(0xFF4A90E2),
              borderRadius: 25,
              height: 55,
            ),
          ],
        ),
      ),
    );
  }
}
