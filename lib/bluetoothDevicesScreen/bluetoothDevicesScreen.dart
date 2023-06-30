import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/receipt/receipt_text_size_type.dart';
import 'package:blue_print_pos/receipt/receipt_text_style_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receipt_generator_client/supabasehandler.dart';

class bluetoothDevicesScreen extends StatefulWidget {
  // final List<LineText> list;
  // final Uint8List bytes;
  // final String resturant_id;
  const bluetoothDevicesScreen({Key? key}) : super(key: key);

  @override
  State<bluetoothDevicesScreen> createState() => _bluetoothDevicesScreenState();
}

class _bluetoothDevicesScreenState extends State<bluetoothDevicesScreen> {
  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  bool _isLoading = false;
  int _loadingAtIndex = -1;

  @override
  void initState(){
    super.initState();

  }

  Future<void> _onScanPressed() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
          statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
        return;
      }
    }

    setState(() => _isLoading = true);
    _bluePrintPos.scan().then((List<BlueDevice> devices) {
      if (devices.isNotEmpty) {
        setState(() {
          _blueDevices = devices;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  void _onDisconnectDevice() {
    _bluePrintPos.disconnect().then((ConnectionStatus status) {
      if (status == ConnectionStatus.disconnect) {
        setState(() {
          _selectedDevice = null;
        });
      }
    });
  }

  Future<void> _onPrintReceipt() async {
    /// Example for Print Image
    final ByteData logoBytes = await rootBundle.load(
      'assets/logo.jpg',
    );



    /// Example for Print Text
    final ReceiptSectionText receiptText = ReceiptSectionText();
    // receiptText.addImage(
    //   base64.encode(Uint8List.view(logoBytes.buffer)),
    //   width: 300,
    // );
    receiptText.addSpacer();
    receiptText.addText(
      'EXCEED YOUR VISION',
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );
    receiptText.addText(
      'MC Koo',
      size: ReceiptTextSizeType.small,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText('Time', '04/06/22, 10:30');
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Apple 4pcs',
      '\$ 10.00',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'TOTAL',
      '\$ 10.00',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Payment',
      'Cash',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.normal,
    );
    receiptText.addSpacer(count: 2);

    /// Example for print QR
    // await _bluePrintPos.printQR('https://www.google.com/', size: 250);
    //
    // await _bluePrintPos.printReceiptImage(widget.bytes,);

    /// Text after QR
    // final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    // receiptSecondText.addText('Powered by Google',
    //     size: ReceiptTextSizeType.small);
    // receiptSecondText.addSpacer();
    // receiptText.
    // await _bluePrintPos.printReceiptText(, feedCount: 1);
  }

  void _onSelectDevice(int index) {
    setState(() {
      _isLoading = true;
      _loadingAtIndex = index;
    });
    final BlueDevice blueDevice = _blueDevices[index];
    Navigator.pop(context, blueDevice);
    _bluePrintPos.connect(blueDevice,timeout: Duration(days: 10)).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        setState(() => _selectedDevice = blueDevice);
        print(_bluePrintPos.isConnected.toString());
        Navigator.pop(context, _selectedDevice);
      } else if (status == ConnectionStatus.timeout) {
        _onDisconnectDevice();
      } else {
        if (kDebugMode) {
          print('$runtimeType - something wrong');
        }
      }
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Select Printer"),
      ),
      body: SafeArea(
        child: _isLoading && _blueDevices.isEmpty
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        )
            : _blueDevices.isNotEmpty
            ? SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: List<Widget>.generate(_blueDevices.length,
                        (int index) {
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: _blueDevices[index].address ==
                                  (_selectedDevice?.address ?? '')
                                  ? _onDisconnectDevice
                                  : () => _onSelectDevice(index),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _blueDevices[index].name,
                                      style: TextStyle(
                                        color: _selectedDevice?.address ==
                                            _blueDevices[index]
                                                .address
                                            ? Colors.blue
                                            : Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _blueDevices[index].address,
                                      style: TextStyle(
                                        color: _selectedDevice?.address ==
                                            _blueDevices[index]
                                                .address
                                            ? Colors.blueGrey
                                            : Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_loadingAtIndex == index && _isLoading)
                            Container(
                              height: 24.0,
                              width: 24.0,
                              margin: const EdgeInsets.only(right: 8.0),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                          if (!_isLoading &&
                              _blueDevices[index].address ==
                                  (_selectedDevice?.address ?? ''))
                            TextButton(
                              onPressed: _onPrintReceipt,
                              child: Container(
                                color: _selectedDevice == null
                                    ? Colors.grey
                                    : Colors.blue,
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  'Test Print',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty
                                    .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(
                                        MaterialState.pressed)) {
                                      return Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5);
                                    }
                                    return Theme.of(context).primaryColor;
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
              ),
            ],
          ),
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'Scan bluetooth device',
                style: TextStyle(fontSize: 24, color: Colors.blue),
              ),
              Text(
                'Press button scan',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _onScanPressed,
        child: const Icon(Icons.search),
        backgroundColor: _isLoading ? Colors.grey : Colors.blue,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
