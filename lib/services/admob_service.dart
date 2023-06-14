/*
 *  admob_service.dart
 *
 *  Created by Ilya Chirkunov <xc@yar.net> on 14.08.2022.
 */

import 'package:flutter/material.dart';

class AdmobService {
  static Future<void> init() async {}

  static Widget get bannerBottom => /*const SizedBox.shrink()*/ Container(
        color: Colors.blueGrey,
        width: double.infinity,
        height: AppBar().preferredSize.height,
        child: const Center(child: Text("Mock Ad")),
      );
}
