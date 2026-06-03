import 'package:fl_chart/fl_chart.dart';
import 'dart:mirrors';

void main() {
  try {
    print('Inspecting BarChartRodData:');
    final classMirror = reflectClass(BarChartRodData);
    for (var v in classMirror.declarations.values) {
      if (v is MethodMirror && v.isConstructor) {
        print('Constructor: ${v.constructorName}');
        for (var p in v.parameters) {
          print('  Parameter: ${MirrorSystem.getName(p.simpleName)} (${p.type.reflectedType})');
        }
      }
    }
  } catch (e) {
    print('Mirror reflection not fully supported, trying simple instantiation check...');
  }
}
