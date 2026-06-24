import 'package:rafiq/features/course%20mangement/models/course_model.dart';

sealed class CourseState {
  const CourseState();
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

class CourseLoaded extends CourseState {
  final List<CourseItemModel> courses;
  final List<CourseItemModel> filteredCourses;
  final String searchQuery;
  final int page;
  final bool hasMore;
  final bool isRefreshing;

  const CourseLoaded({
    required this.courses,
    required this.filteredCourses,
    this.searchQuery = '',
    this.page = 1,
    this.hasMore = false,
    this.isRefreshing = false,
  });

  CourseLoaded copyWith({
    List<CourseItemModel>? courses,
    List<CourseItemModel>? filteredCourses,
    String? searchQuery,
    int? page,
    bool? hasMore,
    bool? isRefreshing,
  }) {
    return CourseLoaded(
      courses: courses ?? this.courses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class CourseActionLoading extends CourseState {
  final List<CourseItemModel> courses;
  final String action;

  const CourseActionLoading({
    required this.courses,
    required this.action,
  });
}

class CourseError extends CourseState {
  final String message;
  final List<CourseItemModel>? previousCourses;

  const CourseError(this.message, {this.previousCourses});
}

class CourseActionSuccess extends CourseState {
  final List<CourseItemModel> courses;
  final String message;

  const CourseActionSuccess({
    required this.courses,
    required this.message,
  });
}
