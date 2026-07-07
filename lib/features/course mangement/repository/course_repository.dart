import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/course_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/course_model.dart';

class CourseRepository {
  final CourseRemoteDataSource remoteDataSource;

  const CourseRepository(this.remoteDataSource);

  Future<CoursesPageModel> getCourses({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final items = await remoteDataSource.getCourses(
        page: page,
        pageSize: pageSize,
        search: search,
      );
      return CoursesPageModel.fromList(items);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load courses.');
    }
  }

  Future<CourseItemModel> getCourseById(String courseId) async {
    try {
      final data = await remoteDataSource.getCourseById(courseId);
      return CourseItemModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load course details.');
    }
  }

  Future<void> enrollCourse(String courseId, String sectionId) async {
    try {
      await remoteDataSource.enrollCourse(courseId, sectionId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to enroll in course.');
    }
  }

  Future<void> dropCourse(String courseId) async {
    try {
      await remoteDataSource.dropCourse(courseId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to drop course.');
    }
  }

  Future<CourseItemModel> addCourse(CourseItemModel course) async {
    try {
      final data = await remoteDataSource.addCourse(course.toRequestJson());
      return CourseItemModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to add course.');
    }
  }

  Future<CourseItemModel> updateCourse(CourseItemModel course) async {
    try {
      final data = await remoteDataSource.updateCourse(
        course.id,
        course.toRequestJson(),
      );
      return CourseItemModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to update course.');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await remoteDataSource.deleteCourse(courseId);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to delete course.');
    }
  }
}
