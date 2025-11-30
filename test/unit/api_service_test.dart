import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_getx_app/services/api_service.dart';
import 'package:flutter_getx_app/models/restful_object.dart';
import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ApiService apiService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('ApiService', () {
    test('getObjects returns list of RestfulObject on 200 OK', () async {
      // Arrange
      when(mockClient.get(Uri.parse('https://api.restful-api.dev/objects')))
          .thenAnswer((_) async => http.Response(
              '[{"id": "1", "name": "Google Pixel 6 Pro", "data": {"color": "Cloudy White", "capacity": "128 GB"}}]',
              200));

      // Act
      final result = await apiService.getObjects();

      // Assert
      expect(result, isA<List<RestfulObject>>());
      expect(result.length, 1);
      expect(result.first.name, 'Google Pixel 6 Pro');
    });

    test('getObjects throws ApiException on 404', () async {
      // Arrange
      when(mockClient.get(Uri.parse('https://api.restful-api.dev/objects')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(apiService.getObjects(), throwsA(isA<ApiException>()));
    });
  });
}
