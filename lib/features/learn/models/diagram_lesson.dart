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
    required this.instructions,
    required this.xpReward,
    required this.blocks,
  });

  final String id;
  final int number;
  final String title;
  final String instructions;
  final int xpReward;
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

const firstDiagramLesson = DiagramLesson(
  id: 'unit-1-lesson-3',
  number: 3,
  title: 'Tu primer diagrama',
  instructions:
      'Toca los bloques para colocarlos en el diagrama. Todo flujo empieza '
      'en Inicio y termina en Fin.',
  xpReward: 50,
  blocks: [
    DiagramBlock(id: 'start', kind: DiagramBlockKind.start, label: 'Inicio'),
    DiagramBlock(
      id: 'process',
      kind: DiagramBlockKind.process,
      label: 'Mostrar mensaje',
    ),
    DiagramBlock(id: 'end', kind: DiagramBlockKind.end, label: 'Fin'),
  ],
);
