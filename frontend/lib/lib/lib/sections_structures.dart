import 'package:flutter/material.dart';
import 'dart:core';

class SectionBase {
  String name;

  SectionBase({required this.name});

  bool isSection() => false;
  bool isPage() => false;

  List<SectionBase> getSubsection() => const [];
  Widget? getPage() => null;
}
class Section extends SectionBase {
  List<SectionBase> subsections = List.empty(growable: true);

  Section({required super.name});

  @override
  bool isSection() => true;

  @override
  List<SectionBase> getSubsection() => subsections;

  static Section fromPageWidgetMap({required String sectionName, required Map<String, dynamic> map}) {
    Section result = Section(name: sectionName);
    map.forEach((key, value) {
      if (value is Widget) {
        result.subsections.add(PageSection(name: key, pageWidget: value) as SectionBase);
      }
      else if (value is Map<String, dynamic>) {
        result.subsections.add(Section.fromPageWidgetMap(sectionName: key, map: value) as SectionBase);
      }
    });

    return result;
  }
}
class PageSection extends SectionBase {
  Widget pageWidget;

  PageSection({required super.name, required this.pageWidget});

  @override
  bool isPage() => true;
  @override
  Widget? getPage() => pageWidget;
}

class SectionStructure {
  Map<String, dynamic> getWidgetMap() => {};
}

class SectionManager {
  static final Map<String, SectionStructure> _structures = {};

  static void addStructure<T extends SectionStructure>({required String name, required T structure})
    => _structures[name] = structure;
  static void removeStructure(String name) => _structures.remove(name);
  static bool isContainStructure(String name) => _structures.containsKey(name);

  static List<String> getAllStructureNames() => _structures.keys.toList();
  static Section? getSectionWithName(String name) {
    Map<String, dynamic>? widgetMap = _structures[name]?.getWidgetMap();
    if (widgetMap == null) return null;
    return Section.fromPageWidgetMap(sectionName: name, map: widgetMap);
  }
}