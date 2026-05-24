import '../../configuration/constants.dart';

class WorkshopLink {
  String? _workshopLink;

  WorkshopLink();

  void setRoot() {
    _workshopLink = uuidNil;
  }

  void setId(String id) {
    _workshopLink = id;
  }

  void setEmpty() {
    _workshopLink = null;
  }

  bool isRoot() {
    return _workshopLink == uuidNil;
  }

  bool isExist() {
    return _workshopLink != null;
  }

  String? getLink() {
    return _workshopLink;
  }

  factory WorkshopLink.fromMap(Map<String, dynamic> map) {
    final workshopLink = map['workshopLink'];

    final WorkshopLink link = WorkshopLink();

    if (workshopLink == null) {
      link.setEmpty();
    } else if(workshopLink == uuidNil) {
      link.setRoot();
    } else {
      link.setId(workshopLink);
    }

    return link;
  }


}