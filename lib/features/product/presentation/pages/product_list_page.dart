// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:shop_app/core/router/app_router.dart';
// import 'package:shop_app/features/cart/presentation/bloc/cart_bloc.dart';
// import '../../../../core/di/injection.dart';
// import '../bloc/product_bloc.dart';
// import '../widgets/product_card.dart';

// class ProductListPage extends StatefulWidget {
//   const ProductListPage({super.key});

//   @override
//   State<ProductListPage> createState() => _ProductListPageState();
// }

// class _ProductListPageState extends State<ProductListPage> {
//   String? _selectedCategory;
//   final _searchCtrl = TextEditingController();

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => getIt<ProductBloc>()..add(const LoadProducts()),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F5F5),
//         appBar: AppBar(
//           title: Text(
//             'Sản phẩm',
//             style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//           ),
//           actions: [
//             BlocBuilder<CartBloc, CartState>(
//               builder: (context, state) => Stack(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.shopping_cart_outlined),
//                     onPressed: () => context.push(AppRoutes.cart),
//                   ),
//                   if (state.totalItems > 0)
//                     Positioned(
//                       right: 6,
//                       top: 6,
//                       child: Container(
//                         width: 16,
//                         height: 16,
//                         decoration: const BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${state.totalItems}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         body: BlocBuilder<ProductBloc, ProductState>(
//           builder: (context, state) {
//             if (state is ProductLoading) return _buildShimmer();
//             if (state is ProductError) {
//               return Center(child: Text(state.message));
//             }
//             if (state is ProductListLoaded) {
//               return Column(
//                 children: [
//                   _buildSearchBar(context),
//                   _buildCategories(context, state.categories),
//                   Expanded(child: _buildGrid(state)),
//                 ],
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       child: TextField(
//         controller: _searchCtrl,
//         decoration: InputDecoration(
//           hintText: 'Tìm kiếm sản phẩm...',
//           prefixIcon: const Icon(Icons.search),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               _searchCtrl.clear();
//               context.read<ProductBloc>().add(
//                 LoadProducts(category: _selectedCategory),
//               );
//             },
//           ),
//           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
//         ),
//         onSubmitted: (val) {
//           context.read<ProductBloc>().add(
//             LoadProducts(category: _selectedCategory, search: val),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCategories(BuildContext context, List<String> categories) {
//     final all = ['Tất cả', ...categories];
//     return SizedBox(
//       height: 40.h,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         itemCount: all.length,
//         itemBuilder: (_, i) {
//           final cat = all[i];
//           final isSelected =
//               (cat == 'Tất cả' && _selectedCategory == null) ||
//               cat == _selectedCategory;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedCategory = cat == 'Tất cả' ? null : cat;
//               });
//               context.read<ProductBloc>().add(
//                 LoadProducts(
//                   category: _selectedCategory,
//                   search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
//                 ),
//               );
//             },
//             child: Container(
//               margin: EdgeInsets.only(right: 8.w),
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               decoration: BoxDecoration(
//                 color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: isSelected
//                       ? const Color(0xFF6C63FF)
//                       : Colors.grey.shade300,
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   cat,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: isSelected ? Colors.white : Colors.grey,
//                     fontWeight: isSelected
//                         ? FontWeight.w600
//                         : FontWeight.normal,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildGrid(ProductListLoaded state) {
//     return GridView.builder(
//       padding: EdgeInsets.all(16.w),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.72,
//         crossAxisSpacing: 12.w,
//         mainAxisSpacing: 12.h,
//       ),
//       itemCount: state.products.length,
//       itemBuilder: (_, i) => ProductCard(product: state.products[i]),
//     );
//   }

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.builder(
//         padding: EdgeInsets.all(16.w),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.72,
//           crossAxisSpacing: 12.w,
//           mainAxisSpacing: 12.h,
//         ),
//         itemCount: 6,
//         itemBuilder: (_, __) => Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shop_app/core/router/app_router.dart';
import 'package:shop_app/features/cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(const LoadProducts()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Sản phẩm',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) => Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.cart),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF1A1A2E),
                        size: 24,
                      ),
                      if (state.totalItems > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${state.totalItems}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) return _buildShimmer();
            if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            if (state is ProductListLoaded) {
              return Column(
                children: [
                  _buildSearchBar(context),
                  _buildCategories(context, state.categories),
                  Expanded(child: _buildGrid(state)),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade400,
              size: 20,
            ),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                      context.read<ProductBloc>().add(
                        LoadProducts(category: _selectedCategory),
                      );
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 16.w,
            ),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (val) {
            context.read<ProductBloc>().add(
              LoadProducts(
                category: _selectedCategory,
                search: val.isEmpty ? null : val,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<String> categories) {
    final all = ['Tất cả', ...categories];
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: all.length,
        itemBuilder: (_, i) {
          final cat = all[i];
          final isSelected =
              (cat == 'Tất cả' && _selectedCategory == null) ||
              cat == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat == 'Tất cả' ? null : cat;
              });
              context.read<ProductBloc>().add(
                LoadProducts(
                  category: _selectedCategory,
                  search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade200,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(ProductListLoaded state) {
    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text(
              'Không tìm thấy sản phẩm',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: state.products.length,
      itemBuilder: (_, i) => ProductCard(product: state.products[i]),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
