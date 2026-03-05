import 'package:get_it/get_it.dart';
import 'injection.dart' as injection;

final locator = GetIt.instance;

void setupLocator() {
  injection.setupLocator();
}