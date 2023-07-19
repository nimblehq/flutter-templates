import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_view_state.freezed.dart';

@freezed
class MainViewState with _$MainViewState {
  const factory MainViewState.init() = _Init;
}
