import 'package:sign/features/requests/domain/entities/request_entity.dart';
import 'package:sign/features/requests/domain/repositories/request_repository.dart';

class SaveRequestUseCase {
  final RequestRepository repository;

  SaveRequestUseCase(this.repository);

  Future<void> call(RequestEntity request) async {
    return await repository.saveRequest(request);
  }
}
