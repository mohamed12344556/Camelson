import 'package:flutter/material.dart';

/// Configuration model for bottom navigation tabs
class TabConfig {
  final String iconPath;
  final String label;
  final Widget view;
  final Map<String, Widget Function()> routes;
  final bool isProfile;

  const TabConfig({
    required this.iconPath,
    required this.label,
    required this.view,
    this.routes = const {},
    this.isProfile = false,
  });

  /// Create a copy of this config with some properties changed
  TabConfig copyWith({
    String? iconPath,
    String? label,
    Widget? view,
    Map<String, Widget Function()>? routes,
    bool? isProfile,
  }) {
    return TabConfig(
      iconPath: iconPath ?? this.iconPath,
      label: label ?? this.label,
      view: view ?? this.view,
      routes: routes ?? this.routes,
      isProfile: isProfile ?? this.isProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TabConfig &&
        other.iconPath == iconPath &&
        other.label == label &&
        other.isProfile == isProfile;
  }

  @override
  int get hashCode {
    return iconPath.hashCode ^ label.hashCode ^ isProfile.hashCode;
  }

  @override
  String toString() {
    return 'TabConfig(iconPath: $iconPath, label: $label, isProfile: $isProfile)';
  }
}
