class GstReportHeadBreakdown {
  final String head;
  final double output;
  final double input;
  final double payable;
  final double excessITC;

  GstReportHeadBreakdown({
    required this.head,
    required this.output,
    required this.input,
    required this.payable,
    required this.excessITC,
  });
}

class GstReportSummary {
  final double outputCgst;
  final double outputSgst;
  final double outputIgst;
  final double inputCgst;
  final double inputSgst;
  final double inputIgst;
  final double netTaxPayable;
  final Map<String, dynamic> rawJson;

  GstReportSummary({
    required this.outputCgst,
    required this.outputSgst,
    required this.outputIgst,
    required this.inputCgst,
    required this.inputSgst,
    required this.inputIgst,
    required this.netTaxPayable,
    required this.rawJson,
  });

  double get totalOutputTax => outputCgst + outputSgst + outputIgst;
  double get totalInputTax => inputCgst + inputSgst + inputIgst;

  List<GstReportHeadBreakdown> get breakdownRows {
    final List<String> heads = rawJson['heads'] is List
        ? (rawJson['heads'] as List).map((e) => e.toString()).toList()
        : ['cgst', 'sgst', 'igst'];

    final Map<String, dynamic> outputMap =
        rawJson['output'] is Map<String, dynamic>
        ? rawJson['output'] as Map<String, dynamic>
        : {};
    final Map<String, dynamic> inputMap =
        rawJson['input'] is Map<String, dynamic>
        ? rawJson['input'] as Map<String, dynamic>
        : {};
    final Map<String, dynamic> payableMap =
        rawJson['payable'] is Map<String, dynamic>
        ? rawJson['payable'] as Map<String, dynamic>
        : {};
    final Map<String, dynamic> excessItcMap =
        rawJson['excessITC'] is Map<String, dynamic>
        ? rawJson['excessITC'] as Map<String, dynamic>
        : {};

    return heads.map((key) {
      final outVal =
          (outputMap[key] as num?)?.toDouble() ??
          (key == 'cgst'
              ? outputCgst
              : (key == 'sgst'
                    ? outputSgst
                    : (key == 'igst' ? outputIgst : 0.0)));
      final inVal =
          (inputMap[key] as num?)?.toDouble() ??
          (key == 'cgst'
              ? inputCgst
              : (key == 'sgst'
                    ? inputSgst
                    : (key == 'igst' ? inputIgst : 0.0)));
      final payVal =
          (payableMap[key] as num?)?.toDouble() ??
          (outVal > inVal ? outVal - inVal : 0.0);
      final excVal =
          (excessItcMap[key] as num?)?.toDouble() ??
          (inVal > outVal ? inVal - outVal : 0.0);

      String label = key.toUpperCase();
      if (key == 'cgst') label = 'CGST (Central Tax)';
      if (key == 'sgst') label = 'SGST (State Tax)';
      if (key == 'igst') label = 'IGST (Integrated Tax)';
      if (key == 'total') label = 'TOTAL TAX SUMMARY';

      return GstReportHeadBreakdown(
        head: label,
        output: outVal,
        input: inVal,
        payable: payVal,
        excessITC: excVal,
      );
    }).toList();
  }

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
      rawJson: json,
    );
  }
}
