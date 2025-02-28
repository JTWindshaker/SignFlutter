import 'package:sign/features/requests/domain/entities/request_entity.dart';

abstract class RequestRepository {
  Future<void> saveRequest(RequestEntity request);
  Future<List<RequestEntity>> getRequests();
  Future<void> deleteRequest(int idRequest);
}
