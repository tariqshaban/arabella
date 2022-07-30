import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'Assets/Components/app_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('app_name').tr(),
      ),
      drawer: AppDrawer(context: context),
      body: Center(),
    );
  }
}
