import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_cubit.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_state.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state.status == PurchaseStatusState.premium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Welcome to Premium!')),
          );
          Navigator.pop(context);
        }
        if (state.status == PurchaseStatusState.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Purchase failed. Please try again.'),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == PurchaseStatusState.loading;
        final isPremium = state.status == PurchaseStatusState.premium;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Go Premium'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 72,
                    color: isPremium ? Colors.amber : Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPremium ? 'You\'re Premium!' : 'Unlock Premium',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPremium
                        ? 'You have full access to all features.'
                        : 'Remove limits and get the most out of your tasks.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  const _FeatureItem(
                    icon: Icons.category,
                    text: 'Unlimited categories',
                  ),
                  const _FeatureItem(
                    icon: Icons.update,
                    text: 'All future premium features',
                  ),
                  const _FeatureItem(
                    icon: Icons.lock_open,
                    text: 'One-time purchase — no subscriptions',
                  ),
                  const Spacer(),
                  if (!isPremium) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () => context.read<PurchaseCubit>().buyPremium(),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pay once. Own it forever.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                  if (isPremium)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 48),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child:
                Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}