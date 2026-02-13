import 'package:frontend_sgfcp/widgets/document_type_selector.dart';

DocumentType parseDocumentType(String type) {
  final normalized = type.toLowerCase();
  switch (normalized) {
    case 'cgt':
    case 'ctg':
      return DocumentType.ctg;
    case 'remito':
      return DocumentType.remito;
    default:
      return DocumentType.ctg;
  }
}

String documentTypeToApiValue(DocumentType type) {
  switch (type) {
    case DocumentType.ctg:
      return 'CTG';
    case DocumentType.remito:
      return 'Remito';
  }
}
