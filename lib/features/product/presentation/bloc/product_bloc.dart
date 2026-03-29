import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/core/usecases/usecases.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'product_event.dart';
part 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductDetailUseCase,
    required this.getCategoriesUseCase,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetail>(_onLoadProductDetail);
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final categoriesResult = await getCategoriesUseCase(NoParams());
    final categories = categoriesResult.fold((_) => <String>[], (c) => c);

    final productsResult = await getProductsUseCase(
      GetProductsParams(
        category: event.category,
        search: event.search,
        page: event.page,
      ),
    );

    productsResult.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) =>
          emit(ProductListLoaded(products: products, categories: categories)),
    );
  }

  Future<void> _onLoadProductDetail(
    LoadProductDetail event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getProductDetailUseCase(event.id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ProductState> emit,
  ) async {
    final result = await getCategoriesUseCase(NoParams());
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (categories) =>
          emit(ProductListLoaded(products: const [], categories: categories)),
    );
  }
}
