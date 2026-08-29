import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  GoogleLoginUseCase({required this.repository});

  final AuthRepository repository;

  Future<AuthEntity?> call() => repository.signInWithGoogle();
}
