import 'dart:async';

import 'package:paypadi/config/provider_registry/provider_registry.dart';
import 'package:paypadi/config/router/router.gr.dart';
import 'package:paypadi/core/repositories/authentication/i_authentication_repository.dart';
import 'package:paypadi/core/utils/constants.dart';
import 'package:paypadi/core/utils/extensions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_controller.g.dart';

@Riverpod(keepAlive: true)
Map<String, dynamic> authenticationPayload(Ref ref) => <String, dynamic>{};

@riverpod
class AuthenticationController extends _$AuthenticationController {
  late final IAuthenticationRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(authenticationRepositoryProvider);
  }

  Future<void> login(String phoneNumber, String password) async {
    state = const AsyncLoading();

    final result = await _repository.login({
      'phone_number': phoneNumber,
      'password': password,
    });

    await result.fold(
      (response) async {
        await Future.wait([
          ref.read(notificationsServiceProvider).requestPermission(),

          _saveSession(
            refreshToken: response.data.refreshToken,
            accessToken: response.data.accessToken,
            refreshExpiry: response.data.refreshTokenExpiry,
            accessExpiry: response.data.accessTokenExpiry,
          ),

          _saveToCache(CacheKeys.phoneNumber, phoneNumber),
          _saveToCache(CacheKeys.password, password),
        ]);

        ref.read(notificationsServiceProvider).onTokenRefresh.listen((token) {
          token.printLog();
        });

        state = const AsyncData(null);
        await ref.read(appRouterProvider).push(const DashboardRoute());
      },
      (exception) {
        ref.showExceptionMessage(exception);
        state = const AsyncData(null);
      },
    );
  }

  Future<void> register() async {
    state = const AsyncLoading();
    final payload = ref.watch(authenticationPayloadProvider);

    final result = await _repository.createAccount(payload);

    await result.fold(
      (response) async {
        await _saveSession(
          refreshToken: response.data.refreshToken,
          accessToken: response.data.accessToken,
          refreshExpiry: response.data.refreshTokenExpiry,
          accessExpiry: response.data.accessTokenExpiry,
        );

        state = const AsyncData(null);
        await ref
            .read(appRouterProvider)
            .push(const CreateTransactionPinRoute());
      },
      (failure) {
        ref.showExceptionMessage(failure);
        state = const AsyncData(null);
      },
    );
  }

  Future<void> requestForOtp() async {
    state = const AsyncLoading();
    final payloadBuilder = ref.watch(authenticationPayloadProvider);

    final result = await _repository.requestForOtpCode({
      'phone_number': payloadBuilder['phone_number'],
      'purpose': 'registration',
    });

    await result.fold(
      (success) async {
        await ref.read(appRouterProvider).push(const OtpRoute());
        state = const AsyncData(null);
      },
      (failure) {
        ref.showExceptionMessage(failure);
        state = const AsyncData(null);
      },
    );
  }

  Future<void> verifyOtpCode(String code) async {
    state = const AsyncLoading();
    final payloadBuilder = ref.watch(authenticationPayloadProvider);

    final result = await _repository.verifyOtpCode({
      'phone_number': payloadBuilder['phone_number'],
      'purpose': 'registration',
      'code': code,
    });

    await result.fold(
      (success) async {
        final payload = ref.watch(authenticationPayloadProvider);

        payload['phone_token'] = success.data.token;

        await ref.read(appRouterProvider).push(const AccountRoleRoute());
        state = const AsyncData(null);
      },
      (failure) {
        ref.showExceptionMessage(failure);
        state = const AsyncData(null);
      },
    );
  }

  Future<void> loginWithBiometrics() async {
    final biometricService = ref.watch(biometricsProvider);

    try {
      final didAuthenticate = await biometricService.authenticate();

      if (didAuthenticate) {
        final phoneNumber = await ref
            .read(secureCacheProvider)
            .get<String?>(CacheKeys.phoneNumber);
        final password = await ref
            .read(secureCacheProvider)
            .get<String?>(CacheKeys.password);

        if (phoneNumber == null || password == null) return;

        await login(phoneNumber, password);
      }
    } catch (exception) {
      ref.showExceptionMessage(exception);
      state = const AsyncData(null);
    }
  }

  Future<void> logout() async {
    final localCache = await ref.read(localCacheProvider.future);
    await localCache.clear();

    await ref.read(secureCacheProvider).clear();

    await ref
        .read(appRouterProvider)
        .pushAndPopUntil(
          const SignInRoute(),
          predicate: (route) => route.settings.name == '/sign-in',
        );
  }

  Future<void> _saveToCache(String key, String value) async {
    await ref.read(secureCacheProvider).save(key: key, value: value);
  }

  Future<void> _saveSession({
    required String refreshToken,
    required String accessToken,
    required int refreshExpiry,
    required int accessExpiry,
  }) async {
    await ref
        .read(secureCacheProvider)
        .save(key: CacheKeys.refreshToken, value: refreshToken);

    await ref
        .read(secureCacheProvider)
        .save(key: CacheKeys.accessToken, value: accessToken);
  }
}
