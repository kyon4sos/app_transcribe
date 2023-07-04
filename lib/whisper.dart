import 'dart:developer';
import 'dart:ffi';
import 'package:app_transcribe/model/task.dart';
import 'package:app_transcribe/whisper_bindings_generated.dart';
import 'package:ffi/ffi.dart';
// import 'package:ffi/ffi.dart' as ffi;

final whisperLib = DynamicLibrary.open("libapp.dylib");
WhisperBindings binding = WhisperBindings(whisperLib);

class Whisper {
  String modelPath = "";

  late String filePath;
  Whisper();
  String getSystemInfo() {
    final info = binding.whisper_print_system_info();
    return info.cast<Utf8>().toDartString();
  }

  Pointer<whisper_context> initFromFile(String pathModel) {
    log("initFromFile");
    modelPath = pathModel;
    final path = pathModel.toNativeUtf8().cast<Char>();
    final ctx = binding.whisper_init_from_file(path);
    return ctx;
  }

  String transcribeFromPath(Pointer<whisper_context> ctx, String filePath) {
    final res = binding.transcribe(ctx, filePath.toNativeUtf8().cast());
    return res.toDartString();
  }
}

class Request {
  final int address;
  final Task task;
  Request({required this.address, required this.task});
}
