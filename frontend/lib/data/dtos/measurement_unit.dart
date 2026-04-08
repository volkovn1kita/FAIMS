
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:faims/l10n/app_localizations.dart';

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

extension MeasurementUnitExtension on MeasurementUnit {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case MeasurementUnit.pieces:
        return l10n.unitPieces;
      case MeasurementUnit.milliliters:
        return l10n.unitMilliliters;
      case MeasurementUnit.grams:
        return l10n.unitGrams;
      case MeasurementUnit.tablets:
        return l10n.unitTablets;
      case MeasurementUnit.ampoules:
        return l10n.unitAmpoules;
      case MeasurementUnit.packs:
        return l10n.unitPacks;
    }
  }
}
