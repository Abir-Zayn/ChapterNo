// Exposes dependencies used by the app entry point.
// Keeps dependency declarations separate from cold-launch execution.
export 'package:flutter/material.dart'
    show
        runApp,
        MaterialApp,
        StatelessWidget,
        Scaffold,
        Center,
        Padding,
        Text,
        TextAlign,
        EdgeInsets,
        Widget,
        BuildContext;

export 'app.dart';
export 'bootstrap.dart';
