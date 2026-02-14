import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../../core/api/token_manager.dart';
import '../../../core/core.dart';
import '../../auth/data/models/auth_request.dart';
import '../../auth/data/models/auth_response.dart';
import '../../auth/data/repo/auth_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiService _apiService;
  final AuthRepository _authRepository;
  HomeCubit(this._apiService, this._authRepository) : super(HomeInitial());

  Future<void> loadingData() async {
    safeEmit(HomeLoading());
    Future.delayed(const Duration(seconds: 3), () {
      safeEmit(HomeInitial());
    });
  }

  Future<void> errorState() async {
    safeEmit(
      HomeError(
        ApiErrorModel(
          errorMessage: ErrorData(message: 'timeout'),
          status: false,
        ),
      ),
    );
  }

  Future<Either<ApiErrorModel, AuthResponse>> refreshToken() async {
    try {
      safeEmit(HomeLoading());

      final tokens = await TokenManager.getTokens();
      if (tokens == null) {
        throw Exception('No tokens available for refresh');
      }

      final refreshRequest = AuthRequest.refreshToken(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final response = await _apiService.refreshToken(refreshRequest);

      if (response.isSuccess && response.data != null) {
        await TokenManager.saveTokens(
          accessToken: response.data!.accessToken!,
          refreshToken: response.data!.refreshToken!,
        );
        safeEmit(HomeSuccess(response));
        return Right(response);
      }

      safeEmit(
        HomeError(
          ApiErrorModel(
            errorMessage: ErrorData(message: 'Token refresh failed'),
            status: false,
          ),
        ),
      );
      return Left(
        ApiErrorModel(
          errorMessage: ErrorData(message: 'Token refresh failed'),
          status: false,
        ),
      );
    } catch (e) {
      final error = ApiErrorHandler.handle(e);
      safeEmit(HomeError(error));
      return Left(error);
    }
  }

  // void safeEmit(HomeState state) {
  //   if (!isClosed) emit(state);
  // }
}
