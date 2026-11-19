import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/gst_utils.dart';
import '../models/business_profile.dart';
import '../repositories/business_repository.dart';

class BusinessProfileController extends GetxController {
  final BusinessRepository _repository;

  BusinessProfileController(this._repository);

  final Rxn<BusinessProfile> profile = Rxn<BusinessProfile>();
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  // Form Controllers
  final businessNameController = TextEditingController();
  final taglineController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final gstinController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final logoUrlController = TextEditingController();
  final signatureUrlController = TextEditingController();

  // Bank & Settlement Details
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final branchController = TextEditingController();
  final upiIdController = TextEditingController();
  final invoiceTermsController = TextEditingController();

  // Reactive Selections
  final RxString selectedBusinessType = 'Retail'.obs;
  final RxString selectedStateCode = ''.obs;
  final RxString selectedStateName = ''.obs;
  final Rxn<DateTime> beginningDate = Rxn<DateTime>();

  final List<String> businessTypes = [
    'Retail',
    'Wholesale',
    'Manufacturing',
    'Service',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    taglineController.dispose();
    phoneController.dispose();
    emailController.dispose();
    gstinController.dispose();
    addressController.dispose();
    pincodeController.dispose();
    logoUrlController.dispose();
    signatureUrlController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    branchController.dispose();
    upiIdController.dispose();
    invoiceTermsController.dispose();
    super.onClose();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final res = await _repository.getProfile();
      profile.value = res;
      _populateFields(res);
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to load business profile';
      AppSnackbar.error(msg, title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFields(BusinessProfile p) {
    businessNameController.text = p.businessName;
    taglineController.text = p.tagline ?? '';
    phoneController.text = p.phone ?? '';
    emailController.text = p.email ?? '';
    gstinController.text = p.gstin ?? '';
    addressController.text = p.address ?? '';
    pincodeController.text = p.pincode ?? '';
    logoUrlController.text = p.logo ?? '';
    signatureUrlController.text = p.signature ?? '';

    bankNameController.text = p.bankName ?? '';
    accountNumberController.text = p.accountNumber ?? '';
    ifscCodeController.text = p.ifscCode ?? '';
    branchController.text = p.branch ?? '';
    upiIdController.text = p.upiId ?? '';
    invoiceTermsController.text = p.invoiceTerms ?? '';

    if (p.businessType != null && businessTypes.contains(p.businessType)) {
      selectedBusinessType.value = p.businessType!;
    } else {
      selectedBusinessType.value = 'Retail';
    }

    if (p.stateCode != null && p.stateCode!.isNotEmpty) {
      selectedStateCode.value = p.stateCode!;
      selectedStateName.value = p.state ?? GstUtils.getStateNameFromCode(p.stateCode) ?? '';
    } else if (p.gstin != null && p.gstin!.length >= 2) {
      final code = GstUtils.getStateCodeFromGstin(p.gstin);
      if (code != null) {
        selectedStateCode.value = code;
        selectedStateName.value = GstUtils.getStateNameFromCode(code) ?? '';
      }
    }

    if (p.beginningDate != null && p.beginningDate!.isNotEmpty) {
      try {
        beginningDate.value = DateTime.parse(p.beginningDate!);
      } catch (_) {}
    }
  }

  void onGstinChanged(String val) {
    final cleanGstin = val.trim().toUpperCase();
    final derivedCode = GstUtils.getStateCodeFromGstin(cleanGstin);
    if (derivedCode != null) {
      selectedStateCode.value = derivedCode;
      selectedStateName.value = GstUtils.getStateNameFromCode(derivedCode) ?? '';
    }
  }

  void onStateChanged(String code) {
    selectedStateCode.value = code;
    selectedStateName.value = GstUtils.getStateNameFromCode(code) ?? '';
  }

  void discardChanges() {
    final p = profile.value;
    if (p != null) {
      _populateFields(p);
    } else {
      businessNameController.clear();
      taglineController.clear();
      phoneController.clear();
      emailController.clear();
      gstinController.clear();
      addressController.clear();
      pincodeController.clear();
      logoUrlController.clear();
      signatureUrlController.clear();
      bankNameController.clear();
      accountNumberController.clear();
      ifscCodeController.clear();
      branchController.clear();
      upiIdController.clear();
      invoiceTermsController.clear();
      selectedBusinessType.value = 'Retail';
      selectedStateCode.value = '';
      selectedStateName.value = '';
      beginningDate.value = null;
    }
    AppSnackbar.info('Changes discarded', title: 'Reset');
  }

  Future<bool> saveProfile() async {
    final name = businessNameController.text.trim();
    if (name.isEmpty) {
      AppSnackbar.error('Business name is required', title: 'Validation Error');
      return false;
    }

    final email = emailController.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      AppSnackbar.error('Please enter a valid email address', title: 'Validation Error');
      return false;
    }

    final pincode = pincodeController.text.trim();
    if (pincode.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(pincode)) {
      AppSnackbar.error('Please enter a valid 6-digit pincode', title: 'Validation Error');
      return false;
    }

    final gstin = gstinController.text.trim().toUpperCase();
    if (gstin.isNotEmpty && !GstUtils.isValidGstin(gstin)) {
      AppSnackbar.error(
        'Invalid GSTIN format. Should be 15 alphanumeric characters (e.g. 27AAAAA0000A1Z5)',
        title: 'GSTIN Warning',
      );
      // We still permit saving or user can correct it
    }

    try {
      isSaving.value = true;
      final payload = {
        'businessName': name,
        'tagline': taglineController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': email,
        'gstin': gstin,
        'address': addressController.text.trim(),
        'businessType': selectedBusinessType.value,
        'state': selectedStateName.value,
        'stateCode': selectedStateCode.value,
        'pincode': pincode,
        'logo': logoUrlController.text.trim(),
        'signature': signatureUrlController.text.trim(),
        'bankName': bankNameController.text.trim(),
        'accountNumber': accountNumberController.text.trim(),
        'ifscCode': ifscCodeController.text.trim().toUpperCase(),
        'branch': branchController.text.trim(),
        'upiId': upiIdController.text.trim(),
        'invoiceTerms': invoiceTermsController.text.trim(),
        if (beginningDate.value != null)
          'beginningDate': beginningDate.value!.toIso8601String(),
      };

      final updated = await _repository.updateProfile(payload);
      profile.value = updated;
      _populateFields(updated);
      AppSnackbar.success('Business profile updated successfully', title: 'Saved');
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to update business profile';
      AppSnackbar.error(msg, title: 'Save Failed');
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
