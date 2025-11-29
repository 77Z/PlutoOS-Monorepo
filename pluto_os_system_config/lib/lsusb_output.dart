class UsbDevice {
  final String bus;
  final String device;
  final String id;
  final String description;
  final DeviceDescriptor deviceDescriptor;

  String? driver;

  UsbDevice({
    required this.bus,
    required this.device,
    required this.id,
    required this.description,
    required this.deviceDescriptor,
  });

  factory UsbDevice.fromJson(Map<String, dynamic> json) {
    return UsbDevice(
      bus: json['bus'],
      device: json['device'],
      id: json['id'],
      description: json['description'],
      deviceDescriptor: DeviceDescriptor.fromJson(json['device_descriptor']),
    );
  }
}

class DeviceDescriptor {
  final ValueField bLength;
  final ValueField bDescriptorType;
  final ValueField bcdUSB;
  final DescriptionField bDeviceClass;
  final DescriptionField bDeviceSubClass;
  final ValueField bDeviceProtocol;
  final ValueField bMaxPacketSize0;
  final DescriptionField idVendor;
  final DescriptionField idProduct;
  final ValueField bcdDevice;
  final DescriptionField iManufacturer;
  final DescriptionField iProduct;
  final DescriptionField iSerial;
  final ValueField bNumConfigurations;
  final ConfigurationDescriptor configurationDescriptor;

  DeviceDescriptor({
    required this.bLength,
    required this.bDescriptorType,
    required this.bcdUSB,
    required this.bDeviceClass,
    required this.bDeviceSubClass,
    required this.bDeviceProtocol,
    required this.bMaxPacketSize0,
    required this.idVendor,
    required this.idProduct,
    required this.bcdDevice,
    required this.iManufacturer,
    required this.iProduct,
    required this.iSerial,
    required this.bNumConfigurations,
    required this.configurationDescriptor,
  });

  factory DeviceDescriptor.fromJson(Map<String, dynamic> json) {
    return DeviceDescriptor(
      bLength: ValueField.fromJson(json['bLength']),
      bDescriptorType: ValueField.fromJson(json['bDescriptorType']),
      bcdUSB: ValueField.fromJson(json['bcdUSB']),
      bDeviceClass: DescriptionField.fromJson(json['bDeviceClass']),
      bDeviceSubClass: DescriptionField.fromJson(json['bDeviceSubClass']),
      bDeviceProtocol: ValueField.fromJson(json['bDeviceProtocol']),
      bMaxPacketSize0: ValueField.fromJson(json['bMaxPacketSize0']),
      idVendor: DescriptionField.fromJson(json['idVendor']),
      idProduct: DescriptionField.fromJson(json['idProduct']),
      bcdDevice: ValueField.fromJson(json['bcdDevice']),
      iManufacturer: DescriptionField.fromJson(json['iManufacturer']),
      iProduct: DescriptionField.fromJson(json['iProduct']),
      iSerial: DescriptionField.fromJson(json['iSerial']),
      bNumConfigurations: ValueField.fromJson(json['bNumConfigurations']),
      configurationDescriptor: ConfigurationDescriptor.fromJson(json['configuration_descriptor']),
    );
  }
}

class ConfigurationDescriptor {
  final ValueField bLength;
  final ValueField bDescriptorType;
  final ValueField wTotalLength;
  final ValueField bNumInterfaces;
  final ValueField bConfigurationValue;
  final ValueField iConfiguration;
  final AttributesField bmAttributes;
  final String? maxPowerDescription;
  final List<InterfaceDescriptor> interfaceDescriptors;

  ConfigurationDescriptor({
    required this.bLength,
    required this.bDescriptorType,
    required this.wTotalLength,
    required this.bNumInterfaces,
    required this.bConfigurationValue,
    required this.iConfiguration,
    required this.bmAttributes,
    this.maxPowerDescription,
    required this.interfaceDescriptors,
  });

  factory ConfigurationDescriptor.fromJson(Map<String, dynamic> json) {
    return ConfigurationDescriptor(
      bLength: ValueField.fromJson(json['bLength']),
      bDescriptorType: ValueField.fromJson(json['bDescriptorType']),
      wTotalLength: ValueField.fromJson(json['wTotalLength']),
      bNumInterfaces: ValueField.fromJson(json['bNumInterfaces']),
      bConfigurationValue: ValueField.fromJson(json['bConfigurationValue']),
      iConfiguration: ValueField.fromJson(json['iConfiguration']),
      bmAttributes: AttributesField.fromJson(json['bmAttributes']),
      maxPowerDescription: json['MaxPower']?['description'],
      interfaceDescriptors: (json['interface_descriptors'] as List)
          .map((e) => InterfaceDescriptor.fromJson(e))
          .toList(),
    );
  }
}

class InterfaceDescriptor {
  final ValueField bLength;
  final ValueField bDescriptorType;
  final ValueField bInterfaceNumber;
  final ValueField bAlternateSetting;
  final ValueField bNumEndpoints;
  final DescriptionField bInterfaceClass;
  final DescriptionField bInterfaceSubClass;
  final DescriptionField bInterfaceProtocol;
  final ValueField iInterface;
  // final List<EndpointDescriptor> endpointDescriptors;

  InterfaceDescriptor({
    required this.bLength,
    required this.bDescriptorType,
    required this.bInterfaceNumber,
    required this.bAlternateSetting,
    required this.bNumEndpoints,
    required this.bInterfaceClass,
    required this.bInterfaceSubClass,
    required this.bInterfaceProtocol,
    required this.iInterface,
    // required this.endpointDescriptors,
  });

  factory InterfaceDescriptor.fromJson(Map<String, dynamic> json) {
    return InterfaceDescriptor(
      bLength: ValueField.fromJson(json['bLength']),
      bDescriptorType: ValueField.fromJson(json['bDescriptorType']),
      bInterfaceNumber: ValueField.fromJson(json['bInterfaceNumber']),
      bAlternateSetting: ValueField.fromJson(json['bAlternateSetting']),
      bNumEndpoints: ValueField.fromJson(json['bNumEndpoints']),
      bInterfaceClass: DescriptionField.fromJson(json['bInterfaceClass']),
      bInterfaceSubClass: DescriptionField.fromJson(json['bInterfaceSubClass']),
      bInterfaceProtocol: DescriptionField.fromJson(json['bInterfaceProtocol']),
      iInterface: ValueField.fromJson(json['iInterface']),
      // endpointDescriptors: (json['endpoint_descriptors'] as List)
      //     .map((e) => EndpointDescriptor.fromJson(e))
      //     .toList(),
    );
  }
}

class EndpointDescriptor {
  final ValueField bLength;
  final ValueField bDescriptorType;
  final DescriptionField bEndpointAddress;
  final AttributesField bmAttributes;
  final DescriptionField wMaxPacketSize;
  final ValueField bInterval;
  // final ValueField bMaxBurst;

  EndpointDescriptor({
    required this.bLength,
    required this.bDescriptorType,
    required this.bEndpointAddress,
    required this.bmAttributes,
    required this.wMaxPacketSize,
    required this.bInterval,
    // required this.bMaxBurst,
  });

  factory EndpointDescriptor.fromJson(Map<String, dynamic> json) {
    return EndpointDescriptor(
      bLength: ValueField.fromJson(json['bLength']),
      bDescriptorType: ValueField.fromJson(json['bDescriptorType']),
      bEndpointAddress: DescriptionField.fromJson(json['bEndpointAddress']),
      bmAttributes: AttributesField.fromJson(json['bmAttributes']),
      wMaxPacketSize: DescriptionField.fromJson(json['wMaxPacketSize']),
      bInterval: ValueField.fromJson(json['bInterval']),
      // bMaxBurst: ValueField.fromJson(json['bMaxBurst']),
    );
  }
}

class ValueField {
  final String value;

  ValueField({required this.value});

  factory ValueField.fromJson(Map<String, dynamic> json) {
    return ValueField(value: json['value']);
  }
}

class DescriptionField {
  final String value;
  final String? description;

  DescriptionField({required this.value, this.description});

  factory DescriptionField.fromJson(Map<String, dynamic> json) {
    return DescriptionField(
      value: json['value'],
      description: json['description'],
    );
  }
}

class AttributesField {
  final String value;
  final List<String> attributes;

  AttributesField({required this.value, required this.attributes});

  factory AttributesField.fromJson(Map<String, dynamic> json) {
    return AttributesField(
      value: json['value'],
      attributes: List<String>.from(json['attributes']),
    );
  }
}