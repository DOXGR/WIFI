class NetworkDevice {
  final String ipAddress;
  String? macAddress;
  String? hostname;
  String? vendor;
  bool isOnline;
  
  // QoS specific fields
  int? downloadLimitKbps;
  int? uploadLimitKbps;

  NetworkDevice({
    required this.ipAddress,
    this.macAddress,
    this.hostname,
    this.vendor,
    this.isOnline = true,
    this.downloadLimitKbps,
    this.uploadLimitKbps,
  });

  factory NetworkDevice.fromIP(String ip) {
    return NetworkDevice(ipAddress: ip);
  }
}

class BandwidthUsage {
  final int uploadKbps;
  final int downloadKbps;

  BandwidthUsage({required this.uploadKbps, required this.downloadKbps});
}
