import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/course/CourseDetailResponse.dart';
import 'package:masterstudy_app/data/models/purchase/UserPlansResponse.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';
import 'package:masterstudy_app/data/repository/purchase_repository.dart';
import 'package:masterstudy_app/data/repository/review_respository.dart';

import './bloc.dart';

@provide
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CoursesRepository _coursesRepository;
  final ReviewRepository _reviewRepository;
  final PurchaseRepository _purchaseRepository;
  CourseDetailResponse? courseDetailResponse;
  List<UserPlansBean> availablePlans = [];

  // if payment id is -1, selected type is one time payment
  int selectedPaymetId = -1;

  CourseState get initialState => InitialCourseState();

  CourseBloc(this._coursesRepository, this._reviewRepository, this._purchaseRepository) : super(InitialCourseState()) {
    on<CourseEvent>((event, emit) async {
      await _getCourse(event, emit);
    });
  }

  Future<void> _getCourse(CourseEvent event, Emitter<CourseState> emit) async {
    if (event is FetchEvent) {
      _fetchCourse(event.courseId);
    }

    if (event is DeleteFromFavorite) {
      _fetchCourse(event.courseId);
    }

    if (event is AddToFavorite) {
      try {
        await _coursesRepository.addFavoriteCourse(event.courseId);
        _fetchCourse(event.courseId);
      } catch (error) {
        print(error);
      }
    }

    if (event is VerifyInAppPurchase) {
      emit(InitialCourseState());
      try {
        await _coursesRepository.verifyInApp(event.serverVerificationData!, event.price!);
      } catch (error) {
        print(error);
      } finally {
        _fetchCourse(event.courseId);
      }
    }

    if (event is PaymentSelectedEvent) {
      selectedPaymetId = event.selectedPaymentId;
      _fetchCourse(event.courseId);
    }

    if (event is UsePlan) {
      emit(InitialCourseState());
      await _purchaseRepository.usePlan(event.courseId, selectedPaymetId);

      _fetchCourse(event.courseId);
    }

    if (event is AddToCart) {
      var response = await _purchaseRepository.addToCart(event.courseId);
      emit(OpenPurchaseState(response.cart_url));
    }
  }

  Future<CourseState> _fetchCourse(courseId) async {
    if (courseDetailResponse == null || state is ErrorCourseState) emit(InitialCourseState());
    try {
      courseDetailResponse = await _coursesRepository.getCourse(courseId);
      var reviews = await _reviewRepository.getReviews(courseId);
      // var plans = await _purchaseRepository.getUserPlans();
      availablePlans = await _purchaseRepository.getPlans();
      emit(LoadedCourseState(courseDetailResponse!, reviews, []/*plans*/));
    } catch (e, s) {
      print(e);
      print(s);
      emit(ErrorCourseState());
    }
    return ErrorCourseState();
  }
}
