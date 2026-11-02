import 'package:flutter/material.dart';

import '../../shared/widgets/flow_page_header.dart';
import 'lesson_screen.dart';
import 'models/diagram_lesson.dart';
import 'widgets/learning_path.dart';
import 'widgets/unit_summary_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool _lessonCompleted = false;

  Future<void> _openLesson() async {
    final approved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LessonScreen(lesson: firstDiagramLesson),
      ),
    );

    if (!mounted || approved != true) {
      return;
    }

    setState(() => _lessonCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _lessonCompleted ? 1.0 : 0.67;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlowPageHeader(title: 'Ruta de aprendizaje'),
                const SizedBox(height: 20),
                UnitSummaryCard(
                  progress: progress,
                  completedLessons: _lessonCompleted ? 3 : 2,
                ),
                const SizedBox(height: 18),
                LearningPath(
                  lessonCompleted: _lessonCompleted,
                  onCurrentLessonTap: _openLesson,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
