import 'dart:convert';


HaroldProduct haroldProductFromJson(String str) =>
    HaroldProduct.fromJson(json.decode(str));

String haroldProductToJson(HaroldProduct data) => json.encode(data.toJson());

class HaroldProduct {
  HaroldProduct({
    //   required this.product,
    required this.crmDetails,
  });

//  Product product;
  CrmDetails crmDetails;

  factory HaroldProduct.fromJson(Map<String, dynamic> json) => HaroldProduct(
        //  product: Product.fromJson(json['product']),
        crmDetails: CrmDetails.fromJson(json['crm_details']),
      );

  Map<String, dynamic> toJson() => {
        // 'product': product.toJson(),
        'crm_details': crmDetails.toJson(),
      };
}

class CrmDetails {
  CrmDetails({
    this.inventory,
    this.ecommerce,
    this.images,
    this.videos,
    this.variants,
    this.id,
    this.code,
    this.name,
    this.v,
    this.createdAt,
    this.updatedAt,
    this.costPrice,
    this.shippingCost,
    this.crmDetailsId,
  });

  int? inventory;
  String? ecommerce;
  List<dynamic>? images;
  List<String>? videos;
  List<dynamic>? variants;
  String? id;
  String? code;
  String? name;
  int? v;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? costPrice;
  String? shippingCost;
  String? crmDetailsId;

  factory CrmDetails.fromJson(Map<String, dynamic> json) => CrmDetails(
        inventory: json['inventory'],
        ecommerce: json['ecommerce'],
        images: List<dynamic>.from(json['images'].map((x) => x)),
        videos: List<String>.from(json['videos'].map((x) => x)),
        variants: List<dynamic>.from(json['variants'].map((x) => x)),
        id: json['_id'],
        code: json['code'],
        name: json['name'],
        v: json['__v'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        costPrice: json['costPrice'],
        shippingCost: json['shippingCost'],
        crmDetailsId: json['id'],
      );

  Map<String, dynamic> toJson() => {
        'inventory': inventory,
        'ecommerce': ecommerce,
        'images':
            images != null ? List<dynamic>.from(images!.map((x) => x)) : null,
        'videos':
            videos != null ? List<dynamic>.from(videos!.map((x) => x)) : null,
        'variants': variants != null
            ? List<dynamic>.from(variants!.map((x) => x))
            : null,
        '_id': id,
        'code': code,
        'name': name,
        '__v': v,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'costPrice': costPrice,
        'shippingCost': shippingCost,
        'id': crmDetailsId,
      };
}
