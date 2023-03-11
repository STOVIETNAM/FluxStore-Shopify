import '../../common/constants.dart';
import '../../common/tools.dart';

class ProductAttribute {
  String? id;
  String? name;
  String? label;
  String? slug;
  List? options = [];
  List optionSlugs = [];
  bool? isVisible;
  bool? isVariation;
  String? get cleanSlug => slug?.replaceAll('pa_', '');

  ProductAttribute({
    this.id,
    this.name,
    this.label,
    this.slug,
    this.options,
    this.optionSlugs = const [],
    this.isVisible,
    this.isVariation,
  });

  ProductAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'].toString();
    label = parsedJson['label'] ?? parsedJson['name']?.replaceAll('pa_', '');
    name =
        parsedJson['name']?.replaceAll('pa_', ''); // name for FluxStore Manager
    slug = parsedJson['slug'] ?? parsedJson['name'];
    isVariation = parsedJson['variation'] ?? false;
    isVisible = parsedJson['visible'] ?? false;

    if (parsedJson['options'] != null) {
      for (var item in parsedJson['options']) {
        options!.add(item);
      }
    }
    if (parsedJson['slugs'] != null) {
      for (var item in parsedJson['slugs']) {
        optionSlugs.add(item);
      }
    }
  }

  ProductAttribute.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = "${parsedJson["attribute_id"]}";
    name = parsedJson['attribute_code'];
    label = name;
    options = parsedJson['options'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'options': options,
      'visible': isVisible,
      'variation': isVariation
    };
  }

  ProductAttribute.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id']?.toString();
      name = json['name'];
      options = json['options'];
      label = name;
    } catch (e) {
      printLog(e.toString());
    }
  }

  ProductAttribute.fromShopify(att) {
    try {
      id = att['id'];
      name = att['name'];
      label = name;
      List? values = att['values'];
      if (values != null) {
        final distinctValue = <dynamic>{};
        if (name?.toLowerCase() == 'color') {
          for (var element in values) {
            distinctValue.add(element.split(' ').first);
          }
          options = distinctValue.toList();
        } else {
          options = values;
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  ProductAttribute.fromPresta(att) {
    try {
      id = att['id'].toString();
      name = att['name'];
      options = att['options'];
      label = name;
    } catch (e) {
      printLog(e.toString());
    }
  }

  ProductAttribute.fromNotion(
      Map<String, dynamic> parsedJson, String nameAttribute) {
    id = parsedJson['id'].toString();
    name = nameAttribute; // name for FluxStore Manager
    label = name;
    slug = nameAttribute;
    isVariation = false;
    isVisible = true;
    options = NotionDataTools.fromMultiSelect(parsedJson);
  }

  ProductAttribute copyWith({
    String? id,
    String? name,
    String? label,
    String? slug,
    List? options,
    List? optionSlugs,
    bool? isVisible,
    bool? isVariation,
  }) {
    return ProductAttribute(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      slug: slug ?? this.slug,
      options: options ?? this.options,
      optionSlugs: optionSlugs ?? this.optionSlugs,
      isVisible: isVisible ?? this.isVisible,
      isVariation: isVariation ?? this.isVariation,
    );
  }
}

class Attribute {
  int? id;
  String? name;
  String? option;
  Attribute({
    this.id,
    this.name,
    this.option,
  });

  Attribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
    option = parsedJson['option'];
  }

  Attribute.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = int.parse(parsedJson['value']);
    name = parsedJson['attribute_code'];
    option = parsedJson['value'];
  }

  Attribute.fromLocalJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
    option = parsedJson['option'];
  }

  Attribute.fromShopifyJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
    option = parsedJson['value'];
  }

  Attribute.fromPrestaJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
    option = parsedJson['option'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'option': option};
  }

  @override
  String toString() {
    return '${name ?? ""}${option ?? ""}';
  }
}
