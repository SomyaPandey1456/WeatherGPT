import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';
import '../screens/alerts/alert_details_screen.dart';
import '../screens/disaster/disaster_screen.dart';
import 'weather_card.dart';
import 'forecast_card.dart';
import 'alert_card.dart';
import 'advisory_card.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onQuerySelected;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.onQuerySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: context.isDark ? AppColors.skyBlue : AppColors.primaryBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.userBubbleBg : context.cardBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border:
                        isUser ? null : Border.all(color: context.borderBg),
                    boxShadow: AppStyles.softShadow,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isUser ? Colors.white : context.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                if (message.structuredContent != null) ...[
                  const SizedBox(height: 10),
                  _buildStructuredContent(context, message.structuredContent!),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
              child: Icon(Icons.person_rounded,
                  size: 18, color: context.isDark ? AppColors.skyBlue : AppColors.primaryBlue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStructuredContent(
      BuildContext context, StructuredResponseContent content) {
    switch (content.type) {
      case ResponseContentType.weatherCard:
        if (content.currentWeather != null) {
          return WeatherCard(weather: content.currentWeather!);
        }
        break;
      case ResponseContentType.forecastCard:
        if (content.hourlyForecasts != null) {
          return Container(
            height: 130,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: content.hourlyForecasts!.length,
              itemBuilder: (context, index) {
                return HourlyForecastTile(
                    forecast: content.hourlyForecasts![index]);
              },
            ),
          );
        }
        break;
      case ResponseContentType.alertCard:
        if (content.alert != null) {
          return AlertCard(
            alert: content.alert!,
            onTap: () {
              // Navigate to AlertDetailsScreen with the associated alert data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AlertDetailsScreen(alert: content.alert!),
                ),
              );
            },
          );
        }
        break;
      case ResponseContentType.advisoryCard:
        if (content.advisoryData != null) {
          final data = content.advisoryData!;
          return GestureDetector(
            onTap: () {
              // Navigate to DisasterScreen for advisory cards
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DisasterScreen(),
                ),
              );
            },
            child: AdvisoryCardWidget(
              title: data['title'] ?? 'Advisory',
              category: data['category'] ?? 'General',
              recommendation: data['recommendation'] ?? '',
              riskLevel: data['risk_level'] ?? 'Moderate',
            ),
          );
        }
        break;
      default:
        return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
