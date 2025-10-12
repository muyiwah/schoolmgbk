import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/parent_login_response_model.dart';
import 'package:schmgtsystem/repository/auth_repo.dart';
import 'package:schmgtsystem/repository/parent_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentLoginState {
  final ParentLoginResponse? parentLoginData;
  final bool isLoading;
  final String? errorMessage;

  ParentLoginState({
    this.parentLoginData,
    this.isLoading = false,
    this.errorMessage,
  });

  ParentLoginState copyWith({
    ParentLoginResponse? parentLoginData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ParentLoginState(
      parentLoginData: parentLoginData ?? this.parentLoginData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ParentLoginProvider extends StateNotifier<ParentLoginState> {
  final _authRepo = locator<AuthRepo>();
  final _parentRepo = locator<ParentRepo>();

  ParentLoginProvider() : super(ParentLoginState());

  void setParentLoginData(ParentLoginResponse data) {
    print('🔍 DEBUG: Setting parent login data');
    print('🔍 DEBUG: Data success: ${data.success}');
    print('🔍 DEBUG: Data message: ${data.message}');
    print('🔍 DEBUG: Data is null: false');
    print('🔍 DEBUG: Data.data is null: ${data.data == null}');

    // Enhanced parent info logging
    if (data.data != null) {
      final parentData = data.data!;
      print('🔍 DEBUG: ===== PARENT LOGIN INFO =====');

      // Parent basic info
      if (parentData.parent != null) {
        final parent = parentData.parent!;
        print('🔍 DEBUG: Parent ID: ${parent.id}');
        print(
          '🔍 DEBUG: Parent Name: ${parent.personalInfo?.firstName} ${parent.personalInfo?.lastName}',
        );
        print('🔍 DEBUG: Parent Email: ${parent.contactInfo?.email}');
        print('🔍 DEBUG: Parent Phone: ${parent.contactInfo?.primaryPhone}');
        print('🔍 DEBUG: Parent Title: ${parent.personalInfo?.title}');
        print('🔍 DEBUG: Parent Status: Active');
      }

      // Parent financial info
      if (parentData.financialSummary != null) {
        final financialSummary = parentData.financialSummary!;
        print('🔍 DEBUG: Total Fees: ${financialSummary.totalFees}');
        print(
          '🔍 DEBUG: Total Amount Paid: ${financialSummary.totalAmountPaid}',
        );
        print(
          '🔍 DEBUG: Total Amount Owed: ${financialSummary.totalAmountOwed}',
        );
        print(
          '🔍 DEBUG: Payment Completion: ${financialSummary.paymentCompletion}%',
        );
        print(
          '🔍 DEBUG: Children with Outstanding Fees: ${financialSummary.childrenWithOutstandingFees}',
        );
      }

      // Current term info
      if (parentData.currentTerm != null) {
        final currentTerm = parentData.currentTerm!;
        print('🔍 DEBUG: Current Academic Year: ${currentTerm.academicYear}');
        print('🔍 DEBUG: Current Term: ${currentTerm.term}');
        print(
          '🔍 DEBUG: Current Term Status: ${currentTerm.status ?? 'No status'}',
        );
        print('🔍 DEBUG: Amount Owed: ${currentTerm.amountOwed}');
      }

      // Children detailed info
      print('🔍 DEBUG: Children count: ${parentData.children?.length ?? 0}');
      if (parentData.children != null) {
        for (int i = 0; i < parentData.children!.length; i++) {
          final child = parentData.children![i];
          print('🔍 DEBUG: ----- Child $i -----');
          print('🔍 DEBUG: Child ID: ${child.student?.id}');
          print(
            '🔍 DEBUG: Child Name: ${child.student?.personalInfo?.firstName} ${child.student?.personalInfo?.lastName}',
          );
          print(
            '🔍 DEBUG: Child Admission Number: ${child.student?.admissionNumber}',
          );

          // Child academic info
          if (child.student?.academicInfo != null) {
            final academicInfo = child.student!.academicInfo!;
            print('🔍 DEBUG: Child Class: ${academicInfo.currentClass?.name}');
            print('🔍 DEBUG: Child Level: ${academicInfo.currentClass?.level}');
            print(
              '🔍 DEBUG: Child Academic Year: ${academicInfo.academicYear}',
            );
          }

          // Child current term info
          if (child.currentTerm != null) {
            final childCurrentTerm = child.currentTerm!;
            print('🔍 DEBUG: Child Current Term: ${childCurrentTerm.term}');
            print(
              '🔍 DEBUG: Child Academic Year: ${childCurrentTerm.academicYear}',
            );
            print(
              '🔍 DEBUG: Child Amount Owed: ${childCurrentTerm.amountOwed}',
            );

            // Fee record info
            if (childCurrentTerm.feeRecord != null) {
              final feeRecord = childCurrentTerm.feeRecord!;
              print('🔍 DEBUG: Fee Record ID: ${feeRecord.id}');
              print(
                '🔍 DEBUG: Fee Record Status: ${feeRecord.status ?? 'No status'}',
              );
              print('🔍 DEBUG: Fee Record Balance: ${feeRecord.balance}');
              print(
                '🔍 DEBUG: Fee Record Amount Paid: ${feeRecord.amountPaid}',
              );

              // Fee details
              if (feeRecord.feeDetails != null) {
                final feeDetails = feeRecord.feeDetails!;
                print('🔍 DEBUG: Base Fee: ${feeDetails.baseFee}');
                print('🔍 DEBUG: Total Fee: ${feeDetails.totalFee}');
                print(
                  '🔍 DEBUG: Add-ons count: ${feeDetails.addOns?.length ?? 0}',
                );

                if (feeDetails.addOns != null &&
                    feeDetails.addOns!.isNotEmpty) {
                  for (int j = 0; j < feeDetails.addOns!.length; j++) {
                    final addOn = feeDetails.addOns![j];
                    print(
                      '🔍 DEBUG: Add-on $j: ${addOn.name} - £${addOn.amount} (${addOn.compulsory == true ? 'Required' : 'Optional'})',
                    );
                  }
                }
              }

              // Payments info
              print(
                '🔍 DEBUG: Payments count: ${feeRecord.payments?.length ?? 0}',
              );
              if (feeRecord.payments != null &&
                  feeRecord.payments!.isNotEmpty) {
                for (int k = 0; k < feeRecord.payments!.length; k++) {
                  final payment = feeRecord.payments![k];
                  // Handle payment as Map since it's dynamic
                  if (payment is Map<String, dynamic>) {
                    print(
                      '🔍 DEBUG: Payment $k: ${payment['status']} - £${payment['amount']} (${payment['date']})',
                    );
                  } else {
                    print('🔍 DEBUG: Payment $k: $payment');
                  }
                }
              }
            }
          }

          // Fee summary removed - not available in new model

          print('🔍 DEBUG: -------------------------');
        }
      }

      print('🔍 DEBUG: ===== END PARENT LOGIN INFO =====');
    }

    state = state.copyWith(
      parentLoginData: data,
      isLoading: false,
      errorMessage: null,
    );

    print('🔍 DEBUG: Parent login data set successfully');
    print(
      '🔍 DEBUG: State after setting: ${state.parentLoginData?.data?.children?.length}',
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, isLoading: false);
  }

  Future<bool> refreshDataFromDashboard() async {
    try {
      print('🔍 DEBUG: ===== STARTING PARENT DASHBOARD REFRESH =====');
      setLoading(true);

      // Get parent ID from SharedPreferences (stored during login)
      String? parentId;
      final prefs = await SharedPreferences.getInstance();
      parentId = prefs.getString('parent_id');

      if (parentId == null) {
        print('🔍 DEBUG: No parent ID found in SharedPreferences');
        print('🔍 DEBUG: User needs to log in again to get parent ID');
        setError('Unable to determine parent ID. Please log in again.');
        return false;
      }

      print('🔍 DEBUG: Found parent ID: $parentId');
      print('🔍 DEBUG: Fetching dashboard for parent ID: $parentId');
      print('🔍 DEBUG: ===== CALLING PARENT DASHBOARD ENDPOINT =====');
      print('🔍 DEBUG: Endpoint: GET /api/parents/$parentId');
      print(
        '🔍 DEBUG: Repository method: _parentRepo.getParentDashboard($parentId)',
      );

      // Call the dashboard endpoint with parent ID
      final response = await _parentRepo.getParentDashboard(parentId);

      print('🔍 DEBUG: ===== PARENT DASHBOARD ENDPOINT RESPONSE =====');
      print('🔍 DEBUG: Response code: ${response.code}');
      print(
        '🔍 DEBUG: Response success: ${HTTPResponseModel.isApiCallSuccess(response)}',
      );
      print('🔍 DEBUG: Response message: ${response.message}');

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        print('🔍 DEBUG: Dashboard API call successful');
        print('🔍 DEBUG: Raw dashboard data: ${response.data}');

        try {
          final parentLoginData = ParentLoginResponse.fromJson(response.data);

          // Debug the parsed data structure
          print('🔍 DEBUG: Parsed parentLoginData: $parentLoginData');
          if (parentLoginData.data?.children != null) {
            print(
              '🔍 DEBUG: Number of children: ${parentLoginData.data!.children!.length}',
            );
            for (int i = 0; i < parentLoginData.data!.children!.length; i++) {
              final child = parentLoginData.data!.children![i];
              print('🔍 DEBUG: Child $i:');
              print('🔍 DEBUG:   currentTerm: ${child.currentTerm}');
              print(
                '🔍 DEBUG:   currentTerm?.status: ${child.currentTerm?.status}',
              );
              print(
                '🔍 DEBUG:   currentTerm?.feeRecord: ${child.currentTerm?.feeRecord}',
              );
              print(
                '🔍 DEBUG:   currentTerm?.feeRecord?.feeDetails: ${child.currentTerm?.feeRecord?.feeDetails}',
              );
            }
          }

          setParentLoginData(parentLoginData);
          print('🔍 DEBUG: Dashboard data set successfully');
          print('🔍 DEBUG: ===== END PARENT DASHBOARD REFRESH (SUCCESS) =====');
          return true;
        } catch (parseError) {
          print('🔍 DEBUG: Dashboard parsing error: $parseError');
          setError('Error parsing dashboard data: ${parseError.toString()}');
          return false;
        }
      } else {
        print('🔍 DEBUG: Dashboard API call failed: ${response.message}');
        setError(response.message ?? 'Failed to fetch dashboard data');
        return false;
      }
    } catch (e) {
      print('🔍 DEBUG: Dashboard refresh error: $e');
      setError('Error refreshing dashboard: ${e.toString()}');
      return false;
    }
  }

  Future<bool> refreshData() async {
    try {
      print('🔍 DEBUG: ===== STARTING PARENT DATA REFRESH =====');
      print('🔍 DEBUG: Starting refreshData');
      setLoading(true);
      print('🔍 DEBUG: Loading state set to true');

      // Get saved credentials from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');

      print('🔍 DEBUG: Saved email: ${email != null ? 'Found' : 'Not found'}');
      print('🔍 DEBUG: Saved email value: ${email ?? 'null'}');
      print(
        '🔍 DEBUG: Saved password: ${password != null ? 'Found' : 'Not found'}',
      );

      if (email == null || password == null) {
        print('🔍 DEBUG: No saved credentials found');
        setError('No saved credentials found');
        print('🔍 DEBUG: ===== END PARENT DATA REFRESH (NO CREDENTIALS) =====');
        return false;
      }

      // Create login body
      final loginBody = {'email': email, 'password': password};
      print('🔍 DEBUG: Attempting login with saved credentials');
      print(
        '🔍 DEBUG: Login body: {email: ${email.substring(0, email.indexOf('@'))}@..., password: ***}',
      );

      // Call login API
      print('🔍 DEBUG: ===== CALLING PARENT LOGIN ENDPOINT =====');
      print('🔍 DEBUG: Endpoint: POST /api/auth/login');
      print('🔍 DEBUG: Repository method: _authRepo.login(loginBody)');
      print('🔍 DEBUG: Calling auth repository login method');
      final response = await _authRepo.login(loginBody);

      print('🔍 DEBUG: ===== PARENT LOGIN ENDPOINT RESPONSE =====');
      print('🔍 DEBUG: Login API call completed');
      print(
        '🔍 DEBUG: Login response success: ${HTTPResponseModel.isApiCallSuccess(response)}',
      );
      print('🔍 DEBUG: Login response code: ${response.code}');
      print('🔍 DEBUG: Login response message: ${response.message}');

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        // Parse and set the new data
        print('🔍 DEBUG: Raw response data: ${response.data}');
        try {
          // Add detailed logging for children data structure
          if (response.data is Map<String, dynamic>) {
            final dataMap = response.data as Map<String, dynamic>;
            print('🔍 DEBUG: Response data structure:');
            dataMap.forEach((key, value) {
              print('  $key: ${value.runtimeType}');
              if (key == 'data' && value is Map<String, dynamic>) {
                print('    data keys: ${value.keys.toList()}');
                if (value['parentDetails'] is Map<String, dynamic>) {
                  final parentDetails =
                      value['parentDetails'] as Map<String, dynamic>;
                  print(
                    '    parentDetails keys: ${parentDetails.keys.toList()}',
                  );
                  if (parentDetails['children'] is List) {
                    final children = parentDetails['children'] as List;
                    print('    children count: ${children.length}');
                    if (children.isNotEmpty) {
                      print(
                        '    first child keys: ${children.first is Map ? (children.first as Map).keys.toList() : 'not a map'}',
                      );
                    }
                  }
                }
              }
            });
          }

          // Validate that the response has the expected structure
          if (response.data is! Map<String, dynamic>) {
            throw Exception(
              'Invalid response format: expected Map but got ${response.data.runtimeType}',
            );
          }

          final dataMap = response.data as Map<String, dynamic>;
          if (!dataMap.containsKey('data')) {
            throw Exception('Response missing data field');
          }

          final data = dataMap['data'];
          if (data is! Map<String, dynamic>) {
            throw Exception(
              'Invalid data format: expected Map but got ${data.runtimeType}',
            );
          }

          if (!data.containsKey('parentDetails')) {
            throw Exception('Response missing parentDetails field');
          }

          final parentLoginData = ParentLoginResponse.fromJson(response.data);
          print(
            '🔍 DEBUG: Parsed refresh data success: ${parentLoginData.success}',
          );
          print('🔍 DEBUG: Calling setParentLoginData with parsed data');
          setParentLoginData(parentLoginData);
          print('🔍 DEBUG: Parent login data set successfully');
          print('🔍 DEBUG: ===== END PARENT DATA REFRESH (SUCCESS) =====');
          return true;
        } catch (parseError) {
          print('🔍 DEBUG: Parsing error details: $parseError');
          print('🔍 DEBUG: Parse error type: ${parseError.runtimeType}');
          if (parseError is TypeError) {
            print('🔍 DEBUG: TypeError stack trace: ${parseError.stackTrace}');
          }
          // Don't rethrow, just set error and return false
          setError('Error parsing refresh data: ${parseError.toString()}');
          print('🔍 DEBUG: ===== END PARENT DATA REFRESH (PARSE ERROR) =====');
          return false;
        }
      } else {
        print('🔍 DEBUG: Login failed: ${response.message}');
        setError(response.message ?? 'Failed to refresh data');
        print('🔍 DEBUG: ===== END PARENT DATA REFRESH (LOGIN FAILED) =====');
        return false;
      }
    } catch (e) {
      print('🔍 DEBUG: Refresh data error: $e');
      print('🔍 DEBUG: Error type: ${e.runtimeType}');
      print('🔍 DEBUG: Error details: ${e.toString()}');
      if (e is TypeError) {
        print('🔍 DEBUG: TypeError details: ${e.toString()}');
      }
      setError('Error refreshing data: ${e.toString()}');
      print('🔍 DEBUG: ===== END PARENT DATA REFRESH (EXCEPTION) =====');
      return false;
    } finally {
      setLoading(false);
      print('🔍 DEBUG: Loading state set to false');
    }
  }

  // Helper methods to access nested data
  User? get currentUser => state.parentLoginData?.data?.parent?.user;
  Parent? get currentParent => state.parentLoginData?.data?.parent;
  List<Child>? get children {
    final childrenList = state.parentLoginData?.data?.children;
    print(
      '🔍 DEBUG: Children getter called, returning ${childrenList?.length ?? 0} children',
    );
    return childrenList;
  }

  FinancialSummary? get financialSummary =>
      state.parentLoginData?.data?.financialSummary;
  List<dynamic>? get communications =>
      state.parentLoginData?.data?.communications;
  CurrentTerm? get currentTerm => state.parentLoginData?.data?.currentTerm;
}
