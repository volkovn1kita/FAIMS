
import 'package:json_annotation/json_annotation.dart';

enum ExpirationStatus {
  @JsonValue('Good')
  good,
  @JsonValue('Warning')
  warning,
  @JsonValue('Critical')
  critical,
  @JsonValue('Expired')
  expired,
}