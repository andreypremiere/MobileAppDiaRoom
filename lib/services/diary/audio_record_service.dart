// import 'package:record/record.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
//
// class AudioRecorderService {
//   final AudioRecorder _recorder = AudioRecorder();
//
//   Future<void> startRecording() async {
//     try {
//       if (await _recorder.hasPermission()) {
//
//         final directory = await getApplicationCacheDirectory();
//         final String filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
//
//         const config = RecordConfig();
//
//         await _recorder.start(config, path: filePath);
//         print("Запись пошла: $filePath");
//       }
//     } catch (e) {
//       print("Ошибка при старте записи: $e");
//     }
//   }
//
//   Future<String?> stopRecording() async {
//     final path = await _recorder.stop();
//     return path;
//   }
//
//   void dispose() {
//     _recorder.dispose();
//   }
// }