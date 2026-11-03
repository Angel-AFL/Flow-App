enum DiagramBlockKind { start, process, end }

class DiagramBlock {
  const DiagramBlock({
    required this.id,
    required this.kind,
    required this.label,
  });

  final String id;
  final DiagramBlockKind kind;
  final String label;
}

class DiagramLesson {
  const DiagramLesson({
    required this.id,
    required this.number,
    required this.title,
    this.concept = '',
    required this.instructions,
    required this.xpReward,
    this.coinReward = 0,
    required this.blocks,
  });

  final String id;
  final int number;
  final String title;
  final String concept;
  final String instructions;
  final int xpReward;
  final int coinReward;
  final List<DiagramBlock> blocks;

  bool isCorrect(List<DiagramBlock?> placedBlocks) {
    if (placedBlocks.length != blocks.length) {
      return false;
    }

    for (var index = 0; index < blocks.length; index++) {
      if (placedBlocks[index]?.id != blocks[index].id) {
        return false;
      }
    }

    return true;
  }

  List<DiagramBlock> get trayBlocks => blocks.reversed.toList();
}
