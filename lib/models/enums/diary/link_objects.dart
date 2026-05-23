
import 'package:dia_room/models/enums/dialog_abstract_class.dart';

enum LinkAction implements HasLabel {
  linkWorkshop("Папка в мастерской"),
  linkPost("Публикация");

  @override
  final String label;
  const LinkAction(this.label);
}