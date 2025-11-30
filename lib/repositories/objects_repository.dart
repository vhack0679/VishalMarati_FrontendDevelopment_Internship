import '../models/restful_object.dart';
import '../services/api_service.dart';

class ObjectsRepository {
  final ApiService _apiService;

  ObjectsRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  Future<List<RestfulObject>> getAllObjects() async {
    return await _apiService.getObjects();
  }

  Future<RestfulObject> getObjectDetails(String id) async {
    return await _apiService.getObject(id);
  }

  Future<RestfulObject> addObject(String name, Map<String, dynamic> data) async {
    return await _apiService.createObject(name, data);
  }

  Future<RestfulObject> updateObject(String id, String name, Map<String, dynamic> data) async {
    return await _apiService.updateObject(id, name, data);
  }

  Future<void> deleteObject(String id) async {
    return await _apiService.deleteObject(id);
  }
}
