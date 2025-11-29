import 'dart:io';

class FrameworkApi {

  // Returns true if PlutoOS is currently running on a Framework Laptop 13.
  // TODO: Expand this to other frameworks as well!
  static bool isFrameworkLaptop() {
    try {
      var manufacturer = File("/sys/devices/virtual/dmi/id/board_vendor");
      if (manufacturer.readAsStringSync() != "Framework\n") return false;

      var product = File("/sys/devices/virtual/dmi/id/product_name");
      if (!product.readAsStringSync().startsWith("Laptop")) return false;

      return true;

    } catch(e) {
      return false;
    }
  }

}