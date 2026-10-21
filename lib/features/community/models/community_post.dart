import 'package:flutter/material.dart';

enum DiagramPreviewType { linear, decision }

class DiagramSpec {
  const DiagramSpec({
    required this.type,
    this.startLabel = 'Inicio',
    this.processLabel = 'Mostrar mensaje',
    this.decisionLabel = 'Es > 0',
    this.yesLabel = 'Sí',
    this.noLabel = 'No',
    this.endLabel = 'Fin',
  });

  final DiagramPreviewType type;
  final String startLabel;
  final String processLabel;
  final String decisionLabel;
  final String yesLabel;
  final String noLabel;
  final String endLabel;
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.avatarColor,
    required this.timeAgo,
    required this.authorRole,
    required this.title,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.diagram,
  });

  final String id;
  final String authorName;
  final String authorInitials;
  final Color avatarColor;
  final String timeAgo;
  final String authorRole;
  final String title;
  final String caption;
  final int likes;
  final int comments;
  final DiagramSpec diagram;
}
