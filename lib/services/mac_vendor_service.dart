import 'dart:convert';
import 'package:http/http.dart' as http;

class MacVendorService {
  // A lightweight offline database of the most common manufacturer OUIs
  // Format: "XX:XX:XX" -> "Manufacturer Name"
  static final Map<String, String> _offlineDatabase = {
    // Apple
    '00:14:51': 'Apple, Inc.',
    '00:16:CB': 'Apple, Inc.',
    '00:1E:52': 'Apple, Inc.',
    '00:23:DF': 'Apple, Inc.',
    '00:25:00': 'Apple, Inc.',
    '00:25:4B': 'Apple, Inc.',
    '00:26:08': 'Apple, Inc.',
    '00:26:BB': 'Apple, Inc.',
    '00:26:B0': 'Apple, Inc.',
    // Samsung
    '00:16:32': 'Samsung Electronics Co.,Ltd',
    '00:1E:E3': 'Samsung Electronics Co.,Ltd',
    '00:21:19': 'Samsung Electronics Co.,Ltd',
    '00:23:99': 'Samsung Electronics Co.,Ltd',
    // Intel
    '00:13:E8': 'Intel Corporate',
    '00:15:00': 'Intel Corporate',
    '00:1B:77': 'Intel Corporate',
    '00:1C:C0': 'Intel Corporate',
    // TP-Link
    '00:0A:EB': 'TP-Link Technologies Co., Ltd.',
    '00:1D:0F': 'TP-Link Technologies Co., Ltd.',
    '00:25:86': 'TP-Link Technologies Co., Ltd.',
    // Asus
    '00:0C:6E': 'ASUSTek COMPUTER INC.',
    '00:11:2F': 'ASUSTek COMPUTER INC.',
    '00:13:D4': 'ASUSTek COMPUTER INC.',
    // Sony
    '00:01:4A': 'Sony Corporation',
    '00:13:A9': 'Sony Corporation',
    '00:19:C5': 'Sony Corporation',
    // Microsoft
    '00:12:5A': 'Microsoft Corporation',
    '00:15:5D': 'Microsoft Corporation',
    '00:17:FA': 'Microsoft Corporation',
    // Espressif (IoT Devices)
    '18:FE:34': 'Espressif Inc.',
    '24:0A:C4': 'Espressif Inc.',
    '30:AE:A4': 'Espressif Inc.',
    // Google
    '00:1A:11': 'Google, Inc.',
    'F4:F5:D8': 'Google, Inc.',
  };

  /// Attempts to resolve the MAC address using an offline mapping. 
  /// If it fails, falls back to the public API.
  static Future<String?> getVendor(String? macAddress) async {
    if (macAddress == null || macAddress.isEmpty) return null;

    final normalizedMac = macAddress.toUpperCase().replaceAll('-', ':');
    if (normalizedMac.length >= 8) {
      final oui = normalizedMac.substring(0, 8);
      
      // 1. Check Offline Database First
      if (_offlineDatabase.containsKey(oui)) {
        return _offlineDatabase[oui];
      }

      // 2. Fallback to API if internet is available
      try {
        final response = await http.get(Uri.parse('https://api.macvendors.com/\$normalizedMac'))
                                   .timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          return response.body.trim();
        }
      } catch (e) {
        print('API MAC Lookup failed: \$e');
      }
    }
    
    return 'Unknown Device';
  }
}
