import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/database_service.dart';
import 'dart:async';

class BandwidthChart extends StatefulWidget {
  const BandwidthChart({Key? key}) : super(key: key);

  @override
  _BandwidthChartState createState() => _BandwidthChartState();
}

class _BandwidthChartState extends State<BandwidthChart> {
  List<FlSpot> _downloadSpots = [];
  List<FlSpot> _uploadSpots = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Refresh chart every 2 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final history = await DatabaseService.getHistory();
    if (!mounted) return;

    List<FlSpot> dlSpots = [];
    List<FlSpot> ulSpots = [];
    
    int index = 0;
    for (var entry in history) {
      dlSpots.add(FlSpot(index.toDouble(), (entry['downloadKbps'] as int) / 1024.0)); // Convert to Mbps
      ulSpots.add(FlSpot(index.toDouble(), (entry['uploadKbps'] as int) / 1024.0));
      index++;
    }

    setState(() {
      _downloadSpots = dlSpots;
      _uploadSpots = ulSpots;
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_downloadSpots.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text("Collecting history...", style: TextStyle(color: Colors.white54))),
      );
    }

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _downloadSpots,
              isCurved: true,
              color: Colors.greenAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.greenAccent.withOpacity(0.2),
              ),
            ),
            LineChartBarData(
              spots: _uploadSpots,
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
