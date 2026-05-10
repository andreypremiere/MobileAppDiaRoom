import 'package:dia_room/models/enums/workshop/item_status.dart';

class UpdatingItemStatus {
  final String itemId;
  final ItemStatus status;

  UpdatingItemStatus({required this.itemId, required this.status});

  Map<String, dynamic> toMap() {
    return {
      "itemId": itemId,
      "status": status.slug,
    };
  }
}