import 'package:flutter/material.dart';

IconData getIcon(String name) {
  switch (name) {
    case 'computer':
    case 'computador':
    case 'computadora':
    case 'pc':
      return Icons.computer;
    case 'videocam':
    case 'proyector':
    case 'video beam':
    case 'video_beam':
      return Icons.videocam;
    case 'speaker':
    case 'parlante':
    case 'bocina':
    case 'altavoz':
      return Icons.speaker;
    case 'cable':
    case 'hdmi':
      return Icons.cable;
    case 'settings_input_composite':
    case 'rca':
    case 'cable_rca':
      return Icons.settings_input_composite;
    case 'usb':
    case 'cable_usb':
      return Icons.usb;
    case 'electrical_services':
    case 'extension':
    case 'regleta':
      return Icons.electrical_services;
    case 'monitor':
    case 'pantalla':
      return Icons.monitor;
    case 'keyboard':
    case 'teclado':
      return Icons.keyboard;
    case 'mouse':
    case 'raton':
    case 'mouse_':
      return Icons.mouse;
    case 'wifi':
      return Icons.wifi;
    case 'inventory_2':
      return Icons.inventory_2;
    case 'print':
      return Icons.print;
    case 'tv':
      return Icons.tv;
    case 'scanner':
      return Icons.scanner;
    case 'router':
      return Icons.router;
    case 'mic':
      return Icons.mic;
    case 'help_outline':
      return Icons.help_outline;
    default:
      return Icons.inventory_2;
  }
}
