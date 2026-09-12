import 'package:csv/csv.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CsvService {
  String encode(List<List<dynamic>> rows) {
    return const ListToCsvConverter().convert(rows);
  }

  List<List<dynamic>> decode(String csv) {
    if (csv.trim().isEmpty) {
      return const [];
    }
    return const CsvToListConverter(shouldParseNumbers: false).convert(csv);
  }
}
