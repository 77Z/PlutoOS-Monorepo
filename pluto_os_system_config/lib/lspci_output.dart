class PciDevice {
  final String slot;
  final String domain;
  final int domainInt;
  final String bus;
  final int busInt;
  final String dev;
  final int devInt;
  final String function;
  final int functionInt;
  final String klass;
  final String vendor;
  final String device;
  final String? svendor;
  final String? sdevice;
  final String progif;
  final int progifInt;
  final String? driver;
  final String? module;
  final String? iommugroup;

  PciDevice({
    required this.slot,
    required this.domain,
    required this.domainInt,
    required this.bus,
    required this.busInt,
    required this.dev,
    required this.devInt,
    required this.function,
    required this.functionInt,
    required this.klass,
    required this.vendor,
    required this.device,
    required this.svendor,
    required this.sdevice,
    required this.progif,
    required this.progifInt,
    required this.driver,
    required this.module,
    required this.iommugroup,
  });

  factory PciDevice.fromJson(Map<String, dynamic> json) {
    return PciDevice(
      slot: json['slot'],
      domain: json['domain'],
      domainInt: json['domain_int'],
      bus: json['bus'],
      busInt: json['bus_int'],
      dev: json['dev'],
      devInt: json['dev_int'],
      function: json['function'],
      functionInt: json['function_int'],
      klass: json['class'],
      vendor: json['vendor'],
      device: json['device'],
      svendor: json['svendor'],
      sdevice: json['sdevice'],
      progif: json['progif'],
      progifInt: json['progif_int'],
      driver: json['driver'],
      module: json['module'],
      iommugroup: json['iommugroup'],
    );
  }
}