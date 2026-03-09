import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

class FFmpegService {
  static String? _ffmpegPath;

  static Future<String?> getFFmpegPath() async {
    if (_ffmpegPath != null) return _ffmpegPath;

    final appDir = Directory.current.path;
    final builtInPath = '$appDir\\ffmpeg\\bin\\ffmpeg.exe';
    if (await File(builtInPath).exists()) {
      _ffmpegPath = builtInPath;
      return _ffmpegPath;
    }

    try {
      final shell = Shell();
      await shell.run('ffmpeg -version');
      _ffmpegPath = 'ffmpeg';
      return _ffmpegPath;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> checkFFmpegAvailable() async {
    _ffmpegPath = null;
    return await getFFmpegPath() != null;
  }

  static Future<String> convert(
    String inputPath,
    String outputFormat, {
    String? outputDir,
    String quality = 'medium',
    String resolution = 'original',
    bool useDiscreteGPU = true,
    String videoCodec = 'h264',
    String audioCodec = 'aac',
    String frameRate = 'original',
    String bitrate = 'auto',
  }) async {
    final ffmpegPath = await getFFmpegPath();
    if (ffmpegPath == null) {
      throw Exception('FFmpeg未找到');
    }

    final dir = outputDir != null ? Directory(outputDir) : await getApplicationDocumentsDirectory();
    final fileName = inputPath.split(Platform.pathSeparator).last.split('.').first;
    final outputPath = '${dir.path}${Platform.pathSeparator}${fileName}_converted.$outputFormat';

    String command;
    if (useDiscreteGPU) {
      command = '"$ffmpegPath" -y -vsync 0 -hwaccel cuda -hwaccel_output_format cuda -i "$inputPath" ';
    } else {
      command = '"$ffmpegPath" -y -hwaccel auto -i "$inputPath" ';
    }

    if (resolution != 'original') {
      if (useDiscreteGPU) {
        command += '-vf scale_cuda=$resolution ';
      } else {
        command += '-vf scale=$resolution ';
      }
    }

    // 视频编码器
    if (useDiscreteGPU) {
      switch (videoCodec) {
        case 'h264':
          command += '-c:v h264_nvenc -gpu 0 ';
          break;
        case 'h265':
          command += '-c:v hevc_nvenc -gpu 0 ';
          break;
        case 'vp9':
          command += '-c:v vp9 ';
          break;
      }
    } else {
      switch (videoCodec) {
        case 'h264':
          command += '-c:v h264_qsv ';
          break;
        case 'h265':
          command += '-c:v hevc_qsv ';
          break;
        case 'vp9':
          command += '-c:v vp9 ';
          break;
      }
    }

    // 质量参数
    if (videoCodec != 'vp9') {
      switch (quality) {
        case 'high':
          command += '-preset p7 -tune hq -rc vbr -cq 18 -b:v 0 ';
          break;
        case 'medium':
          command += '-preset p4 -tune hq -rc vbr -cq 23 -b:v 0 ';
          break;
        case 'low':
          command += '-preset p1 -rc vbr -cq 28 -b:v 0 ';
          break;
      }
    }

    // 帧率
    if (frameRate != 'original') {
      command += '-r $frameRate ';
    }

    // 码率
    if (bitrate != 'auto') {
      command += '-b:v ${bitrate}M ';
    }

    // 音频编码器
    switch (audioCodec) {
      case 'copy':
        command += '-c:a copy ';
        break;
      case 'aac':
        command += '-c:a aac -b:a 192k ';
        break;
      case 'mp3':
        command += '-c:a libmp3lame -b:a 192k ';
        break;
      case 'opus':
        command += '-c:a libopus -b:a 128k ';
        break;
    }

    command += '"$outputPath"';

    final shell = Shell();
    
    try {
      await shell.run(command);
    } catch (e) {
      // GPU加速失败，回退到CPU
      command = '"$ffmpegPath" -y -i "$inputPath" ';
      
      if (resolution != 'original') {
        command += '-vf scale=$resolution ';
      }
      
      command += '-c:v lib$videoCodec ';
      
      if (videoCodec == 'h264' || videoCodec == 'h265') {
        switch (quality) {
          case 'high':
            command += '-crf 18 ';
            break;
          case 'medium':
            command += '-crf 23 ';
            break;
          case 'low':
            command += '-crf 28 ';
            break;
        }
      }
      
      if (frameRate != 'original') {
        command += '-r $frameRate ';
      }
      
      if (bitrate != 'auto') {
        command += '-b:v ${bitrate}M ';
      }
      
      switch (audioCodec) {
        case 'copy':
          command += '-c:a copy ';
          break;
        case 'aac':
          command += '-c:a aac -b:a 192k ';
          break;
        case 'mp3':
          command += '-c:a libmp3lame -b:a 192k ';
          break;
        case 'opus':
          command += '-c:a libopus -b:a 128k ';
          break;
      }
      
      command += '"$outputPath"';
      await shell.run(command);
    }

    return outputPath;
  }
}
