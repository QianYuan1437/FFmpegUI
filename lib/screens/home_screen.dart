import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ffmpeg_service.dart';
import '../widgets/ffmpeg_guide_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _inputFile;
  String? _outputDir;
  String? _outputFile;
  String _outputFormat = 'mp4';
  String _quality = 'medium';
  String _resolution = 'original';
  String _videoCodec = 'h264';
  String _audioCodec = 'copy';
  String _frameRate = 'original';
  String _bitrate = 'auto';
  bool _isConverting = false;
  String _status = '正在检查FFmpeg...';
  bool _ffmpegAvailable = false;
  bool _hasShownGuide = false;
  bool _useDiscreteGPU = true;

  final List<String> _formats = ['mp4', 'avi', 'mkv', 'mov', 'flv', 'wmv'];

  @override
  void initState() {
    super.initState();
    _checkFFmpeg(showGuide: true);
  }

  Future<void> _checkFFmpeg({bool showGuide = false}) async {
    final available = await FFmpegService.checkFFmpegAvailable();
    setState(() {
      _ffmpegAvailable = available;
      _status = available ? '等待选择文件...' : 'FFmpeg未检测到，点击右上角查看配置指南';
    });

    if (!available && showGuide && !_hasShownGuide) {
      _hasShownGuide = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => FFmpegGuideDialog(
              onClose: () => _checkFFmpeg(showGuide: false),
            ),
          );
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      final filePath = result.files.single.path!;
      final fileDir = File(filePath).parent.path;
      setState(() {
        _inputFile = filePath;
        _outputDir = fileDir;
        _status = '已选择: ${result.files.single.name}';
      });
    }
  }

  Future<void> _pickOutputDir() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() => _outputDir = result);
    }
  }

  Future<void> _convert() async {
    if (_inputFile == null) return;

    setState(() {
      _isConverting = true;
      _status = '正在转换...';
    });

    try {
      final output = await FFmpegService.convert(
        _inputFile!,
        _outputFormat,
        outputDir: _outputDir,
        quality: _quality,
        resolution: _resolution,
        useDiscreteGPU: _useDiscreteGPU,
        videoCodec: _videoCodec,
        audioCodec: _audioCodec,
        frameRate: _frameRate,
        bitrate: _bitrate,
      );
      setState(() {
        _outputFile = output;
        _status = '转换完成！\n输出: $output';
      });
    } catch (e) {
      setState(() {
        _status = '转换失败: $e';
      });
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  Future<void> _openFolder() async {
    if (_outputFile == null) return;
    final dir = File(_outputFile!).parent.path;
    await launchUrl(Uri.file(dir));
  }

  Future<void> _playVideo() async {
    if (_outputFile == null) return;
    await launchUrl(Uri.file(_outputFile!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('FFmpeg视频转换工具', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_ffmpegAvailable ? Icons.check_circle : Icons.help_outline),
            color: _ffmpegAvailable ? Colors.green : Colors.orange,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FFmpegGuideDialog(
                  onClose: () => _checkFFmpeg(showGuide: false),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton(
                  onPressed: (_isConverting || !_ffmpegAvailable) ? null : _pickFile,
                  icon: Icons.folder_open,
                  label: '选择视频文件',
                  color: Colors.blue,
                ),
                if (_inputFile != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '已选择: ${_inputFile!.split(Platform.pathSeparator).last}',
                      style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _buildSection('输出设置', [
                  _buildOptionRow('输出格式', Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!, width: 1.5),
                    ),
                    child: DropdownButton<String>(
                      value: _outputFormat,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
                      dropdownColor: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      items: _formats.map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[900])),
                      )).toList(),
                      onChanged: (_isConverting || !_ffmpegAvailable) ? null : (v) => setState(() => _outputFormat = v!),
                    ),
                  )),
                  const SizedBox(height: 12),
                  _buildOptionRow('输出目录', Row(
                    children: [
                      Expanded(child: Text(_outputDir ?? '默认（文档目录）', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
                      IconButton(icon: const Icon(Icons.folder_open), onPressed: _pickOutputDir),
                    ],
                  )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallButton(
                          onPressed: () => setState(() => _useDiscreteGPU = false),
                          label: '优先核显',
                          color: _useDiscreteGPU ? Colors.grey : Colors.orange,
                          isSelected: !_useDiscreteGPU,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallButton(
                          onPressed: () => setState(() => _useDiscreteGPU = true),
                          label: '优先独显',
                          color: _useDiscreteGPU ? Colors.green : Colors.grey,
                          isSelected: _useDiscreteGPU,
                        ),
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSection('高级选项', [
                  Row(
                    children: [
                      Expanded(child: _buildDropdownButton('视频质量', _getQualityLabel(_quality), ['高质量', '中等质量', '低质量'], ['high', 'medium', 'low'], (v) => setState(() => _quality = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdownButton('输出分辨率', _getResolutionLabel(_resolution), ['原始', '1080p', '720p', '480p'], ['original', '1920:1080', '1280:720', '854:480'], (v) => setState(() => _resolution = v))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDropdownButton('视频编码器', _getVideoCodecLabel(_videoCodec), ['H.264', 'H.265', 'VP9'], ['h264', 'h265', 'vp9'], (v) => setState(() => _videoCodec = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdownButton('音频编码器', _getAudioCodecLabel(_audioCodec), ['复制原音频', 'AAC', 'MP3', 'Opus'], ['copy', 'aac', 'mp3', 'opus'], (v) => setState(() => _audioCodec = v))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDropdownButton('帧率', _getFrameRateLabel(_frameRate), ['原始', '60fps', '30fps', '24fps'], ['original', '60', '30', '24'], (v) => setState(() => _frameRate = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdownButton('码率', _getBitrateLabel(_bitrate), ['自动', '10Mbps', '5Mbps', '2Mbps'], ['auto', '10', '5', '2'], (v) => setState(() => _bitrate = v))),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),
                _buildButton(
                  onPressed: (_inputFile != null && !_isConverting && _ffmpegAvailable) ? _convert : null,
                  icon: _isConverting ? null : Icons.play_arrow,
                  label: _isConverting ? '转换中...' : '开始转换',
                  color: Colors.green,
                  isLoading: _isConverting,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_status, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                  ),
                ),
                if (_outputFile != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          onPressed: _openFolder,
                          icon: Icons.folder_open,
                          label: '打开文件夹',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton(
                          onPressed: _playVideo,
                          icon: Icons.play_circle,
                          label: '播放视频',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildOptionRow(String label, Widget child) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildRadio(String label, String value, String groupValue, ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      groupValue: groupValue,
      onChanged: (_isConverting || !_ffmpegAvailable) ? null : onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    IconData? icon,
    required String label,
    required Color color,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          else if (icon != null)
            Icon(icon),
          if (icon != null || isLoading) const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required VoidCallback? onPressed,
    required String label,
    required Color color,
    bool isSelected = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isSelected ? 4 : 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDropdownButton(String label, String currentValue, List<String> labels, List<String> values, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1.5),
      ),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Expanded(
            child: DropdownButton<String>(
              value: values[labels.indexOf(currentValue)],
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700], size: 20),
              dropdownColor: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue[900]),
              items: List.generate(labels.length, (i) => DropdownMenuItem(value: values[i], child: Text(labels[i]))),
              onChanged: (_isConverting || !_ffmpegAvailable) ? null : (v) => onChanged(v!),
            ),
          ),
        ],
      ),
    );
  }

  String _getQualityLabel(String quality) {
    switch (quality) {
      case 'high': return '高质量';
      case 'medium': return '中等质量';
      case 'low': return '低质量';
      default: return quality;
    }
  }

  String _getResolutionLabel(String resolution) {
    switch (resolution) {
      case 'original': return '原始';
      case '1920:1080': return '1080p';
      case '1280:720': return '720p';
      case '854:480': return '480p';
      default: return resolution;
    }
  }

  String _getVideoCodecLabel(String codec) {
    switch (codec) {
      case 'h264': return 'H.264';
      case 'h265': return 'H.265';
      case 'vp9': return 'VP9';
      default: return codec;
    }
  }

  String _getAudioCodecLabel(String codec) {
    switch (codec) {
      case 'copy': return '复制原音频';
      case 'aac': return 'AAC';
      case 'mp3': return 'MP3';
      case 'opus': return 'Opus';
      default: return codec;
    }
  }

  String _getFrameRateLabel(String frameRate) {
    switch (frameRate) {
      case 'original': return '原始';
      case '60': return '60fps';
      case '30': return '30fps';
      case '24': return '24fps';
      default: return frameRate;
    }
  }

  String _getBitrateLabel(String bitrate) {
    switch (bitrate) {
      case 'auto': return '自动';
      case '10': return '10Mbps';
      case '5': return '5Mbps';
      case '2': return '2Mbps';
      default: return bitrate;
    }
  }
}
