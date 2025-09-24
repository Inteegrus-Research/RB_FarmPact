import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmpact/themes/theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      elevation: elevation ?? 4.0,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class LoadingCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? padding;

  const LoadingCard({
    super.key,
    required this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}

class RiskScoreDisplay extends StatelessWidget {
  final double score;
  final String riskLevel;

  const RiskScoreDisplay({
    super.key,
    required this.score,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          score.toInt().toString(),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 48.0,
                fontWeight: FontWeight.w700,
                color: AppTheme.getRiskColorByScore(score),
              ),
        ),
        const SizedBox(height: 4.0),
        Text(
          riskLevel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.getRiskColorByScore(score),
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class LearningResourceCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback? onTap;

  const LearningResourceCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        ),
                      )
                    : _buildPlaceholder(),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.play_circle_outline,
        size: 40,
        color: AppTheme.primaryGreen,
      ),
    );
  }
}

class WeatherIcon extends StatelessWidget {
  final String weatherCondition;
  final double size;

  const WeatherIcon({
    super.key,
    required this.weatherCondition,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor = AppTheme.primaryGreen;

    switch (weatherCondition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case 'cloudy':
      case 'overcast':
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      case 'rainy':
      case 'rain':
        iconData = Icons.umbrella;
        iconColor = Colors.blue;
        break;
      case 'stormy':
      case 'thunderstorm':
        iconData = Icons.flash_on;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.wb_cloudy;
        iconColor = AppTheme.primaryGreen;
    }

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
