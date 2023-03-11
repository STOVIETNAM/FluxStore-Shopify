// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

NewUser newUserFromJson(String str) => NewUser.fromJson(json.decode(str));

String newUserToJson(NewUser data) => json.encode(data.toJson());

class NewUser {
  NewUser({
    this.customer,
  });

  final Customer? customer;

  factory NewUser.fromJson(Map<String, dynamic> json) => NewUser(
        customer: Customer.fromJson(json['customer']),
      );

  Map<String, dynamic> toJson() => {
        'customer': customer?.toJson(),
      };
}

class Customer {
  Customer({
    this.email,
    this.firstName,
    this.lastName,
    this.id,
    this.acceptsMarketing,
    this.createdAt,
    this.updatedAt,
    this.ordersCount,
    this.state,
    this.totalSpent,
    this.lastOrderId,
    this.note,
    this.verifiedEmail,
    this.multipassIdentifier,
    this.taxExempt,
    this.tags,
    this.lastOrderName,
    this.currency,
    this.phone,
    // this.addresses,
    this.acceptsMarketingUpdatedAt,
    this.marketingOptInLevel,
    this.taxExemptions,
    // this.emailMarketingConsent,
    this.smsMarketingConsent,
    this.adminGraphqlApiId,
    // this.defaultAddress,
  });

  final String? email;
  final String? firstName;
  final String? lastName;
  final int? id;
  final bool? acceptsMarketing;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? ordersCount;
  final String? state;
  final String? totalSpent;
  final int? lastOrderId;
  final dynamic note;
  final bool? verifiedEmail;
  final dynamic multipassIdentifier;
  final bool? taxExempt;
  final String? tags;
  final String? lastOrderName;
  final String? currency;
  final String? phone;
  // final List<Addres>? addresses;
  final DateTime? acceptsMarketingUpdatedAt;
  final dynamic marketingOptInLevel;
  final List<dynamic>? taxExemptions;
  // final MarketingConsent? emailMarketingConsent;
  final MarketingConsent? smsMarketingConsent;
  final String? adminGraphqlApiId;
  // final Addres? defaultAddress;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        email: json['email'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        id: json['id'],
        acceptsMarketing: json['accepts_marketing'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        ordersCount: json['orders_count'],
        state: json['state'],
        totalSpent: json['total_spent'],
        lastOrderId: json['last_order_id'],
        note: json['note'],
        verifiedEmail: json['verified_email'],
        multipassIdentifier: json['multipass_identifier'],
        taxExempt: json['tax_exempt'],
        tags: json['tags'],
        lastOrderName: json['last_order_name'],
        currency: json['currency'],
        phone: json['phone'],
        // addresses:
        //     List<Addres>.from(json['addresses'].map(Addres.fromJson)),
        acceptsMarketingUpdatedAt:
            DateTime.parse(json['accepts_marketing_updated_at']),
        marketingOptInLevel: json['marketing_opt_in_level'],
        taxExemptions: List<dynamic>.from(json['tax_exemptions'].map((x) => x)),
        // emailMarketingConsent:
        //     MarketingConsent.fromJson(json['email_marketing_consent']),
        smsMarketingConsent:
            MarketingConsent.fromJson(json['sms_marketing_consent']),
        adminGraphqlApiId: json['admin_graphql_api_id'],
        // defaultAddress: Addres.fromJson(json['default_address']),
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'id': id,
        'accepts_marketing': acceptsMarketing,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'orders_count': ordersCount,
        'state': state,
        'total_spent': totalSpent,
        'last_order_id': lastOrderId,
        'note': note,
        'verified_email': verifiedEmail,
        'multipass_identifier': multipassIdentifier,
        'tax_exempt': taxExempt,
        'tags': tags,
        'last_order_name': lastOrderName,
        'currency': currency,
        'phone': phone,
        // 'addresses': List<dynamic>.from(addresses!.map((x) => x.toJson())),
        'accepts_marketing_updated_at':
            acceptsMarketingUpdatedAt?.toIso8601String(),
        'marketing_opt_in_level': marketingOptInLevel,
        'tax_exemptions': List<dynamic>.from(taxExemptions!.map((x) => x)),
        //  'email_marketing_consent': emailMarketingConsent?.toJson(),
        'sms_marketing_consent': smsMarketingConsent?.toJson(),
        'admin_graphql_api_id': adminGraphqlApiId,
        // 'default_address': defaultAddress?.toJson(),
      };
}

// class Addres {
//   Addres({
//     this.id,
//     this.customerId,
//     this.firstName,
//     this.lastName,
//     this.company,
//     this.address1,
//     this.address2,
//     this.city,
//     this.province,
//     this.country,
//     this.zip,
//     this.phone,
//     this.name,
//     this.provinceCode,
//     this.countryCode,
//     this.countryName,
//     this.addressDefault,
//   });

//   final int? id;
//   final int? customerId;
//   final dynamic firstName;
//   final dynamic lastName;
//   final dynamic company;
//   final String? address1;
//   final String? address2;
//   final String? city;
//   final String? province;
//   final String? country;
//   final String? zip;
//   final String? phone;
//   final String? name;
//   final String? provinceCode;
//   final String? countryCode;
//   final String? countryName;
//   final bool? addressDefault;

//   factory Addres.fromJson(Map<String, dynamic> json) => Addres(
//         id: json['id'],
//         customerId: json['customer_id'],
//         firstName: json['first_name'],
//         lastName: json['last_name'],
//         company: json['company'],
//         address1: json['address1'],
//         address2: json['address2'],
//         city: json['city'],
//         province: json['province'],
//         country: json['country'],
//         zip: json['zip'],
//         phone: json['phone'],
//         name: json['name'],
//         provinceCode: json['province_code'],
//         countryCode: json['country_code'],
//         countryName: json['country_name'],
//         addressDefault: json['default'],
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'customer_id': customerId,
//         'first_name': firstName,
//         'last_name': lastName,
//         'company': company,
//         'address1': address1,
//         'address2': address2,
//         'city': city,
//         'province': province,
//         'country': country,
//         'zip': zip,
//         'phone': phone,
//         'name': name,
//         'province_code': provinceCode,
//         'country_code': countryCode,
//         'country_name': countryName,
//         'default': addressDefault,
//       };
// }

class MarketingConsent {
  MarketingConsent({
    this.state,
    this.optInLevel,
    this.consentUpdatedAt,
    this.consentCollectedFrom,
  });

  final String? state;
  final String? optInLevel;
  final String? consentUpdatedAt;
  final String? consentCollectedFrom;

  factory MarketingConsent.fromJson(Map<String, dynamic> json) =>
      MarketingConsent(
        state: json['state'],
        optInLevel: json['opt_in_level'] == null ? null : json['opt_in_level'],
        consentUpdatedAt: json['consent_updated_at'],
        consentCollectedFrom: json['consent_collected_from'] == null
            ? null
            : json['consent_collected_from'],
      );

  Map<String, dynamic> toJson() => {
        'state': state,
        'opt_in_level': optInLevel == null ? null : optInLevel,
        'consent_updated_at': consentUpdatedAt,
        'consent_collected_from':
            consentCollectedFrom == null ? null : consentCollectedFrom,
      };
}
