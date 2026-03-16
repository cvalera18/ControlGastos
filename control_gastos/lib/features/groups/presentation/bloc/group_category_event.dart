part of 'group_category_bloc.dart';

abstract class GroupCategoryEvent extends Equatable {
  const GroupCategoryEvent();
  @override
  List<Object> get props => [];
}

class FetchGroupCategoriesEvent extends GroupCategoryEvent {
  final String groupId;
  const FetchGroupCategoriesEvent(this.groupId);
  @override
  List<Object> get props => [groupId];
}

class AddGroupCategoryEvent extends GroupCategoryEvent {
  final GroupCategory category;
  const AddGroupCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}

class UpdateGroupCategoryEvent extends GroupCategoryEvent {
  final GroupCategory category;
  const UpdateGroupCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}

class DeleteGroupCategoryEvent extends GroupCategoryEvent {
  final String groupId;
  final String categoryId;
  const DeleteGroupCategoryEvent({required this.groupId, required this.categoryId});
  @override
  List<Object> get props => [groupId, categoryId];
}
