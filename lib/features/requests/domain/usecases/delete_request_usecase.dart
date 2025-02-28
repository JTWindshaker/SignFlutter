import 'package:sign/features/requests/domain/repositories/request_repository.dart';

class DeleteRequestUseCase {
  final RequestRepository repository;

  DeleteRequestUseCase(this.repository);

  Future<void> call(int idRequest) async {
    await repository.deleteRequest(idRequest);
  }
}