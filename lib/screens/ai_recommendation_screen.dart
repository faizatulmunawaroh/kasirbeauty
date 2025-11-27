import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/product.dart';

class RecommendationData {
  final Product product;
  final double confidence;
  final String reason;
  final String category;
  final bool isTrending;
  final bool isPersonalized;

  RecommendationData({
    required this.product,
    required this.confidence,
    required this.reason,
    required this.category,
    this.isTrending = false,
    this.isPersonalized = false,
  });
}

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _budgetController = TextEditingController();
  List<RecommendationData> _recommendations = [];
  bool _isLoading = false;
  String _recommendationType = 'smart';
  double _maxBudget = 500000;
  String _selectedCategory = 'All';
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  // User preferences and behavior tracking
  Map<String, int> _userPreferences = {};
  Map<String, int> _categoryInteractions = {};
  List<String> _recentSearches = [];
  Set<String> _favoriteProducts = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserPreferences();
    _generateInitialRecommendations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadUserPreferences() {
    // Load user preferences from local storage or initialize defaults
    _userPreferences = {
      'Makeup': 8,
      'Skincare': 9,
      'Fashion': 6,
      'Accessories': 7,
      'Hair Care': 5,
      'Fragrance': 4,
    };

    _categoryInteractions = {
      'Makeup': 15,
      'Skincare': 20,
      'Fashion': 10,
      'Accessories': 12,
      'Hair Care': 8,
      'Fragrance': 6,
    };

    _recentSearches = ['lipstick', 'moisturizer', 'dress', 'perfume'];
    _favoriteProducts = {'1', '3', '5'}; // Product IDs
  }

  void _generateInitialRecommendations() {
    // Generate smart recommendations on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getRecommendations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _budgetController.dispose();
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(seconds: 2));

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final allProducts = productProvider.products;
      final transactions = transactionProvider.transactions;

      List<RecommendationData> recommendations = [];

      switch (_recommendationType) {
        case 'smart':
          recommendations = await _generateSmartRecommendations(allProducts, transactions);
          break;

        case 'personalized':
          recommendations = await _generatePersonalizedRecommendations(allProducts, transactions);
          break;

        case 'trending':
          recommendations = await _generateTrendingRecommendations(allProducts, transactions);
          break;

        case 'seasonal':
          recommendations = await _generateSeasonalRecommendations(allProducts);
          break;

        case 'budget':
          final budget = double.tryParse(_budgetController.text) ?? _maxBudget;
          recommendations = await _generateBudgetRecommendations(allProducts, budget);
          break;

        case 'cross_sell':
          recommendations = await _generateCrossSellRecommendations(allProducts, transactions);
          break;

        default:
          recommendations = await _generateSmartRecommendations(allProducts, transactions);
      }

      // Sort by confidence score
      recommendations.sort((a, b) => b.confidence.compareTo(a.confidence));

      setState(() {
        _recommendations = recommendations.take(8).toList();
      });

      _animationController.forward(from: 0.0);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<RecommendationData>> _generateSmartRecommendations(
    List<Product> allProducts,
    List<dynamic> transactions,
  ) async {
    final recommendations = <RecommendationData>[];

    // Analyze transaction patterns
    final productPopularity = <String, int>{};
    final categoryPopularity = <String, int>{};

    for (final transaction in transactions) {
      for (final item in transaction.items) {
        productPopularity[item.product.id] = ((productPopularity[item.product.id] ?? 0) + item.quantity.toInt()).toInt();
        categoryPopularity[item.product.category] = ((categoryPopularity[item.product.category] ?? 0) + item.quantity.toInt()).toInt();
      }
    }

    // Calculate confidence scores for each product
    for (final product in allProducts) {
      double confidence = 0.0;
      String reason = '';

      // Popularity score (0-40 points)
      final popularity = productPopularity[product.id] ?? 0;
      confidence += min(popularity * 8.0, 40.0);

      // Category preference score (0-20 points)
      final categoryPref = _userPreferences[product.category] ?? 5;
      confidence += (categoryPref / 10) * 20;

      // Price optimization score (0-15 points)
      if (product.price >= 10000 && product.price <= 100000) {
        confidence += 15;
        reason = 'Optimal price range for quality products';
      } else if (product.price < 10000) {
        confidence += 8;
        reason = 'Budget-friendly option';
      }

      // Stock availability score (0-10 points)
      if (product.stock > 20) {
        confidence += 10;
      } else if (product.stock > 5) {
        confidence += 5;
      }

      // Category trending score (0-15 points)
      final categoryTrend = categoryPopularity[product.category] ?? 0;
      confidence += min(categoryTrend * 3.0, 15.0);

      if (confidence > 20) {
        recommendations.add(RecommendationData(
          product: product,
          confidence: confidence,
          reason: reason.isEmpty ? 'Based on popularity and user preferences' : reason,
          category: product.category,
          isTrending: popularity > 5,
          isPersonalized: categoryPref > 7,
        ));
      }
    }

    return recommendations;
  }

  Future<List<RecommendationData>> _generatePersonalizedRecommendations(
    List<Product> allProducts,
    List<dynamic> transactions,
  ) async {
    final recommendations = <RecommendationData>[];

    // Analyze user's purchase history and preferences
    final userPurchases = <String, int>{};
    final userCategories = <String, int>{};

    for (final transaction in transactions.take(10)) { // Last 10 transactions
      for (final item in transaction.items) {
        userPurchases[item.product.id] = ((userPurchases[item.product.id] ?? 0) + item.quantity.toInt()).toInt();
        userCategories[item.product.category] = ((userCategories[item.product.category] ?? 0) + item.quantity.toInt()).toInt();
      }
    }

    // Find most purchased category
    final topCategory = userCategories.entries
        .fold<MapEntry<String, int>?>(null, (prev, curr) => prev == null || curr.value > prev.value ? curr : prev)
        ?.key ?? 'Makeup';

    // Recommend products from preferred categories
    for (final product in allProducts) {
      if (product.category == topCategory && !_favoriteProducts.contains(product.id)) {
        final confidence = 85.0 + (Random().nextDouble() * 10); // High confidence for personalized
        recommendations.add(RecommendationData(
          product: product,
          confidence: confidence,
          reason: 'Based on your purchase history in ${product.category}',
          category: product.category,
          isPersonalized: true,
        ));
      }
    }

    return recommendations;
  }

  Future<List<RecommendationData>> _generateTrendingRecommendations(
    List<Product> allProducts,
    List<dynamic> transactions,
  ) async {
    final recommendations = <RecommendationData>[];

    // Analyze last 7 days
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentTransactions = transactions.where((t) => t.date.isAfter(weekAgo)).toList();

    final trendingProducts = <String, int>{};
    for (final transaction in recentTransactions) {
      for (final item in transaction.items) {
        trendingProducts[item.product.id] = ((trendingProducts[item.product.id] ?? 0) + item.quantity.toInt()).toInt();
      }
    }

    // Get top trending products
    final sortedTrending = trendingProducts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedTrending.take(6)) {
      final product = allProducts.firstWhere((p) => p.id == entry.key);
      final confidence = 70.0 + (entry.value * 5.0) + (Random().nextDouble() * 10);

      recommendations.add(RecommendationData(
        product: product,
        confidence: confidence,
        reason: 'Trending this week - ${entry.value} units sold',
        category: product.category,
        isTrending: true,
      ));
    }

    return recommendations;
  }

  Future<List<RecommendationData>> _generateSeasonalRecommendations(
    List<Product> allProducts,
  ) async {
    final recommendations = <RecommendationData>[];
    final now = DateTime.now();
    final month = now.month;

    // Seasonal recommendations based on month
    List<String> seasonalKeywords;
    String seasonReason;

    if (month >= 3 && month <= 5) { // Spring
      seasonalKeywords = ['floral', 'light', 'fresh', 'bright'];
      seasonReason = 'Spring collection - fresh and floral scents';
    } else if (month >= 6 && month <= 8) { // Summer
      seasonalKeywords = ['tropical', 'bright', 'sunscreen', 'light'];
      seasonReason = 'Summer essentials - tropical and bright colors';
    } else if (month >= 9 && month <= 11) { // Fall
      seasonalKeywords = ['warm', 'earthy', 'rich', 'cozy'];
      seasonReason = 'Fall favorites - warm and earthy tones';
    } else { // Winter
      seasonalKeywords = ['rich', 'deep', 'luxury', 'warm'];
      seasonReason = 'Winter luxury - rich and deep colors';
    }

    for (final product in allProducts) {
      final productName = product.name.toLowerCase();
      final matchesSeason = seasonalKeywords.any((keyword) => productName.contains(keyword));

      if (matchesSeason || Random().nextDouble() > 0.7) { // 30% random seasonal picks
        final confidence = 60.0 + (Random().nextDouble() * 20);
        recommendations.add(RecommendationData(
          product: product,
          confidence: confidence,
          reason: seasonReason,
          category: product.category,
        ));
      }
    }

    return recommendations.take(6).toList();
  }

  Future<List<RecommendationData>> _generateBudgetRecommendations(
    List<Product> allProducts,
    double budget,
  ) async {
    final recommendations = <RecommendationData>[];

    final budgetProducts = allProducts.where((p) => p.price <= budget).toList();
    budgetProducts.sort((a, b) => b.price.compareTo(a.price)); // Best value first

    for (final product in budgetProducts.take(8)) {
      final confidence = 75.0 + (Random().nextDouble() * 15);
      final savings = budget - product.price;
      final reason = savings > 50000
          ? 'Great value - save Rp ${savings.toStringAsFixed(0)}'
          : 'Budget-friendly option within your range';

      recommendations.add(RecommendationData(
        product: product,
        confidence: confidence,
        reason: reason,
        category: product.category,
      ));
    }

    return recommendations;
  }

  Future<List<RecommendationData>> _generateCrossSellRecommendations(
    List<Product> allProducts,
    List<dynamic> transactions,
  ) async {
    final recommendations = <RecommendationData>[];

    // Find products that are often bought together
    final productPairs = <String, Map<String, int>>{};

    for (final transaction in transactions) {
      final productIds = transaction.items.map((item) => item.product.id).toList();
      for (int i = 0; i < productIds.length; i++) {
        for (int j = i + 1; j < productIds.length; j++) {
          final productA = productIds[i];
          final productB = productIds[j];

          productPairs.putIfAbsent(productA, () => {});
          productPairs[productA]![productB] = (productPairs[productA]![productB] ?? 0) + 1;

          productPairs.putIfAbsent(productB, () => {});
          productPairs[productB]![productA] = (productPairs[productB]![productA] ?? 0) + 1;
        }
      }
    }

    // Generate cross-sell recommendations
    for (final entry in productPairs.entries) {
      final mainProduct = allProducts.firstWhere((p) => p.id == entry.key);
      final relatedProducts = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final related in relatedProducts.take(2)) {
        final relatedProduct = allProducts.firstWhere((p) => p.id == related.key);
        final confidence = 65.0 + (related.value * 8.0) + (Random().nextDouble() * 10);

        recommendations.add(RecommendationData(
          product: relatedProduct,
          confidence: confidence,
          reason: 'Often bought with ${mainProduct.name}',
          category: relatedProduct.category,
        ));
      }
    }

    return recommendations.take(6).toList();
  }

  void _addToCart(RecommendationData recommendation) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(recommendation.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${recommendation.product.name} added to cart'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite(RecommendationData recommendation) {
    setState(() {
      if (_favoriteProducts.contains(recommendation.product.id)) {
        _favoriteProducts.remove(recommendation.product.id);
      } else {
        _favoriteProducts.add(recommendation.product.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Beauty Recommendations'),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getRecommendations,
            tooltip: 'Refresh Recommendations',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFE91E63)),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'AI is analyzing your preferences...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.pink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // AI Header Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.pink.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.shade100.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  AnimatedBuilder(
                                    animation: _fabScaleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _fabScaleAnimation.value,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.smart_toy,
                                            color: Colors.pink.shade600,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Beauty Assistant',
                                          style: TextStyle(
                                            color: Colors.pink.shade800,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Personalized recommendations just for you',
                                          style: TextStyle(
                                            color: Colors.pink.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.trending_up,
                                                color: Colors.pink.shade600,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${_recommendations.length} recommendations',
                                                style: TextStyle(
                                                  color: Colors.pink.shade800,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Recommendation Type Selector
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.tune,
                                        color: Colors.pink.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Choose Recommendation Type',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildRecommendationTypeChip('Smart AI', 'smart', Icons.auto_awesome),
                                      _buildRecommendationTypeChip('Personalized', 'personalized', Icons.person),
                                      _buildRecommendationTypeChip('Trending', 'trending', Icons.trending_up),
                                      _buildRecommendationTypeChip('Seasonal', 'seasonal', Icons.wb_sunny),
                                      _buildRecommendationTypeChip('Budget', 'budget', Icons.attach_money),
                                      _buildRecommendationTypeChip('Cross-sell', 'cross_sell', Icons.add_shopping_cart),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Search and Budget Inputs
                            if (_recommendationType == 'budget') ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _budgetController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Maximum Budget (Rp)',
                                    prefixIcon: Icon(
                                      Icons.attach_money,
                                      color: Colors.pink.shade400,
                                    ),
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Recommendations Grid
                    if (_recommendations.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final recommendation = _recommendations[index];
                              return _buildRecommendationCard(recommendation, index);
                            },
                            childCount: _recommendations.length,
                          ),
                        ),
                      ),
                    ] else ...[
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lightbulb_outline,
                                  size: 60,
                                  color: Colors.pink.shade300,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No recommendations yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap refresh to get AI-powered suggestions',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _getRecommendations,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Get Recommendations'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.shade600,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Bottom padding
                    const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRecommendationTypeChip(String label, String type, IconData icon) {
    final isSelected = _recommendationType == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.pink.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.pink.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _recommendationType = type);
          _getRecommendations();
        }
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.pink.shade600,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.pink.shade600 : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationData recommendation, int index) {
    final isFavorite = _favoriteProducts.contains(recommendation.product.id);

    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image/Icon Placeholder
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(recommendation.category).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            _getCategoryIcon(recommendation.category),
                            size: 48,
                            color: _getCategoryColor(recommendation.category),
                          ),
                        ),
                        // Confidence Score
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade500.withValues(alpha: 1.0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${recommendation.confidence.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Favorite Button
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: () => _toggleFavorite(recommendation),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // Trending Badge
                        if (recommendation.isTrending)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'Hot',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${recommendation.product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stock: ${recommendation.product.stock}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Reason
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            recommendation.reason,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _addToCart(recommendation),
                            icon: const Icon(Icons.add_shopping_cart, size: 14),
                            label: const Text(
                              'Add to Cart',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makeup':
        return Colors.pink.shade400;
      case 'skincare':
        return Colors.blue.shade400;
      case 'fashion':
        return Colors.purple.shade400;
      case 'accessories':
        return Colors.orange.shade400;
      case 'hair care':
        return Colors.green.shade400;
      case 'fragrance':
        return Colors.indigo.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makeup':
        return Icons.brush;
      case 'skincare':
        return Icons.spa;
      case 'fashion':
        return Icons.checkroom;
      case 'accessories':
        return Icons.watch;
      case 'hair care':
        return Icons.content_cut;
      case 'fragrance':
        return Icons.local_florist;
      default:
        return Icons.shopping_bag;
    }
  }
}