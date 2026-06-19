import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:paypadi/core/utils/constants.dart';
import 'package:paypadi/core/utils/extensions.dart';
import 'package:paypadi/src/features/authentication/controller/authentication_controller.dart';
import 'package:paypadi/src/shared/widgets/app_avatar.dart';
import 'package:paypadi/src/shared/widgets/app_keypad.dart';
import 'package:paypadi/src/shared/widgets/app_pin_indicator.dart';
import 'package:paypadi/src/shared/widgets/app_scaffold.dart';

@RoutePage()
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwordController = useTextEditingController();

    // final enabledBiometrics = useState<bool>(
    //   ref.read(localCacheProvider).getFromCache(CacheKeys.enabledBiometrics) ??
    //       false,
    // );

    // final user = ref
    //     .watch(localCacheProvider)
    //     .getFromCache<UserModel>(
    //       CacheKeys.user,
    //       (raw) => UserModel.fromJson(raw as Map<String, dynamic>),
    //     );

    ref.listen(authenticationControllerProvider, (previous, current) {
      current.when(
        data: (d) => ref.dismissLoading(),
        error: (e, st) => ref.dismissLoading(),
        loading: () => ref.showLoading(),
      );
    });

    return AppScaffold(
      showAppBar: false,
      // topPadding: kTopPadding,
      // bottomPadding: Values.v24,
      child: Column(
        children: [
          const AppAvatar(radius: Values.v84, imageUrl: kDemoProfilePic),
          Values.v16.verticalSpace,
          // Text(
          //   "Good ${getDayTime()}, ${user?.firstName ?? ""}",
          //   style: context.textTheme.headlineSmall,
          // ),
          Values.v24.verticalSpace,
          AppPinIndicator(
            pinLength: passwordPinLength,
            controller: passwordController,
          ),
          const Spacer(flex: 2),
          AppKeypad(
            keyLength: passwordPinLength,
            controller: passwordController,
            // showBiometric: enabledBiometrics.value,
            onBiometricKeyPressed: () => ref
                .read(authenticationControllerProvider.notifier)
                .loginWithBiometrics(),
            // onSubmit: (password) => ref
            //     .read(authenticationControllerProvider.notifier)
            //     .login(user?.phoneNumber ?? '', password),
          ),
          const Spacer(),
          Center(
            child: GestureDetector(
              // onTap: () => ref
              //     .read(appRouterProvider)
              //     .push(ForgotPasswordRoute(email: user?.email ?? '')),
              child: Text(
                'Forgot Password?',
                style: context.textTheme.bodyMedium?.copyWith(
                  letterSpacing: -Values.v1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
