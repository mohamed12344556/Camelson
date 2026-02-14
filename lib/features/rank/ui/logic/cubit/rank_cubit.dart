import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'rank_state.dart';

class RankCubit extends Cubit<RankState> {
  RankCubit() : super(RankInitial());
}
