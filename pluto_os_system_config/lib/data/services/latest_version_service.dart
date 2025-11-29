import 'package:pluto_os_system_config/data/apis/latest_version_api.dart';
import 'package:pluto_os_system_config/data/models/latest_version_info.dart';

class LatestVersionService {
  final api = LatestVersionApi();
  Future<LatestVersionInfo?> getLatestVersionInfo() async {
    return api.getLatestVersionInfo();
  }
}