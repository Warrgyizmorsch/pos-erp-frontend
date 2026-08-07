class GstReportSummary {
  final double outputCgst;
  final double outputSgst;
  final double outputIgst;
  final double inputCgst;
  final double inputSgst;
  final double inputIgst;
  final double netTaxPayable;

  GstReportSummary({
    required this.outputCgst,
    required this.outputSgst,
    required this.outputIgst,
    required this.inputCgst,
    required this.inputSgst,
    required this.inputIgst,
    required this.netTaxPayable,
  });

  double get totalOutputTax => outputCgst + outputSgst + outputIgst;
  double get totalInputTax => inputCgst + inputSgst + inputIgst;

  factory GstReportSummary.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> output =
        json['outputTax'] is Map<String, dynamic> ? json['outputTax'] : json;
    final Map<String, dynamic> input = json['inputTax'] is Map<String, dynamic>
        ? json['inputTax']
        : json;

    final outC =
        (output['cgst'] as num?)?.toDouble() ??
        (json['outputCgst'] as num?)?.toDouble() ??
        0.0;
    final outS =
        (output['sgst'] as num?)?.toDouble() ??
        (json['outputSgst'] as num?)?.toDouble() ??
        0.0;
    final outI =
        (output['igst'] as num?)?.toDouble() ??
        (json['outputIgst'] as num?)?.toDouble() ??
        0.0;

    final inC =
        (input['cgst'] as num?)?.toDouble() ??
        (json['inputCgst'] as num?)?.toDouble() ??
        0.0;
    final inS =
        (input['sgst'] as num?)?.toDouble() ??
        (json['inputSgst'] as num?)?.toDouble() ??
        0.0;
    final inI =
        (input['igst'] as num?)?.toDouble() ??
        (json['inputIgst'] as num?)?.toDouble() ??
        0.0;

    final netP =
        (json['netTaxPayable'] as num?)?.toDouble() ??
        ((outC + outS + outI) - (inC + inS + inI));

    return GstReportSummary(
      outputCgst: outC,
      outputSgst: outS,
      outputIgst: outI,
      inputCgst: inC,
      inputSgst: inS,
      inputIgst: inI,
      netTaxPayable: netP,
    );
  }
}
