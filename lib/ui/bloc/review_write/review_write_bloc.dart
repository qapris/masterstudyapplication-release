import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/ReviewAddResponse.dart';
import 'package:masterstudy_app/data/models/account.dart';
import 'package:masterstudy_app/data/repository/account_repository.dart';
import 'package:masterstudy_app/data/repository/review_respository.dart';
import './bloc.dart';

@provide
class ReviewWriteBloc extends Bloc<ReviewWriteEvent, ReviewWriteState> {
  final AccountRepository _accountRepository;
  final ReviewRepository _reviewRepository;
  late Account accountObj;

  ReviewWriteState get initialState => InitialReviewWriteState();

  ReviewWriteBloc(this._accountRepository, this._reviewRepository) : super(InitialReviewWriteState()) {
    on<SaveReviewEvent>((event, emit) async {
      try {
        ReviewAddResponse reviewAddResponse = await _reviewRepository.addReview(event.id, event.mark, event.review);

        emit(ReviewResponseState(reviewAddResponse, accountObj));
      } catch (error) {
        print(error);
      }
    });

    on<FetchEvent>((event, emit) async {
      try {
        Account account = await _accountRepository.getUserAccount();
        accountObj = account;
        emit(LoadedReviewWriteState(account));
      } catch (error) {
        print('Account resp error');
        print(error);
      }
    });
  }
}
