import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../core/config/api_config.dart';

class RiskModel {
  final String level; // LOW, MODERATE, HIGH, CRITICAL
  final String hazard;
  final String message;
  final String recommendedAction;
  final String updatedAt;

  const RiskModel({
    required this.level,
    required this.hazard,
    required this.message,
    required this.recommendedAction,
    required this.updatedAt,
  });

  factory RiskModel.fromJson(Map<String, dynamic> json) {
    return RiskModel(
      level: json['level'] ?? 'LOW',
      hazard: json['hazard'] ?? 'Normal Weather Conditions',
      message: json['message'] ?? 'No active weather warnings detected in your area.',
      recommendedAction: json['recommended_action'] ?? 'Enjoy your day safely!',
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }

  factory RiskModel.defaultLow() {
    return RiskModel(
      level: 'LOW',
      hazard: 'Normal Weather Conditions',
      message: 'No significant weather hazards detected near your location.',
      recommendedAction: 'Stay aware of local forecast updates.',
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
}

class TravelAssessmentModel {
  final String riskLevel;
  final String hazard;
  final String travelRecommendation;
  final String reason;
  final String recommendedAction;

  const TravelAssessmentModel({
    required this.riskLevel,
    required this.hazard,
    required this.travelRecommendation,
    required this.reason,
    required this.recommendedAction,
  });

  factory TravelAssessmentModel.fromJson(Map<String, dynamic> json) {
    return TravelAssessmentModel(
      riskLevel: json['risk_level'] ?? 'LOW',
      hazard: json['hazard'] ?? 'Clear Conditions',
      travelRecommendation: json['travel_recommendation'] ?? 'Safe to Travel',
      reason: json['reason'] ?? 'Weather conditions are stable along your route.',
      recommendedAction: json['recommended_action'] ?? 'Standard driving rules apply.',
    );
  }
}

class RiskService {
  final ApiService _apiService = ApiService();

  Future<RiskModel> getCurrentRisk({required double latitude, required double longitude}) async {
    debugPrint('📡 CURRENT RISK REQUEST\nlatitude = $latitude\nlongitude = $longitude');

    if (ApiConfig.useMockData) {
      return RiskModel.defaultLow();
    }
    try {
      final res = await _apiService.get(
        '/current-risk',
        queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );
      if (res is Map<String, dynamic>) {
        return RiskModel.fromJson(res);
      }
      return RiskModel.defaultLow();
    } catch (_) {
      return RiskModel.defaultLow();
    }
  }

  Future<TravelAssessmentModel> evaluateTravelRisk({
    required double latitude,
    required double longitude,
    String? destination,
  }) async {
    debugPrint('🚗 TRAVEL RISK REQUEST\nlatitude = $latitude\nlongitude = $longitude');

    if (ApiConfig.useMockData) {
      return const TravelAssessmentModel(
        riskLevel: 'LOW',
        hazard: 'Clear Transit',
        travelRecommendation: 'Safe to Travel',
        reason: 'Current weather conditions are clear and road visibility is optimal.',
        recommendedAction: 'Standard driving precautions apply.',
      );
    }
    try {
      final res = await _apiService.post('/travel-risk', {
        'latitude': latitude,
        'longitude': longitude,
        'destination': destination,
      });
      if (res is Map<String, dynamic>) {
        return TravelAssessmentModel.fromJson(res);
      }
      throw ApiException('Invalid travel risk response format');
    } catch (_) {
      return const TravelAssessmentModel(
        riskLevel: 'LOW',
        hazard: 'Clear Transit',
        travelRecommendation: 'Safe to Travel',
        reason: 'Current weather conditions are clear and road visibility is optimal.',
        recommendedAction: 'Standard driving precautions apply.',
      );
    }
  }
}

