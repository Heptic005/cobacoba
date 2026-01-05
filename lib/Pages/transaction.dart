import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  late String _timeString;
  late Timer _timer;
  // Color limeGreen = const Color.fromARGB(255, 124, 233, 0);
  Color limeGreen = const Color.fromARGB(255, 151, 255, 33);

  final platnomorController = TextEditingController();
  final namabarangController = TextEditingController();
  final customerController = TextEditingController();
  final poController = TextEditingController();
  final namasupirController = TextEditingController();

  final focusPlatnomor = FocusNode();
  final focusNamabarang = FocusNode();
  final focusCustomer = FocusNode();
  final focusPO = FocusNode();
  final focusSupir = FocusNode();

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    // Update every second
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    // Format the date and time as desired
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 90, 30, 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "PT. Dakara Prima Internasional",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeString,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    DateFormat(
                      "EEEE, d MMMM yyyy",
                      "id_ID",
                    ).format(DateTime.now()),
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          // Nominal Timbangan
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indikator Penimbangan
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 0.4),
                  color: const Color.fromARGB(69, 84, 88, 96),
                ),
                child: Stack(
                  children: [
                    Row(
                      spacing: 7,
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: limeGreen,
                            // color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Text(
                          "Weighing Indicator",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          "0 kg",
                          style: TextStyle(
                            fontSize: 64,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Terminal
              Column(
                children: [
                  Text(
                    "Indicator : GST-9000",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Connected to PORT1",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),

          // Input Data Penimbangan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 30,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 0.4),
                  color: const Color.fromARGB(69, 84, 88, 96),
                ),
                child: Form(
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextInput(
                        controller: poController,
                        focus: focusPO,
                        nextFocus: focusSupir,
                        context: context,
                        label: "Nomor Do / PO",
                      ),
                      TextInput(
                        controller: namabarangController,
                        focus: focusNamabarang,
                        nextFocus: focusCustomer,
                        context: context,
                        label: "Nama Barang",
                      ),
                      TextInput(
                        controller: customerController,
                        focus: focusCustomer,
                        nextFocus: focusPO,
                        context: context,
                        label: "Nama Customer",
                      ),
                      TextInput(
                        controller: platnomorController,
                        focus: focusPlatnomor,
                        nextFocus: focusNamabarang,
                        context: context,
                        label: "No. Kendaraan",
                        suffixIcon: Icon(Icons.abc),
                        textCapital: TextCapitalization.characters,
                        validatorText: "Plat No Kendaraan Wajib Diisi!",
                      ),
                      TextInput(
                        controller: namasupirController,
                        focus: focusSupir,
                        context: context,
                        label: "Nama Supir",
                      ),
                      ElevatedButton(
                        // style: ButtonStyle(backgroundColor: WidgetStateColor.fromMap(map)),
                        onPressed: () {},
                        child: Text("Simpan"),
                      ),
                    ],
                  ),
                ),
              ),

              // History
              Container(
                height: 450,
                // width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 25,
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 0.5),
                  color: const Color.fromARGB(69, 84, 88, 96),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Text(
                      "Recent Transaction",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),

                    Container(
                      height: 350,
                      width: 270,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 52, 52, 52),
                            // offset: Offset(-1, 1),
                            blurRadius: 3,
                            spreadRadius: 0.5,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Text("Test"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget TextInput({
    required TextEditingController controller,
    required BuildContext context,
    FocusNode? focus,
    FocusNode? nextFocus,
    String? label,
    String? hint,
    bool? validator,
    String? validatorText,
    int? minline = 1,
    int? maxline = 1,
    Icon? suffixIcon,
    TextCapitalization textCapital = TextCapitalization.none,
    TextInputType? textInputType,
    bool expand = false,
    bool border = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextFormField(
        controller: controller,
        focusNode: focus,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          floatingLabelStyle: TextStyle(color: Colors.white, fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: hint,
          // hintStyle: TextStyle(
          //   color: Colors.white,
          //   fontWeight: FontWeight.w300,
          // ),
          suffixIcon: suffixIcon,
          suffixIconColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              // color: const Color.fromARGB(255, 151, 255, 33),
              color: Color(0xFF0080FF),
              width: 1.5,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          border:
              border
                  ? OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 0.1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )
                  : null,
        ),
        minLines: minline,
        maxLines: maxline,
        expands: expand,
        textCapitalization: textCapital,
        keyboardType: textInputType,
        validator: (value) {
          if (validator != null) {
            if (value == null || value.isEmpty) {
              return validatorText;
            }
            return null;
          }
          return null;
        },
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(nextFocus);
        },
      ),
    );
  }
}
