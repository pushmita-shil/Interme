import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MarketplaceShimmer extends StatefulWidget {
  final int count;
  final bool isHorizontal;

  const MarketplaceShimmer({
    super.key,
    this.count = 3,
    this.isHorizontal = false,
  });

  @override
  State<MarketplaceShimmer> createState() => _MarketplaceShimmerState();
}

class _MarketplaceShimmerState extends State<MarketplaceShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontal) {
      return SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.count,
          itemBuilder: (_, index) => _buildCard(width: 280),
        ),
      );
    }

    return Column(
      children: List.generate(
        widget.count,
        (index) => _buildCard(width: double.infinity),
      ),
    );
  }

  Widget _buildCard({required double width}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          margin: const EdgeInsets.only(bottom: 16, right: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _shimmerBox(width: 44, height: 44, radius: 10),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(width: 120, height: 14, radius: 4),
                        const SizedBox(height: 6),
                        _shimmerBox(width: 80, height: 12, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _shimmerBox(width: 200, height: 18, radius: 4),
              const SizedBox(height: 8),
              _shimmerBox(width: 140, height: 14, radius: 4),
              const SizedBox(height: 16),
              Row(
                children: [
                  _shimmerBox(width: 70, height: 24, radius: 6),
                  const SizedBox(width: 8),
                  _shimmerBox(width: 60, height: 24, radius: 6),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(_animation.value),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

