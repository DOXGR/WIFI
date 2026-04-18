import 'dart:async';
import 'package:upnp2/upnp.dart';
import '../models/network_device.dart';
import 'router_plugin_interface.dart';

class GenericUpnpPlugin implements RouterPluginInterface {
  @override
  String get pluginName => 'Standard UPnP IGD';

  @override
  String get pluginDescription => 'Basic UPnP support. Cannot set per-device QoS limits.';

  @override
  String get requiredRouterBrand => 'Any';

  String? _gatewayIp;
  Device? _igdDevice;
  final DeviceDiscoverer _discoverer = DeviceDiscoverer();
  
  int _lastBytesReceived = 0;
  int _lastBytesSent = 0;
  DateTime? _lastFetchTime;

  @override
  Future<bool> connect(String gatewayIp) async {
    _gatewayIp = gatewayIp;
    try {
      await _discoverer.start(ipv6: false);
      
      // Look for InternetGatewayDevice
      var clients = await _discoverer.discoverClients(Duration(seconds: 3));
      for (var client in clients) {
        var device = await client.getDevice();
        if (device != null && device.deviceType != null && device.deviceType!.contains('InternetGatewayDevice')) {
          _igdDevice = device;
          return true;
        }
      }
    } catch (e) {
      print('UPnP Connect Error: \$e');
    } finally {
      _discoverer.stop();
    }
    return false;
  }

  @override
  Future<BandwidthUsage> getGlobalBandwidth() async {
    if (_igdDevice == null) return BandwidthUsage(uploadKbps: 0, downloadKbps: 0);

    try {
      var service = await _igdDevice!.getService('urn:upnp-org:serviceId:WANCommonIFC1');
      if (service == null) return BandwidthUsage(uploadKbps: 0, downloadKbps: 0);

      var result = await service.invokeAction('GetAddonInfos', {});
      if (result.isNotEmpty) {
        // Different routers might use different actions, e.g., GetTotalBytesReceived
        int currentBytesReceived = int.tryParse(result['NewTotalBytesReceived'] ?? '0') ?? 0;
        int currentBytesSent = int.tryParse(result['NewTotalBytesSent'] ?? '0') ?? 0;
        
        DateTime now = DateTime.now();
        
        if (_lastFetchTime != null) {
          int timeDiff = now.difference(_lastFetchTime!).inMilliseconds;
          if (timeDiff > 0) {
            double rxRate = ((currentBytesReceived - _lastBytesReceived) * 8) / (timeDiff / 1000.0) / 1000.0;
            double txRate = ((currentBytesSent - _lastBytesSent) * 8) / (timeDiff / 1000.0) / 1000.0;
            
            _lastBytesReceived = currentBytesReceived;
            _lastBytesSent = currentBytesSent;
            _lastFetchTime = now;
            
            return BandwidthUsage(
              uploadKbps: txRate.toInt(),
              downloadKbps: rxRate.toInt()
            );
          }
        } else {
          _lastBytesReceived = currentBytesReceived;
          _lastBytesSent = currentBytesSent;
          _lastFetchTime = now;
        }
      }
    } catch (e) {
      print('UPnP Bandwidth Error: \$e');
    }
    
    return BandwidthUsage(uploadKbps: 0, downloadKbps: 0);
  }

  @override
  Future<List<NetworkDevice>> getConnectedDevices() async {
    // UPnP IGD usually doesn't provide the connected devices list.
    // We rely on NetworkDiscoveryService for this.
    return [];
  }

  @override
  Future<bool> setDeviceQosLimit(String macAddress, int downloadLimitKbps, int uploadLimitKbps) async {
    // Standard UPnP does not support MAC-based QoS limits.
    print('Error: UPnP IGD does not support QoS limits.');
    return false;
  }
}
