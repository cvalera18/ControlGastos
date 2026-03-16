part of 'group_category_bloc.dart';

abstract class GroupCategoryState extends Equatable {
  const GroupCategoryState();
  @override
  List<Object> get props => [];
}

class GroupCategoryInitial extends GroupCategoryState {
  const GroupCategoryInitial();
}

class GroupCategoryLoading extends GroupCategoryState {
  const GroupCategoryLoading();
}

class GroupCategoryLoaded extends GroupCategoryState {
  final List<GroupCategory> categories;
  const GroupCategoryLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class GroupCategoryOperationSuccess extends GroupCategoryState {
  final String message;
  const GroupCategoryOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class GroupCategoryError extends GroupCategoryState {
  final String message;
  const GroupCategoryError(this.message);
  @override
  List<Object> get props => [message];
}
