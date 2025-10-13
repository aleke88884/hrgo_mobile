import 'package:flutter/material.dart';
import 'dart:io';

class SickLeaveScreen extends StatefulWidget {
  const SickLeaveScreen({Key? key}) : super(key: key);

  @override
  State<SickLeaveScreen> createState() => _SickLeaveScreenState();
}

class _SickLeaveScreenState extends State<SickLeaveScreen> {
  final TextEditingController _commentController = TextEditingController();
  File? _attachedFile;
  String _status = 'Under review';

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _attachFile() async {
    // Implement file picker logic here
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening file picker...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate file attachment
    setState(() {
      // _attachedFile would be set here in real implementation
    });
  }

  void _sendSickLeave() {
    if (_commentController.text.isEmpty && _attachedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach a sick leave certificate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Handle send action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sick leave request submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _status = 'Submitted';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3F3D56)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sick Leave',
          style: TextStyle(
            color: Color(0xFF3F3D56),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instruction Text
                    Text(
                      'Attach photo or scan of the sick leave certificate.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Attach File Button
                    _buildAttachFileButton(),

                    const SizedBox(height: 24),

                    // Comment Text Area
                    _buildCommentField(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Section with Status and Send Button
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildAttachFileButton() {
    return GestureDetector(
      onTap: _attachFile,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3F3D56),
            width: 2,
            style: BorderStyle.solid,
          ),
          // Dashed border effect using custom painter would be more complex
          // Using solid border as approximation
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.attach_file, color: Color(0xFF3F3D56), size: 28),
            SizedBox(width: 12),
            Text(
              'Attach File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F3D56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Add a comment (optional)',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Status: ',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F3D56),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Send Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _sendSickLeave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F3D56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed border (optional enhancement)
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    this.color = const Color(0xFF3F3D56),
    this.strokeWidth = 2.0,
    this.dashWidth = 8.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    double distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(distance + dashWidth);

        if (start != null && end != null) {
          dashPath.moveTo(start.position.dx, start.position.dy);
          dashPath.lineTo(end.position.dx, end.position.dy);
        }

        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
