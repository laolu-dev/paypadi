import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paypadi/config/gen/colors.gen.dart';
import 'package:paypadi/config/provider_registry/provider_registry.dart';
import 'package:paypadi/config/router/router.gr.dart';
import 'package:paypadi/core/utils/constants.dart';
import 'package:paypadi/core/utils/extensions.dart';
import 'package:paypadi/core/utils/helpers.dart' show formatAmount;
import 'package:paypadi/src/features/home/controller/wallet_controller.dart';
import 'package:paypadi/src/shared/widgets/app_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserWallet extends HookConsumerWidget {
  const UserWallet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletControllerProvider);
    final hideBalance = useState<bool>(true);

    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: Values.v8,
                children: [
                  Text(
                    'Available Balance',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.walletCardTextColor,
                    ),
                  ),
                  InkWell(
                    onTap: () => hideBalance.value = !hideBalance.value,
                    child: Padding(
                      padding: const EdgeInsets.all(Values.v4),
                      child: Icon(
                        hideBalance.value
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: AppColors.walletCardIconColor,
                      ),
                    ),
                  ),
                ],
              ),
              Skeletonizer(
                enabled: wallet.isLoading,
                child: Text(
                  hideBalance.value
                      ? "${wallet.value?.currency ?? "₦"} ****"
                      : "${wallet.value?.currency ?? "₦"} ${formatAmount(wallet.value?.availableBalance)}",
                  style: context.textTheme.headlineSmall,
                ),
              ),

              // Row(
              //   children: [
              //     Text(
              //       "Account no: ${123456789}",
              //       style: context.textTheme.bodyMedium?.copyWith(
              //         fontWeight: FontWeight.w400,
              //         color: AppColors.walletCardTextColor,
              //       ),
              //     ),
              //     InkWell(
              //       onTap: () async {
              //         await Clipboard.setData(
              //           ClipboardData(text: "Data"),
              //         );
              //       },
              //       child: Padding(
              //         padding: EdgeInsets.all(Values.v4),
              //         child: Icon(
              //           Clarity.copy_line,
              //           color: AppColors.walletCardIconColor,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),

          FilledButton.icon(
            onPressed: () =>
                ref.read(appRouterProvider).push(const DepositMoneyRoute()),
            label: const Text('Add Money'),
            // icon: const Icon(Iconsax.add_outline, size: 24),
            style: context.filledButtonTheme.style?.copyWith(
              fixedSize: const WidgetStatePropertyAll(kButtonSmallSize),
              foregroundColor: WidgetStatePropertyAll(
                ref.watch(appPrimaryColorProvider),
              ),
              backgroundColor: WidgetStatePropertyAll(
                ref.watch(appPrimaryColorProvider).withAlpha(20),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  side: BorderSide(
                    color: ref.watch(appPrimaryColorProvider),
                  ),
                  borderRadius: BorderRadiusGeometry.circular(12),
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                context.textTheme.bodySmall?.copyWith(
                  letterSpacing: -0.08,
                  fontWeight: FontWeight.w600,
                  color: ref.watch(appPrimaryColorProvider),
                ),
              ),
            ),
          ),
          // ...[
          //   Expanded(
          //     child: FilledButton.icon(
          //       onPressed: () {},
          //       icon: Icon(Iconsax.add_outline, size: 24),
          //       label: Text("Add Money"),
          //       style: context.filledButtonTheme.style?.copyWith(
          //         fixedSize: WidgetStatePropertyAll(Size(125, 32)),
          //         padding: WidgetStatePropertyAll(
          //           EdgeInsets.symmetric(horizontal: 12),
          //         ),
          //         textStyle: WidgetStatePropertyAll(
          //           context.textTheme.bodySmall?.copyWith(
          //             letterSpacing: -0.08,
          //             fontWeight: FontWeight.w600,
          //             color: AppColors.primary,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // 10.0.verticalSpace,
          //   Expanded(
          //     child: FilledButton.icon(
          //       onPressed: () {},
          //       label: Text("Withdraw"),
          //       icon: Icon(Iconsax.bank_outline),
          //       style: context.filledButtonTheme.style?.copyWith(
          //         fixedSize: WidgetStatePropertyAll(Size(125, 32)),
          //         foregroundColor: WidgetStatePropertyAll(
          //           AppColors.primary,
          //         ),
          //         backgroundColor: WidgetStatePropertyAll(
          //           AppColors.walletCardButtonColor,
          //         ),
          //         padding: WidgetStatePropertyAll(
          //           EdgeInsets.symmetric(horizontal: 12),
          //         ),
          //         shape: WidgetStatePropertyAll(
          //           RoundedRectangleBorder(
          //             side: BorderSide(color: AppColors.primary),
          //             borderRadius: BorderRadiusGeometry.circular(12),
          //           ),
          //         ),
          //         textStyle: WidgetStatePropertyAll(
          //           context.textTheme.bodySmall?.copyWith(
          //             letterSpacing: -0.08,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}
