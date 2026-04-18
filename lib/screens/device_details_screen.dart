import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/network_device.dart';
import '../services/router_manager_service.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final NetworkDevice device;

  const DeviceDetailsScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceDetailsScreenState createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  double _dlLimit = 0; // 0 means unlimited
  double _ulLimit = 0;

  @override
  void initState() {
    super.initState();
    _dlLimit = (widget.device.downloadLimitKbps ?? 0).toDouble();
    _ulLimit = (widget.device.uploadLimitKbps ?? 0).toDouble();
  }

  Future<void> _applyLimits() async {
    final routerService = Provider.of<RouterManagerService>(context, listen: false);
    
    if (widget.device.macAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MAC Address is required to set QoS.')),
      );
      return;
    }

    bool success = await routerService.setQosLimit(
      widget.device.macAddress!,
      _dlLimit.toInt(),
      _ulLimit.toInt(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QoS limits applied successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply QoS. Does your router plugin support this?')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.hostname ?? 'Device Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP Address: \${widget.device.ipAddress}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('MAC Address: \${widget.device.macAddress ?? "Unknown"}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40),
            
            const Text('Download Limit (Kbps)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _dlLimit,
              min: 0,
              max: 100000,
              divisions: 100,
              label: _dlLimit == 0 ? 'Unlimited' : '\${_dlLimit.toInt()} Kbps',
              onChanged: (val) => setState(() => _dlLimit = val),
            ),
            
            const SizedBox(height: 20),
            const Text('Upload Limit (Kbps)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _ulLimit,
              min: 0,
              max: 100000,
              divisions: 100,
              label: _ulLimit == 0 ? 'Unlimited' : '\${_ulLimit.toInt()} Kbps',
              onChanged: (val) => setState(() => _ulLimit = val),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applyLimits,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Apply Limits', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
