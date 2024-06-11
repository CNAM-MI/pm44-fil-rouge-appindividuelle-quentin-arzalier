import 'package:uuid/uuid.dart';

class Helpers {
  static String parseUuidWithoutHyphens(String uuidString)
  {
    if (uuidString.length != 32)
    {
      print(uuidString.length);
      throw const FormatException("Uuid must be 32 characters long");
    }

    var uuidParsed = '${uuidString.substring(0, 8)}-${uuidString.substring(8, 12)}-${uuidString.substring(12, 16)}-${uuidString.substring(16, 20)}-${uuidString.substring(20)}';
    print(uuidParsed);
    Uuid.parse(uuidParsed); // valide le UUID en lançant une exception au besoin

    return uuidParsed;
  }
}

