import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/models/course_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/course_state.dart';
import 'package:rafiq/features/course%20mangement/repository/course_repository.dart';

class CourseCubit extends Cubit<CourseState> {
  final CourseRepository repository;

  CourseCubit(this.repository) : super(const CourseInitial());

  List<CourseItemModel> _courses = [];
  String _searchQuery = '';
  int _page = 1;
  bool _hasMore = false;
  static const _pageSize = 20;

  Future<void> loadCourses({bool refresh = false}) async {
    if (refresh && state is CourseLoaded) {
      emit((state as CourseLoaded).copyWith(isRefreshing: true));
    } else {
      emit(const CourseLoading());
    }

    try {
      _page = 1;
      final pageModel = await repository.getCourses(
        page: _page,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _courses = pageModel.courses;
      _hasMore = pageModel.page < pageModel.totalPages;
      emit(
        CourseLoaded(
          courses: _courses,
          filteredCourses: _applyLocalSearch(_courses, _searchQuery),
          searchQuery: _searchQuery,
          page: _page,
          hasMore: _hasMore,
        ),
      );
    } on ApiException catch (e) {
      emit(CourseError(e.message, previousCourses: _courses));
    } catch (_) {
      emit(CourseError('Failed to load courses.', previousCourses: _courses));
    }
  }

  Future<void> loadMore() async {
    if (state is! CourseLoaded) return;
    final current = state as CourseLoaded;
    if (!current.hasMore) return;

    try {
      final nextPage = _page + 1;
      final pageModel = await repository.getCourses(
        page: nextPage,
        pageSize: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _page = nextPage;
      _courses = [..._courses, ...pageModel.courses];
      _hasMore = pageModel.page < pageModel.totalPages;
      emit(
        current.copyWith(
          courses: _courses,
          filteredCourses: _applyLocalSearch(_courses, _searchQuery),
          page: _page,
          hasMore: _hasMore,
        ),
      );
    } on ApiException catch (e) {
      emit(CourseError(e.message, previousCourses: _courses));
    } catch (_) {
      emit(CourseError('Failed to load more courses.', previousCourses: _courses));
    }
  }

  void search(String query) {
    _searchQuery = query.trim();
    if (_courses.isEmpty && state is! CourseLoaded) {
      loadCourses();
      return;
    }
    emit(
      CourseLoaded(
        courses: _courses,
        filteredCourses: _applyLocalSearch(_courses, _searchQuery),
        searchQuery: _searchQuery,
        page: _page,
        hasMore: _hasMore,
      ),
    );
  }

  Future<CourseItemModel?> getCourseById(String courseId) async {
    try {
      return await repository.getCourseById(courseId);
    } catch (_) {
      return null;
    }
  }

  Future<void> enrollCourse(String courseId, String lectureGroupId, String sectionId) async {
    if (state is CourseActionLoading) return; // Prevent duplicate requests
    emit(CourseActionLoading(courses: _courses, action: 'enroll'));
    try {
      await repository.enrollCourse(courseId, lectureGroupId, sectionId);
      // Success is handled by CourseActionSuccess
      emit(CourseActionSuccess(courses: _courses, message: 'تم التسجيل بنجاح'));
      // Note: we don't automatically loadCourses here so we don't overwrite success message, UI will trigger reload
    } on ApiException catch (e) {
      if (e.message.contains('أنت مسجل بالفعل')) {
        emit(CourseActionSuccess(courses: _courses, message: e.message));
      } else {
        emit(CourseError(e.message, previousCourses: _courses));
      }
    } catch (_) {
      emit(CourseError('Failed to enroll in course.', previousCourses: _courses));
    }
  }

  Future<void> dropCourse(String courseId) async {
    emit(CourseActionLoading(courses: _courses, action: 'drop'));
    try {
      await repository.dropCourse(courseId);
      await loadCourses(refresh: true);
    } on ApiException catch (e) {
      emit(CourseError(e.message, previousCourses: _courses));
    } catch (_) {
      emit(CourseError('Failed to drop course.', previousCourses: _courses));
    }
  }

  Future<void> addCourse(CourseItemModel course) async {
    emit(CourseActionLoading(courses: _courses, action: 'add'));
    try {
      await repository.addCourse(course);
      await loadCourses(refresh: true);
    } on ApiException catch (e) {
      emit(CourseError(e.message, previousCourses: _courses));
    } catch (_) {
      emit(CourseError('Failed to add course.', previousCourses: _courses));
    }
  }

  Future<void> updateCourse(CourseItemModel course) async {
    emit(CourseActionLoading(courses: _courses, action: 'update'));
    try {
      await repository.updateCourse(course);
      await loadCourses(refresh: true);
    } on ApiException catch (e) {
      emit(CourseError(e.message, previousCourses: _courses));
    } catch (_) {
      emit(CourseError('Failed to update course.', previousCourses: _courses));
    }
  }

  Future<void> deleteCourse(String courseId) async {
    emit(CourseActionLoading(courses: _courses, action: 'delete'));
    try {
      await repository.deleteCourse(courseId);
      await loadCourses(refresh: true);
    } on ApiException catch (e) {
      emit(CourseError(e.message, previousCourses: _courses));
    } catch (_) {
      emit(CourseError('Failed to delete course.', previousCourses: _courses));
    }
  }

  List<CourseItemModel> _applyLocalSearch(
    List<CourseItemModel> courses,
    String query,
  ) {
    if (query.isEmpty) return courses;
    final lower = query.toLowerCase();
    return courses.where((course) {
      return course.courseCode.toLowerCase().contains(lower) ||
          course.courseTitle.toLowerCase().contains(lower) ||
          course.instructorName.toLowerCase().contains(lower);
    }).toList();
  }
}
