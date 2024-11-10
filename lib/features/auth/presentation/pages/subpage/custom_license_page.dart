import 'package:blogapp/core/common/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomLicensePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const CustomLicensePage());
  const CustomLicensePage({super.key});

  @override
  State<CustomLicensePage> createState() => _CustomLicensePageState();
}

class _CustomLicensePageState extends State<CustomLicensePage> {
  String messages = "";
  void _readFile() async {
    try {
      // Reading from the assets folder
      String content = await rootBundle.loadString('assets/license.txt');
      setState(() {
        messages = content;
      });
    } catch (e) {
      setState(() {
        messages =
            'Error reading file: $e'; // Error handling if file is not found
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _readFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MIT LICENSE"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: messages.isEmpty
                ? const Loader()
                : Text(
                    messages,
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
