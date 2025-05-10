import 'package:shadow_box/pages/files/managing/upload_page.dart';
import 'package:shadow_box/sections_structures.dart';
import 'dart:core';

class FileSectionStructure extends SectionStructure {
  @override
  Map<String, dynamic> getWidgetMap() => {
    "Managing" : {
      "Upload" : FileManagingUploadPage()
    }
  };
}