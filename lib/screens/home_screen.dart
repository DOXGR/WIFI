import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_discovery_service.dart';
import '../services/router_manager_service.dart';
import 'device_details_screen.dart';
import 'router_plugin_store_screen.dart';
import 'settings_screen.dart';
import 'widgets/bandwidth_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNetwork();
    });
  }

  Future<void> _initNetwork() async {
    final discoveryService = Provider.of<NetworkDiscoveryService>(context, listen: false);
    await discoveryService.scanNetwork();
    
    if (discoveryService.gatewayIp != null) {
      final routerService = Provider.of<RouterManagerService>(context, listen: false);
      await routerService.initialize(discoveryService.gatewayIp!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discoveryService = Provider.of<NetworkDiscoveryService>(context);
    final routerService = Provider.of<RouterManagerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('wifREMOTE', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _initNetwork(),
          ),
          IconButton(
            icon: const Icon(Icons.extension),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RouterPluginStoreScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildBandwidthCard(routerService.currentBandwidth.downloadKbps, routerService.currentBandwidth.uploadKbps),
          Expanded(
            child: discoveryService.isScanning
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: discoveryService.devices.length,
                    itemBuilder: (context, index) {
                      final device = discoveryService.devices[index];
                      return ListTile(
                        leading: Icon(
                          device.vendor != null && (device.vendor!.contains('Apple') || device.vendor!.contains('Samsung')) 
                            ? Icons.smartphone 
                            : Icons.devices, 
                          color: Colors.blueAccent
                        ),
                        title: Text(device.hostname ?? device.vendor ?? device.ipAddress),
                        subtitle: Text('\${device.ipAddress} \${device.vendor != null ? "• \${device.vendor}" : ""}'),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeviceDetailsScreen(device: device),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandwidthCard(int dlKbps, int ulKbps) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpeedIndicator('Download', dlKbps, Icons.download, Colors.greenAccent),
              _buildSpeedIndicator('Upload', ulKbps, Icons.upload, Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 20),
          const BandwidthChart(),
        ],
      ),
    );
  }

  Widget _buildSpeedIndicator(String label, int speedKbps, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          '\${(speedKbps / 1024).toStringAsFixed(1)} Mbps',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
