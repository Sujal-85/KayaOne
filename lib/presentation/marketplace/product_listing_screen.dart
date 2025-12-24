import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/product_provider.dart';
import 'package:medinest/state/cart_provider.dart';
import 'package:medinest/presentation/marketplace/cart_screen.dart';
import 'package:medinest/presentation/marketplace/product_detail_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final String? initialSearchQuery;
  const ProductListingScreen({super.key, this.initialSearchQuery});

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("MediStore",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800, color: AppTheme.darkBlue)),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: AppTheme.darkBlue),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
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
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async {
          setState(() {});
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkBlue.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: AppTheme.primaryGreen, size: 24),
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
                  const SizedBox(height: 24),
                  // Categories
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            _selectedCategory == _categories[index];
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedCategory = _categories[index]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade100),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[index],
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product))),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: AssetImage(product['image']),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product['name'],
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkBlue,
                                fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product['category'],
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  "₹${product['price']}",
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.primaryGreen,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  cartProvider.addItem(
                                      product['id'],
                                      product['name'],
                                      product['price'],
                                      product['image']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "${product['name']} added to cart"),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      size: 18,
                                      color: AppTheme.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
