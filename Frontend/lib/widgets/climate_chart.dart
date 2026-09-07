import 'package:flutter/material.dart';
import '../models/climate.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';

class ClimateChartWidget extends StatelessWidget {
  final List<ClimateDataPoint> data;

  const ClimateChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: context.borderBg),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temperature Trend (°C)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.sunnyYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Avg Temp',
                    style: TextStyle(fontSize: 12, color: context.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _ClimatePainter(data: data, gridColor: context.borderBg),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((d) {
              return Text(
                d.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.textMuted,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ClimatePainter extends CustomPainter {
  final List<ClimateDataPoint> data;
  final Color gridColor;

  _ClimatePainter({required this.data, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxTemp = data.map((e) => e.tempValue).reduce((a, b) => a > b ? a : b);
    final minTemp = data.map((e) => e.tempValue).reduce((a, b) => a < b ? a : b);
    final range = (maxTemp - minTemp) == 0 ? 1.0 : (maxTemp - minTemp);

    final linePaint = Paint()
      ..color = AppColors.sunnyYellow
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.sunnyYellow
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = (data[i].tempValue - minTemp) / range;
      final y = size.height - (normalizedY * (size.height - 20) + 10);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPointX = (p1.dx + p2.dx) / 2;
      path.cubicTo(controlPointX, p1.dy, controlPointX, p2.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(path, linePaint);

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
