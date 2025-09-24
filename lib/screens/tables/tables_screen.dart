import 'package:flutter/material.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Tables'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Tables',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  isDark ? const Color(0xFF4B5563) : const Color(0xFFF9FAFB),
                ),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Office')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Start Date')),
                  DataColumn(label: Text('Salary')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('Tiger Nixon')),
                    DataCell(Text('System Architect')),
                    DataCell(Text('Edinburgh')),
                    DataCell(Text('61')),
                    DataCell(Text('2011/04/25')),
                    DataCell(Text('\$320,800')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Garrett Winters')),
                    DataCell(Text('Accountant')),
                    DataCell(Text('Tokyo')),
                    DataCell(Text('63')),
                    DataCell(Text('2011/07/25')),
                    DataCell(Text('\$170,750')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Ashton Cox')),
                    DataCell(Text('Junior Technical Author')),
                    DataCell(Text('San Francisco')),
                    DataCell(Text('66')),
                    DataCell(Text('2009/01/12')),
                    DataCell(Text('\$86,000')),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 