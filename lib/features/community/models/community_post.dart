import 'package:flutter/material.dart';

import '../../../shared/models/diagram_spec.dart';

export '../../../shared/models/diagram_spec.dart';

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
