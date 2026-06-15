class CheckVersionRequest {
  final String version;
  final String numberBuild;

  CheckVersionRequest({required this.version, required this.numberBuild});

  Map<String, dynamic> toMap() {
    return {
      "version": version,
      "numberBuild": numberBuild
    };
  }
}