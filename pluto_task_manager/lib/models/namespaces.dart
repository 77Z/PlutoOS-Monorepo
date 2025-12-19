// sudo lsns -t pid --output-all --json

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
    List<Namespace> namespaces;

    Welcome({
        required this.namespaces,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        namespaces: List<Namespace>.from(json["namespaces"].map((x) => Namespace.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "namespaces": List<dynamic>.from(namespaces.map((x) => x.toJson())),
    };
}

class Namespace {
    int ns;
    Type type;
    String path;
    int nprocs;
    int pid;
    int ppid;
    String command;
    int uid;
    User user;
    dynamic netnsid;
    dynamic nsfs;
    int pns;
    int ons;

    Namespace({
        required this.ns,
        required this.type,
        required this.path,
        required this.nprocs,
        required this.pid,
        required this.ppid,
        required this.command,
        required this.uid,
        required this.user,
        required this.netnsid,
        required this.nsfs,
        required this.pns,
        required this.ons,
    });

    factory Namespace.fromJson(Map<String, dynamic> json) => Namespace(
        ns: json["ns"],
        type: typeValues.map[json["type"]]!,
        path: json["path"],
        nprocs: json["nprocs"],
        pid: json["pid"],
        ppid: json["ppid"],
        command: json["command"],
        uid: json["uid"],
        user: userValues.map[json["user"]]!,
        netnsid: json["netnsid"],
        nsfs: json["nsfs"],
        pns: json["pns"],
        ons: json["ons"],
    );

    Map<String, dynamic> toJson() => {
        "ns": ns,
        "type": typeValues.reverse[type],
        "path": path,
        "nprocs": nprocs,
        "pid": pid,
        "ppid": ppid,
        "command": command,
        "uid": uid,
        "user": userValues.reverse[user],
        "netnsid": netnsid,
        "nsfs": nsfs,
        "pns": pns,
        "ons": ons,
    };
}

enum Type {
    PID
}

final typeValues = EnumValues({
    "pid": Type.PID
});

enum User {
    ROOT,
    VINCE
}

final userValues = EnumValues({
    "root": User.ROOT,
    "vince": User.VINCE
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
