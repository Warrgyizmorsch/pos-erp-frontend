import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/utils/app_snackbar.dart';

/// Official Government GST Offline Tool (v3.0.0) JSON Exporter
class Gstr1ExportService {
  /// Formats date string to Government GST format: DD-MM-YYYY
  static String formatDateForGST(dynamic dateVal) {
    if (dateVal == null) return '';
    try {
      final str = dateVal.toString();
      final dt = DateTime.parse(str);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      return '$day-$month-$year';
    } catch (_) {
      return dateVal.toString();
    }
  }

  /// Derives 6-digit filing period: MMYYYY
  static String deriveFilingPeriod({String? startDate, String? endDate}) {
    DateTime now = DateTime.now();
    if (endDate != null && endDate.isNotEmpty) {
      try {
        now = DateTime.parse(endDate);
      } catch (_) {}
    } else if (startDate != null && startDate.isNotEmpty) {
      try {
        now = DateTime.parse(startDate);
      } catch (_) {}
    }
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    return '$month$year';
  }

  /// Builds standard GST3.0.0 JSON payload from raw report data
  static Map<String, dynamic> buildGstr1Payload(
    dynamic rawData, {
    String? gstin,
    String? startDate,
    String? endDate,
  }) {
    final effectiveGstin = (gstin != null && gstin.trim().isNotEmpty)
        ? gstin.trim().toUpperCase()
        : 'URP';

    final fp = deriveFilingPeriod(startDate: startDate, endDate: endDate);

    final List<Map<String, dynamic>> b2bList = [];
    final List<Map<String, dynamic>> b2csList = [];
    final List<Map<String, dynamic>> hsnList = [];

    if (rawData is Map<String, dynamic>) {
      // 1. Map B2B Invoices
      final b2bRaw = rawData['b2b'];
      if (b2bRaw is List) {
        for (final inv in b2bRaw) {
          if (inv is Map) {
            final double taxable =
                (inv['taxableAmount'] as num?)?.toDouble() ??
                (inv['taxableValue'] as num?)?.toDouble() ??
                0.0;
            final double totalTax =
                (inv['totalTax'] as num?)?.toDouble() ??
                (inv['taxAmount'] as num?)?.toDouble() ??
                0.0;
            final int rate = taxable > 0 ? ((totalTax / taxable) * 100).round() : 0;
            final String ctin = inv['customerGSTIN']?.toString() ??
                inv['gstin']?.toString() ??
                'URP';
            final String inum = inv['invoiceNo']?.toString() ??
                inv['invoiceNumber']?.toString() ??
                '';
            final String idt = formatDateForGST(inv['date'] ?? inv['createdAt']);
            final double val =
                (inv['invoiceTotal'] as num?)?.toDouble() ??
                (inv['totalAmount'] as num?)?.toDouble() ??
                (taxable + totalTax);

            final String posRaw = inv['stateOfSupply']?.toString() ?? '08';
            final String pos = posRaw.length >= 2 ? posRaw.substring(0, 2) : '08';

            final double cgst = (inv['cgst'] as num?)?.toDouble() ?? 0.0;
            final double sgst = (inv['sgst'] as num?)?.toDouble() ?? 0.0;
            final double igst = (inv['igst'] as num?)?.toDouble() ?? 0.0;

            b2bList.add({
              'ctin': ctin,
              'inv': [
                {
                  'inum': inum,
                  'idt': idt,
                  'val': val,
                  'pos': pos,
                  'rchrg': 'N',
                  'pro_ass': 'N',
                  'itms': [
                    {
                      'num': 1,
                      'itm_det': {
                        'txval': taxable,
                        'rt': rate,
                        'cgst': cgst,
                        'sgst': sgst,
                        'igst': igst,
                      },
                    },
                  ],
                },
              ],
            });
          }
        }
      }

      // 2. Map B2C Small
      final b2cRaw = rawData['b2c'];
      if (b2cRaw is List) {
        for (final inv in b2cRaw) {
          if (inv is Map) {
            final double taxable =
                (inv['taxableAmount'] as num?)?.toDouble() ??
                (inv['taxableValue'] as num?)?.toDouble() ??
                0.0;
            final double totalTax =
                (inv['totalTax'] as num?)?.toDouble() ??
                (inv['taxAmount'] as num?)?.toDouble() ??
                0.0;
            final int rate = taxable > 0 ? ((totalTax / taxable) * 100).round() : 0;
            final String posRaw = inv['stateOfSupply']?.toString() ?? '08';
            final String pos = posRaw.length >= 2 ? posRaw.substring(0, 2) : '08';
            final double cgst = (inv['cgst'] as num?)?.toDouble() ?? 0.0;
            final double sgst = (inv['sgst'] as num?)?.toDouble() ?? 0.0;
            final double igst = (inv['igst'] as num?)?.toDouble() ?? 0.0;

            b2csList.add({
              'sply_ty': 'INTRA',
              'rt': rate,
              'typ': 'OE',
              'pos': pos,
              'txval': taxable,
              'cgst': cgst,
              'sgst': sgst,
              'igst': igst,
            });
          }
        }
      }

      // 3. Map HSN Summary
      final hsnRaw = rawData['hsnSummary'] ?? rawData['hsn'];
      if (hsnRaw is List) {
        int idx = 1;
        for (final h in hsnRaw) {
          if (h is Map) {
            final String hsnCode = h['hsn']?.toString() ??
                h['hsn_sc']?.toString() ??
                'Unclassified';
            final String desc = h['description']?.toString() ??
                h['desc']?.toString() ??
                'Products';
            final String unitRaw = h['unit']?.toString() ?? 'OTH';
            final String uqc = unitRaw.length >= 3
                ? unitRaw.substring(0, 3).toUpperCase()
                : unitRaw.toUpperCase();
            final double qty = (h['quantity'] as num?)?.toDouble() ??
                (h['qty'] as num?)?.toDouble() ??
                1.0;
            final double val = (h['totalValue'] as num?)?.toDouble() ??
                (h['val'] as num?)?.toDouble() ??
                0.0;
            final double txval = (h['taxableValue'] as num?)?.toDouble() ??
                (h['txval'] as num?)?.toDouble() ??
                0.0;
            final double rt = (h['taxRate'] as num?)?.toDouble() ??
                (h['rt'] as num?)?.toDouble() ??
                0.0;
            final double cgst = (h['cgst'] as num?)?.toDouble() ?? 0.0;
            final double sgst = (h['sgst'] as num?)?.toDouble() ?? 0.0;
            final double igst = (h['igst'] as num?)?.toDouble() ?? 0.0;

            hsnList.add({
              'num': idx++,
              'hsn_sc': hsnCode,
              'desc': desc,
              'uqc': uqc,
              'qty': qty,
              'val': val,
              'txval': txval,
              'rt': rt,
              'cgst': cgst,
              'sgst': sgst,
              'igst': igst,
            });
          }
        }
      }
    }

    return {
      'gstin': effectiveGstin,
      'fp': fp,
      'version': 'GST3.0.0',
      'hash': 'hash',
      'b2b': b2bList,
      'b2cs': b2csList,
      'hsn': {'data': hsnList},
    };
  }

  /// Converts payload to formatted, pretty-printed JSON string
  static String formatGstr1Json(
    dynamic rawData, {
    String? gstin,
    String? startDate,
    String? endDate,
  }) {
    final payload = buildGstr1Payload(
      rawData,
      gstin: gstin,
      startDate: startDate,
      endDate: endDate,
    );
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  /// Copies formatted GSTR-1 JSON to clipboard
  static Future<void> copyGstr1JsonToClipboard(
    dynamic rawData, {
    String? gstin,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final jsonStr = formatGstr1Json(
        rawData,
        gstin: gstin,
        startDate: startDate,
        endDate: endDate,
      );
      await Clipboard.setData(ClipboardData(text: jsonStr));
      AppSnackbar.success(
        'GSTR-1 GST3.0.0 JSON copied to clipboard. Ready for Government Offline Tool.',
        title: 'JSON Copied',
      );
    } catch (_) {
      AppSnackbar.error('Failed to copy GSTR-1 JSON to clipboard');
    }
  }
}
