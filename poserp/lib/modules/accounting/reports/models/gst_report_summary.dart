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
        json['outputGST'] is Map<String, dynamic>
        ? json['outputGST'] as Map<String, dynamic>
        : (json['outputTax'] is Map<String, dynamic>
              ? json['outputTax'] as Map<String, dynamic>
              : (json['output'] is Map<String, dynamic>
                    ? json['output'] as Map<String, dynamic>
                    : json));

    final Map<String, dynamic> input = json['inputGST'] is Map<String, dynamic>
        ? json['inputGST'] as Map<String, dynamic>
        : (json['inputTax'] is Map<String, dynamic>
              ? json['inputTax'] as Map<String, dynamic>
              : (json['input'] is Map<String, dynamic>
                    ? json['input'] as Map<String, dynamic>
                    : json));

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

    final Map<String, dynamic>? netGstMap =
        json['netGST'] is Map<String, dynamic>
        ? json['netGST'] as Map<String, dynamic>
        : null;

    final netP =
        (netGstMap?['totalPayable'] as num?)?.toDouble() ??
        (netGstMap?['netTaxPayable'] as num?)?.toDouble() ??
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
