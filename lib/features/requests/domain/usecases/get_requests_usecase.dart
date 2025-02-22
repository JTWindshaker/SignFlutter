import 'package:sign/features/requests/domain/entities/request_entity.dart';
import 'package:sign/features/requests/domain/repositories/request_repository.dart';

class GetRequestsUseCase {
  final RequestRepository repository;

  GetRequestsUseCase(this.repository);

  Future<List<RequestEntity>> call() async {
    return await repository.getRequests();
  }
}
