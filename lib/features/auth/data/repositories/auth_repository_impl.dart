import 'package:corrige_ai/features/auth/domain/entities/user_entity.dart';
import 'package:corrige_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:corrige_ai/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  UserEntity? _currentUser;

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula tempo de rede/servidor
    if (email.isEmpty || password.length < 6) {
      throw Exception('E-mail ou senha inválidos.');
    }
    _currentUser = UserModel(
      id: 'prof_001',
      name: email.split('@').first,
      email: email,
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (name.isEmpty || email.isEmpty || password.length < 6) {
      throw Exception('Por favor, preencha todos os campos corretamente.');
    }
    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }
}