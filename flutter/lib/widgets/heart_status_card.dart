import 'package:flutter/material.dart';
import '../models/heart_data.dart';

class HeartStatusCard extends StatelessWidget {
  final double avgBpm;
  final HeartData? last;
  final bool isAnimating;
  final AnimationController animationController;

  const HeartStatusCard({
    super.key,
    required this.avgBpm,
    required this.last,
    required this.isAnimating,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AVG BPM:', style: TextStyle(fontSize: 14)),
                Text(
                  avgBpm.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('SPO²:', style: TextStyle(fontSize: 14)),
                Text(
                  '${last?.spo2.toStringAsFixed(1) ?? "-"}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          (!isAnimating || last == null)
              ? _buildHeartIcon(null)
              : ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(
                      parent: animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: _buildHeartIcon(last),
                ),
        ],
      ),
    );
  }

  Widget _buildHeartIcon(HeartData? data) {
    final isActive = data != null;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.favorite,
          color: isActive ? Colors.red : Colors.grey,
          size: 85,
        ),
        Text(
          data?.bpm.toStringAsFixed(1) ?? "-",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
