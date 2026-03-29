part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? category;
  final String? search;
  final int page;

  const LoadProducts({this.category, this.search, this.page = 1});

  @override
  List<Object?> get props => [category, search, page];
}

class LoadProductDetail extends ProductEvent {
  final String id;
  const LoadProductDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCategories extends ProductEvent {}
