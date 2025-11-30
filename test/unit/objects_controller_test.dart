import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_getx_app/controllers/objects_controller.dart';
import 'package:flutter_getx_app/repositories/objects_repository.dart';
import 'package:flutter_getx_app/models/restful_object.dart';
import 'objects_controller_test.mocks.dart';

@GenerateMocks([ObjectsRepository])
void main() {
  late ObjectsController controller;
  late MockObjectsRepository mockRepository;

  setUp(() {
    mockRepository = MockObjectsRepository();
    controller = ObjectsController(repository: mockRepository);
  });

  group('ObjectsController', () {
    test('fetchObjects populates objects list on success', () async {
      // Arrange
      final objects = [
        RestfulObject(id: '1', name: 'Test Object', data: null)
      ];
      when(mockRepository.getAllObjects()).thenAnswer((_) async => objects);

      // Act
      await controller.fetchObjects();

      // Assert
      expect(controller.objects.length, 1);
      expect(controller.objects.first.name, 'Test Object');
      expect(controller.isLoading.value, false);
    });

    test('createObject returns true and adds to list on success', () async {
      // Arrange
      final newObj = RestfulObject(id: '2', name: 'New Object', data: {});
      when(mockRepository.addObject(any, any)).thenAnswer((_) async => newObj);

      // Act
      final result = await controller.createObject('New Object', {});

      // Assert
      expect(result, true);
      expect(controller.objects.length, 1); // Assuming list was empty
      expect(controller.objects.first.id, '2');
    });
  });
}
