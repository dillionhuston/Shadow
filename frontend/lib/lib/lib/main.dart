import 'package:shadow_box/models/home_page_model.dart';
import 'package:shadow_box/pages/files/structures.dart';
import 'package:shadow_box/pages/home_page.dart';
import 'package:shadow_box/sections_structures.dart';


void main() {
  SectionManager.addStructure(name: "File", structure: FileSectionStructure());
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const ShadowBoxApp()
    )
  );
}

class ShadowBoxApp extends StatelessWidget {
  const ShadowBoxApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow Box',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.black)),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}