import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import '../widgets/pro_widgets.dart';
import '../services/api_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<Product> _similarProducts = [];
  bool _isLoadingSimilar = true;

  @override
  void initState() {
    super.initState();
    _fetchSimilarProducts();
  }

  Future<void> _fetchSimilarProducts() async {
    try {
      final products = await ApiService.getProducts(category: widget.product.category);
      if (mounted) {
        setState(() {
          _similarProducts = products.where((p) => p.id != widget.product.id).take(5).toList();
          _isLoadingSimilar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSimilar = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: ResponsiveWrapper(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
        ),
        actions: [
          ResponsiveWrapper(
            onTap: () => _launchUrl(product.mobileLink),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_outlined, size: 22),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGallery(context),
                _buildMainDetails(context),
                _buildSpecifications(context),
                _buildSimilarProducts(context),
                const SizedBox(height: 180), // More space for stacked sticky buttons
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(BuildContext context) {
    final product = widget.product;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 20),
          Hero(
            tag: 'product-${product.id}',
            child: Container(
              height: 180, // Further reduced from 220
              padding: const EdgeInsets.all(16), // Further reduced from 24
              child: ProImage(url: product.img),
            ),
          ),
          if (product.gallery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                height: 50, // Further reduced from 60
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: product.gallery.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 50, // Further reduced from 60
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: ProImage(url: product.gallery[index]),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainDetails(BuildContext context) {
    final product = widget.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Tighter vertical
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  product.brand.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10, // Smaller
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2563EB),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFACC15).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFF854D0E), size: 18), // Smaller
                    const SizedBox(width: 4),
                    Text(
                      product.rating,
                      style: const TextStyle(
                        fontSize: 14, // Smaller
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF854D0E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24, // Further reduced
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          PriceTag(price: product.price, fontSize: 22), // Further reduced
          const SizedBox(height: 24),
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18, // Further reduced
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.desc,
            style: TextStyle(
              fontSize: 14, // Further reduced
              color: Theme.of(context).hintColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(BuildContext context) {
    final product = widget.product;
    final specs = {
      'Battery': product.battery,
      'CPU': product.cpu,
      'RAM': product.ram,
      'Storage': product.storage,
      'Weight': product.weight,
      'Warranty': product.warranty,
    };

    // Filter out empty specifications
    final filteredSpecs = specs.entries.where((e) => e.value.isNotEmpty).toList();

    if (filteredSpecs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 20, // Reduced from 22
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.8, // Further increased for very slim boxes
            mainAxisSpacing: 10, // Reduced from 12
            crossAxisSpacing: 10, // Reduced from 12
            children: filteredSpecs.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced from 14, 10
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16), // Reduced from 20
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 10, // Reduced from 11
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).hintColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14, // Reduced from 15
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts(BuildContext context) {
    if (_isLoadingSimilar) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(strokeWidth: 2),
      ));
    }

    if (_similarProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32), // Reduced from 48
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Similar Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5), // Reduced from 20
          ),
        ),
        const SizedBox(height: 12), // Reduced from 16
        SizedBox(
          height: 140, // Reduced from 160
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _similarProducts.length,
            itemBuilder: (context, index) {
              final p = _similarProducts[index];
              return Container(
                width: 120, // Reduced from 140
                margin: const EdgeInsets.only(right: 10), // Reduced from 12
                child: GlassCard(
                  borderRadius: 20, // Tighter
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: p)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8), // Reduced from 12
                    child: Column(
                      children: [
                        Expanded(child: ProImage(url: p.img)),
                        const SizedBox(height: 6), // Reduced from 10
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11), // Reduced from 12
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStickyActionButtons(BuildContext context) {
    final product = widget.product;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.officialLink.isNotEmpty || product.flipkartLink.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      if (product.officialLink.isNotEmpty)
                        Expanded(
                          child: ProButton(
                            label: 'Official Site',
                            icon: Icons.language_rounded,
                            isPrimary: false,
                            onPressed: () => _launchUrl(product.officialLink),
                          ),
                        ),
                      if (product.officialLink.isNotEmpty && product.flipkartLink.isNotEmpty)
                        const SizedBox(width: 12),
                      if (product.flipkartLink.isNotEmpty)
                        Expanded(
                          child: ProButton(
                            label: 'Flipkart',
                            icon: Icons.shopping_bag_outlined,
                            isPrimary: false,
                            onPressed: () => _launchUrl(product.flipkartLink),
                          ),
                        ),
                    ],
                  ),
                ),
              Row(
                children: [
                  ValueListenableBuilder<List<Product>>(
                    valueListenable: compareNotifier,
                    builder: (context, list, _) {
                      final isAdded = list.any((p) => p.id == product.id);
                      return Container(
                        decoration: BoxDecoration(
                          color: isAdded ? const Color(0xFF2563EB) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final newList = List<Product>.from(compareNotifier.value);
                            if (isAdded) {
                              newList.removeWhere((p) => p.id == product.id);
                            } else {
                              if (newList.length >= 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Maximum 8 products for comparison'))
                                );
                                return;
                              }
                              newList.add(product);
                            }
                            compareNotifier.value = newList;

                            // Auto-save comparison list
                            final prefs = await SharedPreferences.getInstance();
                            final idList = newList.map((p) => p.id).toList();
                            await prefs.setStringList('compare_list', idList);
                          },
                          icon: Icon(
                            isAdded ? Icons.check_rounded : Icons.compare_arrows_rounded,
                            color: isAdded ? Colors.white : const Color(0xFF2563EB),
                          ),
                          padding: const EdgeInsets.all(18),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ProButton(
                      label: 'Buy on Amazon',
                      icon: Icons.shopping_cart_outlined,
                      onPressed: () => _launchUrl(product.amazonLink),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
