import 'package:flutter/cupertino.dart';

import '../models/post_creator/post_draft.dart';

class DraftProvider extends ChangeNotifier {
  PostDraft? _currentDraft;

  PostDraft? get currentDraft => _currentDraft;

  void startNewDraft(PostDraft draft) {
    _currentDraft = draft;
    notifyListeners();
  }

  void notifyUpdate() {
    notifyListeners();
  }

  void clearDraft() {
    _currentDraft = null;
    notifyListeners();
  }
}