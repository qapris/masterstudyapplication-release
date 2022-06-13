import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/course/CourseDetailResponse.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';
import 'package:masterstudy_app/data/repository/purchase_repository.dart';
import 'package:masterstudy_app/data/repository/review_respository.dart';

import '../../../data/models/purchase/AllPlansResponse.dart';
import './bloc.dart';

@provide
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CoursesRepository _coursesRepository;
  final ReviewRepository _reviewRepository;
  final PurchaseRepository _purchaseRepository;
  CourseDetailResponse? courseDetailResponse;
  List<AllPlansBean> availablePlans = [];

  // if payment id is -1, selected type is one time payment
  int selectedPaymetId = -1;

  CourseState get initialState => InitialCourseState();

  CourseBloc(this._coursesRepository, this._reviewRepository, this._purchaseRepository) : super(InitialCourseState()) {
    //FetchEvent
    on<FetchEvent>((event, emit) async {
      _fetchCourse(event.courseId);
    });

    //DeleteFromFavorite
    on<DeleteFromFavorite>((event, emit) {
      _fetchCourse(event.courseId);
    });

    //AddToFavorite
    on<AddToFavorite>((event, emit) async {
      try {
        await _coursesRepository.addFavoriteCourse(event.courseId);
        _fetchCourse(event.courseId);
      } catch (error) {
        print(error);
      }
    });

    //VerifyInAppPurchase
    on<VerifyInAppPurchase>((event, emit) async {
      emit(InitialCourseState());
      try {
        await _coursesRepository.verifyInApp(event.serverVerificationData!, event.price!);
      } catch (error) {
        print(error);
      } finally {
        _fetchCourse(event.courseId);
      }
    });

    //PaymentSelectedEvent
    on<PaymentSelectedEvent>((event, emit) {
      selectedPaymetId = event.selectedPaymentId;
      _fetchCourse(event.courseId);
    });

    //UsePlan
    on<UsePlan>((event, emit) async {
      emit(InitialCourseState());
      await _purchaseRepository.usePlan(event.courseId, selectedPaymetId);

      _fetchCourse(event.courseId);
    });

    //AddToCard
    on<AddToCart>((event, emit) async {
      var response = await _purchaseRepository.addToCart(event.courseId);
      emit(OpenPurchaseState(response.cart_url));
    });

    on<GetTokenToCourse>((event, emit) async {
      var response = await _coursesRepository.getTokenToCourse(event.courseId);

      emit(OpenPurchaseDialogState(response));
    });
  }

  Future<CourseState> _fetchCourse(courseId) async {
    if (courseDetailResponse == null || state is ErrorCourseState) emit(InitialCourseState());
    try {
      courseDetailResponse = await _coursesRepository.getCourse(courseId);

      var reviews = await _reviewRepository.getReviews(courseId);

      var plans = await _purchaseRepository.getUserPlans(courseId);

      availablePlans = await _purchaseRepository.getPlans(courseId: courseId);

      emit(LoadedCourseState(courseDetailResponse!, reviews, userPlans: plans));
    } catch (e, s) {
      print(e);
      print(s);
      emit(ErrorCourseState());
    }
    return ErrorCourseState();
  }
}
