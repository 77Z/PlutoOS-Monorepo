import 'dart:convert';

LatestVersionInfo versionInfoFromJson(String str) => LatestVersionInfo.fromJson(json.decode(str));

String versionInfoToJson(LatestVersionInfo data) => json.encode(data.toJson());

class LatestVersionInfo {
    Version stable;
    Version beta;
    String server;

    LatestVersionInfo({
        required this.stable,
        required this.beta,
        required this.server,
    });

    factory LatestVersionInfo.fromJson(Map<String, dynamic> json) => LatestVersionInfo(
        stable: Version.fromJson(json["stable"]),
        beta: Version.fromJson(json["beta"]),
        server: json["server"],
    );

    Map<String, dynamic> toJson() => {
        "stable": stable.toJson(),
        "beta": beta.toJson(),
        "server": server,
    };
}

class Version {
    String latestVersion;
    DateTime releaseDate;
    String bundleUrl;

    Version({
        required this.latestVersion,
        required this.releaseDate,
        required this.bundleUrl,
    });

    factory Version.fromJson(Map<String, dynamic> json) => Version(
        latestVersion: json["latestVersion"],
        releaseDate: DateTime.parse(json["releaseDate"]),
        bundleUrl: json["bundleURL"],
    );

    Map<String, dynamic> toJson() => {
        "latestVersion": latestVersion,
        "releaseDate": "${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}",
        "bundleURL": bundleUrl,
    };
}
