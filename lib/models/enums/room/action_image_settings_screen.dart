import 'package:dia_room/models/enums/dialog_abstract_class.dart';

enum ActionImageSettings implements HasLabel {
  edit("Изменить"),
  delete("Удалить");

  @override
  final String label;
  const ActionImageSettings(this.label);
}