import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../common/constants.dart';
import '../services/index.dart';
import 'entities/category.dart';

class CategoryModel with ChangeNotifier {
  final Services _service = Services();

  List<Category>? _categories = [];
  List<Category>? get categories => _categories;

  Map<String?, Category> categoryList = {};

  bool isLoading = false;
  List<Category>? allCategories;
  String? message;

  /// Format the Category List and assign the List by Category ID
  void sortCategoryList(
      {List<Category>? categoryList,
      dynamic sortingList,
      String? categoryLayout}) {
    var _categoryList = <String?, Category>{};
    var result = categoryList;

    if (sortingList != null) {
      var categories = <Category>[];
      var _subCategories = <Category>[];
      var isParent = true;
      for (var category in sortingList) {
        var item = categoryList!.firstWhereOrNull(
            (Category cat) => cat.id.toString() == category.toString());
        if (item != null) {
          if (item.parent != '0') {
            isParent = false;
          }
          categories.add(item);
        }
      }
      if (!['column', 'grid', 'subCategories'].contains(categoryLayout)) {
        for (var category in categoryList!) {
          var item =
              categories.firstWhereOrNull((cat) => cat.id == category.id);
          if (item == null && isParent && category.parent != '0') {
            _subCategories.add(category);
          }
        }
      }
      result = [...categories, ..._subCategories];
    }

    for (var cat in result!) {
      _categoryList[cat.id] = cat;
    }
    this.categoryList = _categoryList;
    _categories = result;
    notifyListeners();
  }

  Future<void> getCategories({lang, sortingList, categoryLayout}) async {
    // try {
    printLog('[Category] getCategories');
    isLoading = true;
    notifyListeners();
    allCategories = await _service.api.getCategories(lang: lang);
    message = null;
    sortCategory();
    sortCategoryList(
        categoryList: allCategories,
        sortingList: sortingList,
        categoryLayout: categoryLayout);

    isLoading = false;
    notifyListeners();
    // } catch (err, _) {
    //   isLoading = false;
    //   message = 'There is an issue with the app during request the data, '
    //           'please contact admin for fixing the issues ' +
    //       err.toString();
    //   //notifyListeners();
    // }
  }

  void sortCategory() {
    var subAllCategories = <Category>[];

    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODA0Mjg0Mg==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODA0Mjg0Mg==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODA0Mjg0Mg==')!);
    }

    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODQwMzI5MA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODQwMzI5MA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODQwMzI5MA==')!);
    }

    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODU2NzEzMA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODU2NzEzMA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTAyODU2NzEzMA==')!);
    }

    //Duplex
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MjQ0MjM4NTQ5OA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MjQ0MjM4NTQ5OA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MjQ0MjM4NTQ5OA==')!);
    }

    //Crystal
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0ODgzNzY2Ng==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0ODgzNzY2Ng==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0ODgzNzY2Ng==')!);
    }

    //FANS
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTg4NjEzODQ1OA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTg4NjEzODQ1OA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2NTg4NjEzODQ1OA==')!);
    }

    //Hanging
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MzQ3NDU3MTE0') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MzQ3NDU3MTE0')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MzQ3NDU3MTE0')!);
    }

    //Wall Lights
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE0ODYzMjA3NjM3OA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE0ODYzMjA3NjM3OA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE0ODYzMjA3NjM3OA==')!);
    }

    //Floor Lamps
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE0OTE2MjkxNzk3OA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE0OTE2MjkxNzk3OA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE0OTE2MjkxNzk3OA==')!);
    }

    //Festive Light
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzk3MDQ2NTYwODU4') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzk3MDQ2NTYwODU4')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzk3MDQ2NTYwODU4')!);
    }

    //Facade Light
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzkzNjE0MDgwMDkw') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzkzNjE0MDgwMDkw')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzkzNjE0MDgwMDkw')!);
    }

    //Gate Light
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzkzMjc2MDc4MTcw') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzkzMjc2MDc4MTcw')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzkzMjc2MDc4MTcw')!);
    }

    //Step Lights
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0ODYwODI5MA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0ODYwODI5MA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0ODYwODI5MA==')!);
    }

    //Bollard Light
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE3MzQ4MzI5NDgxMA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE3MzQ4MzI5NDgxMA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE3MzQ4MzI5NDgxMA==')!);
    }

    //Budget chale
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MTk5NDAyMDk1NA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MTk5NDAyMDk1NA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MTk5NDAyMDk1NA==')!);
    }

    //Spike Lights
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0NzQ2MTQxMA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0NzQ2MTQxMA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzQzMzM0NzQ2MTQxMA==')!);
    }

    //WALL Spotlight
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MTk5MDUwODQy') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MTk5MDUwODQy')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MTk5MDUwODQy')!);
    }

    //Surface COB Light
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MTA2Njc1MjA5MA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MTA2Njc1MjA5MA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MTA2Njc1MjA5MA==')!);
    }

    //Cylindrical COB
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE2NjI3OTkwNTM3MA==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE2NjI3OTkwNTM3MA==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzE2NjI3OTkwNTM3MA==')!);
    }

    //Magnetic track Lights
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id ==
            'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MzgxMDQ4MjI2Ng==') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MzgxMDQ4MjI2Ng==')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id ==
          'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzI2MzgxMDQ4MjI2Ng==')!);
    }

    //LED Track Light
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MjAwODg1ODUw') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MjAwODg1ODUw')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg5MjAwODg1ODUw')!);
    }

    //LED Panel
    if ((allCategories ?? []).firstWhereOrNull((element) =>
            element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg4OTc2NDkwNTg2') !=
        null) {
      subAllCategories.add((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg4OTc2NDkwNTg2')!);
      allCategories!.remove((allCategories ?? []).firstWhereOrNull((element) =>
          element.id == 'Z2lkOi8vc2hvcGlmeS9Db2xsZWN0aW9uLzg4OTc2NDkwNTg2')!);
    }

    (allCategories ?? []).insertAll(0, subAllCategories);
  }

  /// Prase category list from json Object
  static List<Category> parseCategoryList(response) {
    var categories = <Category>[];
    if (response is Map && isNotBlank(response['message'])) {
      throw Exception(response['message']);
    } else {
      for (var item in response) {
        if (item['slug'] != 'uncategorized') {
          categories.add(Category.fromJson(item));
        }
      }
      return categories;
    }
  }

  List<Category>? getCategory({required String parentId}) {
    return _categories?.where((element) => element.parent == parentId).toList();
  }
}
