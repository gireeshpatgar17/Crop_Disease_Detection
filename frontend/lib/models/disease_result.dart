class DiseaseResult {
  final int? id;
  final int? farmId;
  final String disease;
  final double confidence;
  final double scale;
  final String status;
  final String recommendation;
  final String? imageUrl;
  final String? symptoms;
  final String? cause;
  final String? treatment;
  final String? prevention;
  final bool savedToDb;
  final Map<String, double> allPredictions;

  const DiseaseResult({
    this.id,
    this.farmId,
    required this.disease,
    required this.confidence,
    required this.scale,
    required this.status,
    required this.recommendation,
    this.imageUrl,
    this.symptoms,
    this.cause,
    this.treatment,
    this.prevention,
    this.savedToDb = false,
    this.allPredictions = const {},
  });

  bool get isHealthy =>
      disease.toLowerCase().contains('healthy') ||
      status.toLowerCase() == 'healthy';

  int get confidencePercent => (confidence * 100).round();

  factory DiseaseResult.fromJson(Map<String, dynamic> json) {
    final Map<String, double> preds = {};
    if (json['all_predictions'] is Map) {
      (json['all_predictions'] as Map).forEach((key, value) {
        if (value is num) {
          preds[key.toString()] = value.toDouble();
        }
      });
    }

    return DiseaseResult(
      id: (json['id'] as num?)?.toInt(),
      farmId: (json['farm_id'] as num?)?.toInt(),
      disease: json['disease']?.toString() ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Unknown',
      recommendation: json['recommendation']?.toString() ??
          'Consult an agricultural expert for guidance.',
      imageUrl: json['image_url']?.toString(),
      symptoms: json['symptoms']?.toString(),
      cause: json['cause']?.toString(),
      treatment: json['treatment']?.toString(),
      prevention: json['prevention']?.toString(),
      savedToDb: json['saved_to_db'] == true,
      allPredictions: preds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'disease': disease,
      'confidence': confidence,
      'scale': scale,
      'status': status,
      'recommendation': recommendation,
      'image_url': imageUrl,
      'symptoms': symptoms,
      'cause': cause,
      'treatment': treatment,
      'prevention': prevention,
      'saved_to_db': savedToDb,
      'all_predictions': allPredictions,
    };
  }
}
