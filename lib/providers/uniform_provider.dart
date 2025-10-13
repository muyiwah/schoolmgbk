import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/uniform_model.dart';
import 'package:schmgtsystem/repository/class_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class UniformState {
  final List<UniformModel> uniforms;
  final bool isLoading;
  final String? errorMessage;

  UniformState({
    this.uniforms = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  UniformState copyWith({
    List<UniformModel>? uniforms,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UniformState(
      uniforms: uniforms ?? this.uniforms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UniformNotifier extends StateNotifier<UniformState> {
  final ClassRepo _classRepo;

  UniformNotifier(this._classRepo) : super(UniformState());

  Future<void> loadClassUniforms(String classId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _classRepo.getClassUniforms(classId);

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final uniformResponse = UniformResponseModel.fromJson(response.data);
        state = state.copyWith(
          uniforms: uniformResponse.uniforms,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Failed to load uniforms',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading uniforms: $e',
      );
    }
  }

  void clearUniforms() {
    state = UniformState();
  }
}

final uniformProvider = StateNotifierProvider<UniformNotifier, UniformState>((
  ref,
) {
  return UniformNotifier(ClassRepo());
});
