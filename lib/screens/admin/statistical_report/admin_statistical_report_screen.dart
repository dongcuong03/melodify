import 'package:flutter/material.dart';
class AdminStatisticalReportScreen extends StatefulWidget {
  const AdminStatisticalReportScreen({super.key});

  @override
  State<AdminStatisticalReportScreen> createState() => _AdminStatisticalReportScreenState();
}

class _AdminStatisticalReportScreenState extends State<AdminStatisticalReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
              'Báo cáo thống kê'
          ),
        )
    );
  }
}
