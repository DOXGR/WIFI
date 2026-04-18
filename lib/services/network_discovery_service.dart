import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_plus/ping_discover_network_plus.dart';
import '../models/network_device.dart';
import 'dart:io';
import 'mac_vendor_service.dart';

class NetworkDiscoveryService extends ChangeNotifier {
  final NetworkInfo _networkInfo = NetworkInfo();
  
  List<NetworkDevice> _devices = [];
  List<NetworkDevice> get devices => _devices;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  String? _gatewayIp;
  String? get gatewayIp => _gatewayIp;

  Future<void> scanNetwork() async {
    if (_isScanning) return;
    
    _isScanning = true;
    _devices.clear();
    notifyListeners();

    try {
      final String? wifiIP = await _networkInfo.getWifiIP();
      _gatewayIp = await _networkInfo.getWifiGatewayIP();
      
      if (wifiIP != null && _gatewayIp != null) {
        final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
        
        // Find devices responding to standard ports (e.g. 80, or just pinging)
        // Note: ARP reading is restricted on newer Android, so ping scan is preferred
        final stream = NetworkAnalyzer.discover2(subnet, 80, timeout: Duration(milliseconds: 500));
        
        await for (final NetworkAddress addr in stream) {
          if (addr.exists) {
            final device = NetworkDevice(ipAddress: addr.ip);
            
            // Attempt to resolve hostname
            try {
              final host = await InternetAddress(addr.ip).reverse();
              device.hostname = host.host;
            } catch (e) {
              device.hostname = 'Unknown Device';
            }
            
            // Attempt to get MAC from ARP table (works on some Android/OSes)
            try {
              final result = await Process.run('arp', ['-a']);
              if (result.stdout != null) {
                final String output = result.stdout.toString();
                final lines = output.split('\n');
                for (var line in lines) {
                  if (line.contains(addr.ip)) {
                    // Extract MAC address using basic regex or split
                    final parts = line.split(RegExp(r'\s+'));
                    if (parts.length > 2) {
                      final maybeMac = parts.firstWhere(
                        (p) => p.contains(':') || p.contains('-'),
                        orElse: () => '',
                      );
                      if (maybeMac.isNotEmpty) {
                        device.macAddress = maybeMac;
                        device.vendor = await MacVendorService.getVendor(maybeMac);
                        break;
                      }
                    }
                  }
                }
              }
            } catch (e) {
              print('ARP lookup failed: \$e');
            }
            
            _devices.add(device);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Network scan error: \$e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
}
