// systemctl -o json

import 'dart:convert';

List<Welcome> welcomeFromJson(String str) => List<Welcome>.from(json.decode(str).map((x) => Welcome.fromJson(x)));

String welcomeToJson(List<Welcome> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Welcome {
    String unit;
    Load load;
    Active active;
    Active sub;
    String description;

    Welcome({
        required this.unit,
        required this.load,
        required this.active,
        required this.sub,
        required this.description,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        unit: json["unit"],
        load: loadValues.map[json["load"]]!,
        active: activeValues.map[json["active"]]!,
        sub: activeValues.map[json["sub"]]!,
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "unit": unit,
        "load": loadValues.reverse[load],
        "active": activeValues.reverse[active],
        "sub": activeValues.reverse[sub],
        "description": description,
    };
}

enum Active {
    ACTIVE,
    EXITED,
    FAILED,
    LISTENING,
    MOUNTED,
    PLUGGED,
    RUNNING,
    WAITING
}

final activeValues = EnumValues({
    "active": Active.ACTIVE,
    "exited": Active.EXITED,
    "failed": Active.FAILED,
    "listening": Active.LISTENING,
    "mounted": Active.MOUNTED,
    "plugged": Active.PLUGGED,
    "running": Active.RUNNING,
    "waiting": Active.WAITING
});

enum Load {
    LOADED,
    NOT_FOUND
}

final loadValues = EnumValues({
    "loaded": Load.LOADED,
    "not-found": Load.NOT_FOUND
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
