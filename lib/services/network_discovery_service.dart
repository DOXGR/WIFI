import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/network_device.dart';
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
    _devices = [];
    notifyListeners();

    try {
      final String? wifiIP = await _networkInfo.getWifiIP();
      _gatewayIp = await _networkInfo.getWifiGatewayIP();

      if (wifiIP != null) {
        final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

        // Scan all 254 hosts concurrently using raw socket ping
        final futures = <Future>[];
        for (int i = 1; i <= 254; i++) {
          final ip = '$subnet.$i';
          futures.add(_pingAndAdd(ip));
        }
        await Future.wait(futures);
      }
    } catch (e) {
      debugPrint('Network scan error: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> _pingAndAdd(String ip) async {
    try {
      final socket = await Socket.connect(ip, 80,
          timeout: const Duration(milliseconds: 400));
      socket.destroy();

      final device = NetworkDevice(ipAddress: ip);

      // Reverse DNS
      try {
        final hosts = await InternetAddress(ip).reverse();
        device.hostname = hosts.host != ip ? hosts.host : null;
      } catch (_) {}

      // ARP table lookup for MAC address
      await _arpLookup(device);

      _devices.add(device);
      notifyListeners();
    } catch (_) {
      // Host not reachable on port 80, try port 443
      try {
        final socket = await Socket.connect(ip, 443,
            timeout: const Duration(milliseconds: 400));
        socket.destroy();

        final device = NetworkDevice(ipAddress: ip);
        try {
          final hosts = await InternetAddress(ip).reverse();
          device.hostname = hosts.host != ip ? hosts.host : null;
        } catch (_) {}
        await _arpLookup(device);
        _devices.add(device);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _arpLookup(NetworkDevice device) async {
    try {
      final result = await Process.run('arp', ['-a']);
      final output = result.stdout.toString();
      for (final line in output.split('\n')) {
        if (line.contains(device.ipAddress)) {
          final parts = line.trim().split(RegExp(r'\s+'));
          final mac = parts.firstWhere(
            (p) => p.contains(':') || p.contains('-'),
            orElse: () => '',
          );
          if (mac.isNotEmpty) {
            device.macAddress = mac;
            device.vendor = await MacVendorService.getVendor(mac);
          }
          break;
        }
      }
    } catch (_) {}
  }
}
