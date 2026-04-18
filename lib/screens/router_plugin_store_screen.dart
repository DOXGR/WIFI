import 'package:flutter/material.dart';

class RouterPlugin {
  final String id;
  final String name;
  final String description;
  final String targetBrand;
  final bool isInstalled;

  RouterPlugin({
    required this.id,
    required this.name,
    required this.description,
    required this.targetBrand,
    this.isInstalled = false,
  });
}

class RouterPluginStoreScreen extends StatefulWidget {
  const RouterPluginStoreScreen({Key? key}) : super(key: key);

  @override
  _RouterPluginStoreScreenState createState() => _RouterPluginStoreScreenState();
}

class _RouterPluginStoreScreenState extends State<RouterPluginStoreScreen> {
  // Mock data for available plugins
  final List<RouterPlugin> _availablePlugins = [
    RouterPlugin(
      id: 'upnp_generic',
      name: 'Standard UPnP IGD',
      description: 'Basic bandwidth monitoring for most routers. No QoS support.',
      targetBrand: 'Any',
      isInstalled: true,
    ),
    RouterPlugin(
      id: 'tr064_fritzbox',
      name: 'Fritz!Box TR-064',
      description: 'Advanced QoS and device management for AVM Fritz!Box routers.',
      targetBrand: 'AVM Fritz!Box',
      isInstalled: false,
    ),
    RouterPlugin(
      id: 'asuswrt_api',
      name: 'AsusWRT Web API',
      description: 'QoS limits for Asus routers running AsusWRT or Merlin.',
      targetBrand: 'ASUS',
      isInstalled: false,
    ),
    RouterPlugin(
      id: 'ddwrt_ssh',
      name: 'DD-WRT SSH Module',
      description: 'Set tc/iptables limits over SSH for DD-WRT flashed routers.',
      targetBrand: 'DD-WRT',
      isInstalled: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Router Plugin Store'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availablePlugins.length,
        itemBuilder: (context, index) {
          final plugin = _availablePlugins[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plugin.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(plugin.targetBrand, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.blue.withOpacity(0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(plugin.description, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: plugin.isInstalled ? null : () {
                        // Logic to download and load plugin dynamically
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading \${plugin.name}...')),
                        );
                        setState(() {
                          // Mocking the installation process
                          _availablePlugins[index] = RouterPlugin(
                            id: plugin.id,
                            name: plugin.name,
                            description: plugin.description,
                            targetBrand: plugin.targetBrand,
                            isInstalled: true,
                          );
                        });
                      },
                      icon: Icon(plugin.isInstalled ? Icons.check : Icons.download),
                      label: Text(plugin.isInstalled ? 'Installed' : 'Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plugin.isInstalled ? Colors.green : Colors.blueAccent,
                        disabledBackgroundColor: Colors.green.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
