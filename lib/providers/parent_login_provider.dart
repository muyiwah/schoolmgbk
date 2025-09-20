import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/parent_login_model.dart';
import 'package:schmgtsystem/repository/auth_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentLoginState {
  final ParentLoginModel? parentLoginData;
  final bool isLoading;
  final String? errorMessage;

  ParentLoginState({
    this.parentLoginData,
    this.isLoading = false,
    this.errorMessage,
  });

  ParentLoginState copyWith({
    ParentLoginModel? parentLoginData,
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

  ParentLoginProvider() : super(ParentLoginState());

  void setParentLoginData(ParentLoginModel data) {
    state = state.copyWith(
      parentLoginData: data,
      isLoading: false,
      errorMessage: null,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error, isLoading: false);
  }

  void clearData() {
    state = ParentLoginState();
  }

  Future<bool> refreshData() async {
    try {
      setLoading(true);

      // Get saved credentials from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final password = prefs.getString('password');

      if (email == null || password == null) {
        setError('No saved credentials found');
        return false;
      }

      // Create login body
      final loginBody = {'email': email, 'password': password};

      // Call login API
      final response = await _authRepo.login(loginBody);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        // Parse and set the new data
        final parentLoginData = ParentLoginModel.fromJson(response.data);
        setParentLoginData(parentLoginData);
        return true;
      } else {
        setError(response.message ?? 'Failed to refresh data');
        return false;
      }
    } catch (e) {
      setError('Error refreshing data: ${e.toString()}');
      return false;
    }
  }

  // Helper methods to access nested data
  User? get currentUser => state.parentLoginData?.data?.user;
  Parent? get currentParent =>
      state.parentLoginData?.data?.parentDetails?.parent;
  List<Child>? get children =>
      state.parentLoginData?.data?.parentDetails?.children;
  FinancialSummary? get financialSummary =>
      state.parentLoginData?.data?.parentDetails?.financialSummary;
  List<Communication>? get communications =>
      state.parentLoginData?.data?.parentDetails?.communications;
  CurrentTerm? get currentTerm =>
      state.parentLoginData?.data?.parentDetails?.currentTerm;
}
