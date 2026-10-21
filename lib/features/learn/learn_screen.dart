import 'package:flutter/material.dart';

import '../../shared/widgets/flow_page_header.dart';
import 'widgets/learning_path.dart';
import 'widgets/unit_summary_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FlowPageHeader(title: 'Ruta de aprendizaje'),
                SizedBox(height: 20),
                UnitSummaryCard(),
                SizedBox(height: 18),
                LearningPath(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
