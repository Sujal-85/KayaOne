import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/product_provider.dart';
import 'package:kayaone/state/cart_provider.dart';
import 'package:kayaone/presentation/marketplace/cart_screen.dart';
import 'package:kayaone/presentation/marketplace/product_detail_screen.dart';
import 'package:kayaone/presentation/home/home_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final bool isMainTab;

  const ProductListingScreen({
    super.key,
    this.initialSearchQuery,
    this.isMainTab = false,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String _selectedCategory = "All";
  final List<String> _categories = ["All", "Medicine", "Devices", "Wellness"];
  late TextEditingController _searchController;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? "";
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    // Get base products by category
    var products = productProvider.getProductsByCategory(_selectedCategory);

    // Apply specific search filter if query exists
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) =>
              p['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              p['category']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Stack(
        children: [
          // 1. Leafy Header (Background)
          Container(
            height: 280, // Taller header to accommodate search bar
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              image: DecorationImage(
                image: AssetImage('assets/images/home_bg_leaves.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // 2. Body
          RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () async {
              setState(() {});
            },
            child: Column(
              children: [
                // Custom AppBar Area
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (widget.isMainTab) {
                                  HomeScreenState.of(context)?.setIndex(0);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    size: 18),
                              ),
                            ),
                            Text("Products",
                                style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255))),
                            // Cart Icon
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const CartScreen())),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10)
                                        ]),
                                    child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: AppTheme.darkBlue,
                                        size: 20),
                                  ),
                                ),
                                if (cartProvider.itemCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      child: Text(
                                        cartProvider.itemCount.toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Search Bar
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.darkBlue.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded,
                                  color: Colors.grey, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Search medications, devices...",
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.darkBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Content Body
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // Categories
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              bool isSelected =
                                  _selectedCategory == _categories[index];
                              return GestureDetector(
                                onTap: () => setState(() =>
                                    _selectedCategory = _categories[index]),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.grey.shade200),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _categories[index],
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Product Grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.65, // Taller aspect ratio for details
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductCard(
                                  product, cartProvider, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      Map<String, dynamic> product, CartProvider cartProvider, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Area
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Image.asset(
                    product['image'],
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, _) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
                // Rating Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "4.8",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Details Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkBlue,
                          fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['category'],
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "₹${product['price']}",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "₹${(product['price'] * 1.2).toInt()}", // Fake original price
                          style: GoogleFonts.plusJakartaSans(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[400],
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Action Buttons
                    Row(
                      children: [
                        // Add to Cart
                        GestureDetector(
                          onTap: () {
                            cartProvider.addItem(product['id'], product['name'],
                                product['price'], product['image']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("${product['name']} added to cart"),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppTheme.primaryGreen,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppTheme.primaryGreen),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.shopping_cart_outlined,
                                size: 16, color: AppTheme.primaryGreen),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Buy Now (Expanded)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: Text(
                              "Buy Now",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
