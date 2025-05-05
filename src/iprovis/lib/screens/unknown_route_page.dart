import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('unknown_route'.tr())),
      body: Center(child: Text('page_not_found'.tr())),
    );
  }
}
