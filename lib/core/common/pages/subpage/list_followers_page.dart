import 'package:flutter/material.dart';

class ListFollowers extends StatelessWidget {
  final String otherId;
  const ListFollowers({super.key, required this.otherId});

  static MaterialPageRoute route({required String id}) =>
      MaterialPageRoute(builder: (context) => ListFollowers(otherId: id));
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
