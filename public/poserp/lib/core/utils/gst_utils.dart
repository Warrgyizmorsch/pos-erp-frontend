/// Indian GST State Codes & Utilities
/// Based on official GST Council 2-digit state identifiers.
const Map<String, String> gstStateCodes = {
  "01": "Jammu & Kashmir",
  "02": "Himachal Pradesh",
  "03": "Punjab",
  "04": "Chandigarh",
  "05": "Uttarakhand",
  "06": "Haryana",
  "07": "Delhi",
  "08": "Rajasthan",
  "09": "Uttar Pradesh",
  "10": "Bihar",
  "11": "Sikkim",
  "12": "Arunachal Pradesh",
  "13": "Nagaland",
  "14": "Manipur",
  "15": "Mizoram",
  "16": "Tripura",
  "17": "Meghalaya",
  "18": "Assam",
  "19": "West Bengal",
  "20": "Jharkhand",
  "21": "Odisha",
  "22": "Chhattisgarh",
  "23": "Madhya Pradesh",
  "24": "Gujarat",
  "25": "Daman & Diu",
  "26": "Dadra & Nagar Haveli",
  "27": "Maharashtra",
  "28": "Andhra Pradesh (Old)",
  "29": "Karnataka",
  "30": "Goa",
  "31": "Lakshadweep",
  "32": "Kerala",
  "33": "Tamil Nadu",
  "34": "Puducherry",
  "35": "Andaman & Nicobar Islands",
  "36": "Telangana",
  "37": "Andhra Pradesh (New)",
  "38": "Ladakh",
};

class GstUtils {
  /// Extracts the 2-digit state code from a GSTIN string.
  static String? getStateCodeFromGstin(String? gstin) {
    if (gstin == null || gstin.trim().length < 2) return null;
    final code = gstin.trim().substring(0, 2);
    if (gstStateCodes.containsKey(code)) {
      return code;
    }
    return null;
  }

  /// Returns the state name for a given 2-digit state code.
  static String? getStateNameFromCode(String? stateCode) {
    if (stateCode == null) return null;
    return gstStateCodes[stateCode];
  }

  /// Validates standard 15-character GSTIN format.
  static bool isValidGstin(String? gstin) {
    if (gstin == null || gstin.trim().isEmpty) return true; // optional
    final regex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    return regex.hasMatch(gstin.trim().toUpperCase());
  }
}
