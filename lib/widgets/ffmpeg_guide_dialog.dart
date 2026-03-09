import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FFmpegGuideDialog extends StatelessWidget {
  final VoidCallback? onClose;

  const FFmpegGuideDialog({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('FFmpeg未检测到'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '本软件需要FFmpeg才能进行视频转换。请按以下步骤操作：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStep('1', '下载FFmpeg', '点击下方按钮下载FFmpeg'),
            const SizedBox(height: 12),
            _buildStep('2', '解压文件', '将下载的压缩包解压到任意目录\n例如：C:\\ffmpeg'),
            const SizedBox(height: 12),
            _buildStep('3', '配置环境变量', '• 右键"此电脑" → 属性 → 高级系统设置\n• 点击"环境变量"\n• 在系统变量中找到"Path"，双击编辑\n• 点击"新建"，添加FFmpeg的bin目录路径\n  例如：C:\\ffmpeg\\bin\n• 点击"确定"保存'),
            const SizedBox(height: 12),
            _buildStep('4', '重启软件', '配置完成后重启本软件即可使用'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '提示：您也可以将FFmpeg解压到软件目录下的ffmpeg文件夹中，无需配置环境变量。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onClose?.call();
          },
          child: const Text('稍后配置'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final url = Uri.parse('https://ffmpeg.org/download.html');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.download),
          label: const Text('下载FFmpeg'),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
