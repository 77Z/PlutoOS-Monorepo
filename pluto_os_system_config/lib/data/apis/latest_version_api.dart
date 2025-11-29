import 'package:http/http.dart' as http;
import 'package:pluto_os_system_config/data/models/latest_version_info.dart';
import 'package:plutoos_system_library/plutoos_system_library.dart';

class LatestVersionApi {
  Future<LatestVersionInfo?> getLatestVersionInfo() async {
    var response = await http.get(Uri.parse("${getAPIUrl()}/latestVersions"));

    if (response.statusCode == 200) {
      return versionInfoFromJson(response.body);
    }
    return null;
  }
}