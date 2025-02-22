import 'package:sign/features/requests/data/datasources/local/requests_local_datasource.dart';
import 'package:sign/features/requests/domain/repositories/request_repository.dart';
import 'package:sign/features/requests/domain/entities/request_entity.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestLocalDatasource datasource;

  RequestRepositoryImpl(this.datasource);

  @override
  Future<void> saveRequest(RequestEntity request) async {
    await datasource.saveRequest(request);
  }

  @override
  Future<List<RequestEntity>> getRequests() async {
    return await datasource.getRequests();
  }
}
