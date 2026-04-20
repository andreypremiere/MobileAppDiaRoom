import 'package:flutter/cupertino.dart';

import '../models/post_creator/post_draft.dart';

class DraftProvider extends ChangeNotifier {
  PostDraft? _currentDraft;

  PostDraft? get currentDraft => _currentDraft;

  // Метод для начала создания нового поста
  void startNewDraft(PostDraft draft) {
    _currentDraft = draft;
    notifyListeners();
  }

  // Метод для обновления (если нужно явно уведомить UI)
  void notifyUpdate() {
    notifyListeners();
  }

  // Очистка после успешной публикации
  void clearDraft() {
    _currentDraft = null;
    notifyListeners();
  }
}