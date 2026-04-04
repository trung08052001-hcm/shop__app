import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? address;
  final String? phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.address,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, avatar, address, phone];
}
