import 'package:flutter/foundation.dart';
import 'dart:async';
import '../router_plugins/router_plugin_interface.dart';
import '../router_plugins/generic_upnp_plugin.dart';
import '../models/network_device.dart';
import 'database_service.dart';

class RouterManagerService extends ChangeNotifier {
  RouterPluginInterface? _activePlugin;
  RouterPluginInterface? get activePlugin => _activePlugin;

  BandwidthUsage _currentBandwidth = BandwidthUsage(uploadKbps: 0, downloadKbps: 0);
  BandwidthUsage get currentBandwidth => _currentBandwidth;

  Timer? _pollingTimer;

  Future<void> initialize(String gatewayIp) async {
    // Basic detection logic (would be expanded in real implementation)
    // For now, load the Generic UPnP plugin
    _activePlugin = GenericUpnpPlugin();
    
    bool connected = await _activePlugin!.connect(gatewayIp);
    if (connected) {
      _startPolling();
    }
    notifyListeners();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_activePlugin != null) {
        _currentBandwidth = await _activePlugin!.getGlobalBandwidth();
        
        // Save to DB for historical graphing
        await DatabaseService.insertBandwidth(
          _currentBandwidth.uploadKbps, 
          _currentBandwidth.downloadKbps
        );
        
        notifyListeners();
      }
    });
  }

  Future<bool> setQosLimit(String macAddress, int dlLimit, int ulLimit) async {
    if (_activePlugin != null) {
      return await _activePlugin!.setDeviceQosLimit(macAddress, dlLimit, ulLimit);
    }
    return false;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
