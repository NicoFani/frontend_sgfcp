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

  String get label {
    switch (this) {
      case OtherItemsType.ajuste:
        return 'Ajuste';
      case OtherItemsType.multa:
        return 'Multa';
      case OtherItemsType.bonificacionExtra:
        return 'Bonificación extra';
      case OtherItemsType.cargoExtra:
        return 'Cargo extra';
    }
  }

  static OtherItemsType fromBackendString(String backendString) {
    switch (backendString) {
      case 'adjustment':
        return OtherItemsType.ajuste;
      case 'fine_without_trip':
        return OtherItemsType.multa;
      case 'bonus':
        return OtherItemsType.bonificacionExtra;
      case 'extra_charge':
        return OtherItemsType.cargoExtra;
      default:
        throw Exception('Unknown item type: $backendString');
    }
  }
}
