import 'package:flutter/material.dart';

class Menu1Widget extends StatefulWidget {
  const Menu1Widget({super.key});

  @override
  State<Menu1Widget> createState() => _Menu1WidgetState();
}

class _Menu1WidgetState extends State<Menu1Widget> {
  @override
  void initState() {
    super.initState();
    initializeData(); // 呼叫自定義的初始化方法
  }

  Future<void> initializeData() async {}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("測試"),
      ),
      body: const Center(
        child: Text(
          "測試",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
    );
  }
}
