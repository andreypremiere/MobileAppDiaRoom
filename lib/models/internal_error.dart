class Result {
  final bool result;
  final String message;

  Result({
    required this.result,
    required this.message
});
}

class ResultImageService extends Result {
  final String path;

  ResultImageService({required this.path, required super.result, required super.message});
}