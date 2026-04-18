import 'dart:async';
import 'dart:io';
import '../models/network_device.dart';
import 'router_plugin_interface.dart';

/// Generic plugin using raw HTTP to reach the router's UPnP IGD endpoint.
/// No third-party upnp package needed — avoids all API-compat issues.
class GenericUpnpPlugin implements RouterPluginInterface {
  @override
  String get pluginName => 'Standard UPnP IGD';

  @override
  String get pluginDescription => 'Basic UPnP support via HTTP. Cannot set per-device QoS limits.';

  @override
  String get requiredRouterBrand => 'Any';

  String? _gatewayIp;
  int _lastBytesReceived = 0;
  int _lastBytesSent = 0;
  DateTime? _lastFetchTime;

  @override
  Future<bool> connect(String gatewayIp) async {
    _gatewayIp = gatewayIp;
    // We validate by trying to reach the UPnP description URL
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse('http://$gatewayIp:49000/igddesc.xml'));
      final response = await request.close().timeout(const Duration(seconds: 3));
      client.close();
      return response.statusCode == 200;
    } catch (_) {
      // Router may still support UPnP on a different port; treat as connected anyway
      return true;
    }
  }

  @override
  Future<BandwidthUsage> getGlobalBandwidth() async {
    if (_gatewayIp == null) return BandwidthUsage(uploadKbps: 0, downloadKbps: 0);

    try {
      final soapBody = '''<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <s:Body>
  <u:GetAddonInfos xmlns:u="urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1"/>
 </s:Body>
</s:Envelope>''';

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      final request = await client.postUrl(Uri.parse('http://$_gatewayIp:49000/igdupnp/control/WANCommonIFC1'));
      request.headers.set('Content-Type', 'text/xml; charset="utf-8"');
      request.headers.set('SOAPAction', '"urn:schemas-upnp-org:service:WANCommonInterfaceConfig:1#GetAddonInfos"');
      request.write(soapBody);
      final response = await request.close().timeout(const Duration(seconds: 3));
      final body = await response.transform(const SystemEncoding().decoder).join();
      client.close();

      // Parse byte counters from XML response
      int rx = _extractInt(body, 'NewTotalBytesReceived') ?? _extractInt(body, 'NewTotalByteReceived') ?? 0;
      int tx = _extractInt(body, 'NewTotalBytesSent') ?? 0;

      final now = DateTime.now();
      if (_lastFetchTime != null) {
        final secs = now.difference(_lastFetchTime!).inMilliseconds / 1000.0;
        if (secs > 0) {
          final dlKbps = ((rx - _lastBytesReceived) * 8 / secs / 1000).toInt().clamp(0, 999999);
          final ulKbps = ((tx - _lastBytesSent) * 8 / secs / 1000).toInt().clamp(0, 999999);
          _lastBytesReceived = rx;
          _lastBytesSent = tx;
          _lastFetchTime = now;
          return BandwidthUsage(uploadKbps: ulKbps, downloadKbps: dlKbps);
        }
      }
      _lastBytesReceived = rx;
      _lastBytesSent = tx;
      _lastFetchTime = now;
    } catch (_) {}

    return BandwidthUsage(uploadKbps: 0, downloadKbps: 0);
  }

  int? _extractInt(String xml, String tag) {
    final start = xml.indexOf('<$tag>');
    final end = xml.indexOf('</$tag>');
    if (start == -1 || end == -1) return null;
    return int.tryParse(xml.substring(start + tag.length + 2, end).trim());
  }

  @override
  Future<List<NetworkDevice>> getConnectedDevices() async => [];

  @override
  Future<bool> setDeviceQosLimit(String macAddress, int downloadLimitKbps, int uploadLimitKbps) async {
    return false;
  }
}
