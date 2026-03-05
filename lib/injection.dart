import 'package:get_it/get_it.dart';
import 'package:sticky_notes_app/services/storage_service_interface.dart';
import 'package:sticky_notes_app/services/storage_service.dart';
import 'package:sticky_notes_app/services/single_instance_service_interface.dart';
import 'package:sticky_notes_app/services/single_instance_service.dart';
import 'package:sticky_notes_app/providers/notes_provider.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register services - usando factory para inicialização assíncrona
  locator.registerLazySingleton<StorageServiceInterface>(() => StorageService());
  
  // Register providers
  locator.registerLazySingleton<NotesProvider>(() => NotesProvider());
}

void resetLocator() {
  locator.reset();
}

void setupTestLocator({StorageServiceInterface? mockStorageService}) {
  resetLocator();
  
  if (mockStorageService != null) {
    locator.registerSingleton<StorageServiceInterface>(mockStorageService);
  } else {
    locator.registerLazySingleton<StorageServiceInterface>(() => StorageService());
  }
  
  locator.registerLazySingleton<NotesProvider>(
    () => NotesProvider(storageService: locator<StorageServiceInterface>())
  );
}

/// Helper para testes - registra múltiplos mocks
void setupTestLocatorWithMocks({
  StorageServiceInterface? mockStorageService,
  SingleInstanceServiceInterface? mockSingleInstanceService,
}) {
  resetLocator();
  
  if (mockStorageService != null) {
    locator.registerSingleton<StorageServiceInterface>(mockStorageService);
  } else {
    locator.registerLazySingleton<StorageServiceInterface>(() => StorageService());
  }
  
  if (mockSingleInstanceService != null) {
    locator.registerSingleton<SingleInstanceServiceInterface>(mockSingleInstanceService);
  } else {
    locator.registerLazySingleton<SingleInstanceServiceInterface>(() => SingleInstanceService());
  }
  
  locator.registerLazySingleton<NotesProvider>(
    () => NotesProvider(storageService: locator<StorageServiceInterface>())
  );
}