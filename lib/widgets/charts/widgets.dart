import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'notion_theme.dart';

class DonutChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;

  const DonutChart({
    Key? key,
    required this.values,
    required this.labels,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty || values.every((v) => v == 0)) {
      return _emptyBox(context);
    }
    return SizedBox(
      height: height,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: values.asMap().entries.map((e) {
            final i = e.key;
            final v = e.value;
            return PieChartSectionData(
              value: v,
              title: labels.length > i ? labels[i] : '',
              radius: 52,
              color: NotionChartTheme.categorical[i % NotionChartTheme.categorical.length],
              titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _emptyBox(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'No data',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }
}

class SimpleLineChart extends StatelessWidget {
  final List<String> xLabels;
  final List<double> yValues;
  final double height;

  const SimpleLineChart({
    Key? key,
    required this.xLabels,
    required this.yValues,
    this.height = 240,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (yValues.isEmpty) return _emptyBox(context);
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (v) => FlLine(color: NotionChartTheme.gridColor(context), strokeWidth: 1)),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(idx >= 0 && idx < xLabels.length ? xLabels[idx] : '', style: NotionChartTheme.axisTextStyle(context)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: NotionChartTheme.axisTextStyle(context)))) ,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: yValues.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: NotionChartTheme.categorical[0],
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text('No data', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))),
    );
  }
}

class GroupedBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double height;

  const GroupedBarChart({
    Key? key,
    required this.labels,
    required this.values,
    this.height = 260,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return _emptyBox(context);
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: NotionChartTheme.gridColor(context), strokeWidth: 1)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: NotionChartTheme.axisTextStyle(context)))),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
              final i = v.toInt();
              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(i >=0 && i < labels.length ? labels[i] : '', style: NotionChartTheme.axisTextStyle(context)));
            })),
          ),
          borderData: FlBorderData(show: false),
          barGroups: values.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
            BarChartRodData(toY: e.value, color: NotionChartTheme.categorical[e.key % NotionChartTheme.categorical.length], width: 18, borderRadius: BorderRadius.circular(4)),
          ])).toList(),
        ),
      ),
    );
  }

  Widget _emptyBox(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text('No data', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))),
    );
  }
}

