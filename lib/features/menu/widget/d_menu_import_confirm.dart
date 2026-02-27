import 'package:flutter/material.dart';
import 'd_json_viewer.dart';

class MenuImportConfirmDialog extends StatelessWidget {
  final String content;
  final VoidCallback onConfirm;

  const MenuImportConfirmDialog({
    super.key,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '로컬 데이터 확인',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('파일 내용을 확인하고 동기화하시겠습니까?'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Color(0xFF64748B))),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => JsonViewerDialog(json: content),
            );
          },
          child: const Text(
            '내용 확인',
            style: TextStyle(color: Color(0xFF6366F1)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('불러오기'),
        ),
      ],
    );
  }
}
