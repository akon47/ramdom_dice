import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ramdom_dice/screen/setting_screen.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  TabController? controller;
  double threshold = 10.0;
  int number = 1;
  ShakeDetector? shakeDetector;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: 2, vsync: this);
    controller!.addListener(tabListener);
    _createOrApplyShakeDetector();

    _loadThreshold();
  }

  _createOrApplyShakeDetector() {
    shakeDetector?.stopListening();
    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: onPhoneShake,
      shakeSlopTimeMS: 300,
      shakeThresholdGravity: threshold,
    );
  }

  _loadThreshold() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      threshold = prefs.getDouble('threshold') ?? 2.7;
      _createOrApplyShakeDetector();
    });
  }

  _setThreshold(double value) async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      threshold = value;
      prefs.setDouble('threshold', threshold);
    });
  }

  onPhoneShake() {
    final rand = Random();
    setState(() {
      number = rand.nextInt(5) + 1;
    });
  }

  tabListener() {
    setState(() {
      _createOrApplyShakeDetector();
    });
  }

  @override
  void dispose() {
    controller!.removeListener(tabListener);
    shakeDetector!.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: renderChildren(),
      ),
      bottomNavigationBar: renderBottomNavigation(),
    );
  }

  List<Widget> renderChildren() {
    return [
      HomeScreen(number: number),
      SettingScreen(threshold: threshold, onThresholdChange: onThresholdChange)
    ];
  }

  BottomNavigationBar renderBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: controller!.index,
      onTap: (int index) {
        setState(() {
          controller!.animateTo(index);
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.edgesensor_high_outlined,
          ),
          label: '주사위',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
          ),
          label: '설정',
        ),
      ],
    );
  }

  onThresholdChange(double value) {
    _setThreshold(value);
  }
}
