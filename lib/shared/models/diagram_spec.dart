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
