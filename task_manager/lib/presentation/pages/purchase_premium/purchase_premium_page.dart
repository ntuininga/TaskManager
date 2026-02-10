import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_cubit.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Unlock Premium',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('• Unlimited categories'),
                Text('• Custom themes'),
                Text('• Future premium features'),
                Text('• One-time purchase'),
              ],
            ),
            TextButton(
                onPressed: () {
                  context.read<PurchaseCubit>().buyPremium();
                },
                child: const Text("Upgrade to Premium"))
          ],
        ),
      ),
    );
  }
}
