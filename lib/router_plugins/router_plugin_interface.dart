import '../models/network_device.dart';

abstract class RouterPluginInterface {
  String get pluginName;
  String get pluginDescription;
  String get requiredRouterBrand;
  
  /// Initialize the connection to the gateway
  Future<bool> connect(String gatewayIp);

  /// Get total real-time bandwidth usage of the router
  Future<BandwidthUsage> getGlobalBandwidth();

  /// Retrieve the list of devices natively from the router (if supported)
  Future<List<NetworkDevice>> getConnectedDevices();

  /// Set QoS rules (Bandwidth limits) for a specific MAC address
  /// Returns true if successful, false if not supported or failed.
  Future<bool> setDeviceQosLimit(String macAddress, int downloadLimitKbps, int uploadLimitKbps);
}
