// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

enum AppTab { a, b, c }

enum AppToastType { success, error, warning, random }

enum ApiRequestType { get, post, put, patch, delete, formData }

enum KycStatus {
  pending,
  processing, // being processed by the KYC provider (Dojah)
  validating, // being validated by compliance team
  approved,
  failed,
  none;
}

enum VerificationStatus {
  pending,
  ongoing,
  completed,
  failed,
  none;

  static VerificationStatus fromString(String? status) {
    return VerificationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status?.toLowerCase(),
      orElse: () => VerificationStatus.none,
    );
  }
}

enum AddressType { pickup, destination }

enum DeliveryStatus {
  // accepted => heading to pickup location
  // in_transit => heading to dropoff location
  // completed => delivery completed

  pending, // When a delivery is created but not yet started
  paid, // When the delivery has been paid for
  accepted, // When the delivery has been accepted by a movva
  arrived_pickup, // When the delivery has arrived at the pickup location [internal]
  in_transit, // When the delivery is in transit after picking up the item
  arrived_dropoff, // When the delivery has arrived at the dropoff location [internal]
  completed, // When the delivery has been successfully completed
  confirmed, // When the delivery has been confirmed by the customer
  cancelled,
  unknown;

  static DeliveryStatus fromString(String? status) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status?.toLowerCase(),
      orElse: () => DeliveryStatus.unknown,
    );
  }



 
}
