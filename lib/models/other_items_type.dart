enum OtherItemsType { ajuste, multa, bonificacionExtra, cargoExtra }

extension OtherItemsTypeExtension on OtherItemsType {
  String toBackendString() {
    switch (this) {
      case OtherItemsType.ajuste:
        return 'adjustment';
      case OtherItemsType.multa:
        return 'fine_without_trip';
      case OtherItemsType.bonificacionExtra:
        return 'bonus';
      case OtherItemsType.cargoExtra:
        return 'extra_charge';
    }
  }
}
