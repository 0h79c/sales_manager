import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _filter = "day";

  Future<Map<String, double>> _loadRevenue() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("orders")
        .orderBy("createdAt", descending: true)
        .get();

    Map<String, double> data = {};
    for (var doc in snapshot.docs) {
      final order = doc.data();
      final createdAt = (order["createdAt"] as Timestamp).toDate();
      final total = (order["total"] as num).toDouble();

      String key = _filter == "day"
          ? DateFormat("dd/MM").format(createdAt)
          : DateFormat("MM/yyyy").format(createdAt);

      data[key] = (data[key] ?? 0) + total;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                  label: const Text("Theo ngày"),
                  selected: _filter == "day",
                  onSelected: (_) => setState(() => _filter = "day")),
              const SizedBox(width: 8),
              ChoiceChip(
                  label: const Text("Theo tháng"),
                  selected: _filter == "month",
                  onSelected: (_) => setState(() => _filter = "month")),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<String, double>>(
              future: _loadRevenue(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có dữ liệu doanh thu"));
                }
                final data = snapshot.data!;
                final labels = data.keys.toList();
                final values = data.values.toList();
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < labels.length) {
                                return Text(labels[index],
                                    style: const TextStyle(fontSize: 10));
                              }
                              return const Text("");
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(values.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                                toY: values[i], width: 20, color: Colors.blue)
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
