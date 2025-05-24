import 'package:hive/hive.dart';
import 'package:raw_material_management/core/error/failures.dart';

class HiveService<T> {
  final Box<T> box;

  HiveService(this.box);

  Future<void> add(T item) async {
    try {
      await box.add(item);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to add item to local storage',
        code: e.toString(),
      );
    }
  }

  Future<void> put(dynamic key, T item) async {
    try {
      await box.put(key, item);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to update item in local storage',
        code: e.toString(),
      );
    }
  }

  Future<void> delete(dynamic key) async {
    try {
      await box.delete(key);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to delete item from local storage',
        code: e.toString(),
      );
    }
  }

  Future<void> clear() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to clear local storage',
        code: e.toString(),
      );
    }
  }

  T? get(dynamic key) {
    try {
      return box.get(key);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to get item from local storage',
        code: e.toString(),
      );
    }
  }

  List<T> getAll() {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to get all items from local storage',
        code: e.toString(),
      );
    }
  }

  Stream<BoxEvent> watch(dynamic key) {
    try {
      return box.watch(key: key);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to watch item in local storage',
        code: e.toString(),
      );
    }
  }

  Stream<List<T>> watchAll() {
    try {
      return box.watch().map((_) => box.values.toList());
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to watch all items in local storage',
        code: e.toString(),
      );
    }
  }
} 