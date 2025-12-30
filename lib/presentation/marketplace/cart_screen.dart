import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/cart_provider.dart';
import 'package:kayaone/presentation/booking/booking_success_screen.dart';
import 'package:kayaone/data/services/notification_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("My Cart",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800, color: AppTheme.darkBlue)),
      ),
      body: cartProvider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Your cart is empty",
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items.values.toList()[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10)
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                    image: AssetImage(item.image),
                                    fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.darkBlue)),
                                  Text("₹${item.price}",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryGreen)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _qtyBtn(
                                    Icons.remove,
                                    () =>
                                        cartProvider.removeSingleItem(item.id)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(item.quantity.toString(),
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800)),
                                ),
                                _qtyBtn(
                                    Icons.add,
                                    () => cartProvider.addItem(item.id,
                                        item.name, item.price, item.image)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5))
                    ],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount",
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600)),
                          Text(
                              "₹${cartProvider.totalAmount.toStringAsFixed(0)}",
                              style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.darkBlue)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Notification
                          NotificationService().showNotification(
                            title: "Order Placed! 🛍️",
                            body:
                                "Your order of ₹${cartProvider.totalAmount.toStringAsFixed(0)} has been successfully placed.",
                          );

                          cartProvider.clearCart();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const BookingSuccessScreen()),
                            (route) => route.isFirst,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 64),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text("Checkout Now",
                            style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: AppTheme.darkBlue),
      ),
    );
  }
}
