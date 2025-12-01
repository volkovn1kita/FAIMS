
import 'package:json_annotation/json_annotation.dart';

enum MeasurementUnit {
  @JsonValue('Pieces')
  pieces,
  @JsonValue('Milliliters')
  milliliters,
  @JsonValue('Grams')
  grams,
  @JsonValue('Tablets')
  tablets,
  @JsonValue('Ampoules')
  ampoules,
  @JsonValue('Packs')
  packs,
}