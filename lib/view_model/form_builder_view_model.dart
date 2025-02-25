import 'package:cupcake/utils/form/abstract_form_element.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

part 'form_builder_view_model.g.dart';

class FormBuilderViewModel = FormBuilderViewModelBase with _$FormBuilderViewModel;

abstract class FormBuilderViewModelBase with ViewModel, Store {
  FormBuilderViewModelBase({
    required this.formElements,
    required this.scaffoldContext,
    final void Function(String? suggestedTitle)? onLabelChange,
    final void Function(bool val)? toggleIsPinSet,
    required final bool isPinSet,
    required this.showExtra,
  })  : _onLabelChange = onLabelChange,
        _toggleIsPinSet = toggleIsPinSet,
        _isPinSet = isPinSet;

  // Used to force a rebuild
  @observable
  int currentPageDoNotUse = 0;

  @observable
  List<FormElement> formElements;

  BuildContext scaffoldContext;

  @action
  void onLabelChange(final String? suggestedTitle) => _onLabelChange?.call(suggestedTitle);

  final void Function(String? suggestedTitle)? _onLabelChange;

  @action
  void toggleIsPinSet(final bool val) => _toggleIsPinSet?.call(val);

  final void Function(bool val)? _toggleIsPinSet;

  @observable
  bool _isPinSet;

  @computed
  bool get isPinSet => _isPinSet;

  @computed
  set isPinSet(final bool val) {
    _isPinSet = val;
    toggleIsPinSet(val);
  }

  @observable
  bool showExtra;
}
