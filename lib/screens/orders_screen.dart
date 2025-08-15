import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logistics_app/providers/order_provider.dart';
import 'package:logistics_app/widgets/order_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: orderProvider.orders.isEmpty
                ? const Center(
                    child: Text('Нет заказов'),
                  )
                : ListView.builder(
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: OrderCard(order: order),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
