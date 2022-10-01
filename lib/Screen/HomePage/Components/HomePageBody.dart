import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResultList = [];
  bool _isScanning = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initBluetoothScanning();
  }

  bool noDevice = false;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    scan();
                  },
                  child: const Text('Scan'),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Devices',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Row(
                children: [
                  Text('RSSI'),
                  SizedBox(
                    width: 17,
                  ),
                  Text('txPower'),
                  SizedBox(
                    width: 17,
                  ),
                  Text('Dist.'),
                  SizedBox(
                    width: 17,
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResultList.length,
              itemBuilder: (context, index) {
                num distance = 0;
                bool txNull = false;
                if (scanResultList[index].advertisementData.txPowerLevel !=
                    null) {
                  distance = rssiToDistance(scanResultList[index].rssi,
                      scanResultList[index].advertisementData.txPowerLevel);
                } else {
                  txNull = true;
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListTile(
                        title: Text(scanResultList[index].device.name),
                        subtitle:
                            Text(scanResultList[index].device.id.toString()),
                      ),
                    ),
                    Text(scanResultList[index].rssi.toString()),
                    SizedBox(
                      width: 38,
                    ),
                    Text(scanResultList[index]
                        .advertisementData
                        .txPowerLevel
                        .toString()),
                    SizedBox(
                      width: 30,
                    ),
                    txNull ? Text('N/A') : Text(distance.toString()),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                );
              },
            ),
          ),
          Text(
            "Disclaimer: \nIf txPower is null, then distance can't be calculated.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    ));
  }

  initBluetoothScanning() {
    print('Scan starting');
    flutterBlue.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      setState(() {});
    });
  }

  scan() async {
    if (!_isScanning) {
      scanResultList.clear();
      flutterBlue.startScan(timeout: Duration(seconds: 4));
      flutterBlue.scanResults.listen((result) {
        scanResultList = result;
        setState(() {});
      });
    } else {
      flutterBlue.stopScan();
    }
  }

  printResult() {
    if (scanResultList.isEmpty) {
      print("No Device Found");
    }
    for (int i = 0; i < scanResultList.length; i++) {
      num distance = 0;
      if (scanResultList[i].advertisementData.txPowerLevel != null) {
        distance = rssiToDistance(scanResultList[i].rssi,
            scanResultList[i].advertisementData.txPowerLevel);
      }

      print(
          " Scan Result $i : ${scanResultList[i].device.name} | RSSI : ${scanResultList[i].rssi} | Power: ${scanResultList[i].advertisementData.txPowerLevel} | Distance: $distance");
    }
  }

  num rssiToDistance(int RSSI, int? txPower) {
    /* 
    * RSSI in dBm
    * txPower is a transmitter parameter that calculated according to its physic layer and antenna in dBm
    * Return value in meter
    *
    * You should calculate "PL0" in calibration stage:
    * PL0 = txPower - RSSI; // When distance is distance0 (distance0 = 1m or more)
    * 
    * SO, RSSI will be calculated by below formula:
    * RSSI = txPower - PL0 - 10 * n * log(distance/distance0) - G(t)
    * G(t) ~= 0 //This parameter is the main challenge in achiving to more accuracy.
    * n = 2 (Path Loss Exponent, in the free space is 2)
    * distance0 = 1 (m)
    * distance = 10 ^ ((txPower - RSSI - PL0 ) / (10 * n))
    *
    * Read more details:
    *   https://en.wikipedia.org/wiki/Log-distance_path_loss_model
    */

    int PL0 = txPower! - RSSI;
    return pow(10, ((txPower - RSSI - PL0)) / (10 * 2));
  }
}
