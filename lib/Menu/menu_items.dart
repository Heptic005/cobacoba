import 'package:dakara_weighbridge/Menu/menu_details.dart';
import 'package:dakara_weighbridge/Pages/dashboard.dart';
import 'package:flutter/material.dart';

class MenuItems {
  List<MenuDetails> items = [
    MenuDetails(
      title: "Dashboard",
      icon: Icons.assignment_outlined,
      page: Dashboard(),
    ),
    MenuDetails(
      title: "Transaction",
      icon: Icons.attach_money_rounded,
      page: Text("Transaction"),
    ),
    MenuDetails(
      title: "Report",
      icon: Icons.view_in_ar_rounded,
      page: Text("Report"),
    ),
    // MenuDetails(
    //   title: "Analysis",
    //   icon: Icons.laptop_chromebook_rounded,
    //   page: Analysis(),
    // ),
    // MenuDetails(
    //   title: "Asset",
    //   icon: Icons.app_registration_sharp,
    //   page: Assets(),
    // ),
    MenuDetails(title: "Setting", icon: Icons.settings, page: Text("Setting")),
  ];
}
