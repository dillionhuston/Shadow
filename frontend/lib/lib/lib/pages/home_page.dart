import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadow_box/models/home_page_model.dart';
import 'package:shadow_box/sections_structures.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

Widget buildNoEffectButton({required onPressed, Widget? child}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onPressed,
      child: child
    ),
  );
}
Widget buildAvatarHolder({required onPressed}) {
  return buildNoEffectButton(
    onPressed: onPressed,
    child: Container(
      padding: EdgeInsets.all(10),
      child: ClipOval(
          child: Image.asset(
            "Avatar1.jpg",
            width: 35, height: 35,
            fit: BoxFit.cover
          )
      )
    ),
  );
}
Widget buildTileFromSectionPage({required PageSection section, void Function(Widget)? openPageFunc}) {
  return buildNoEffectButton(
    onPressed: () {
      if (openPageFunc != null) openPageFunc(section.pageWidget);
    },
    child: ListTile(
      title: Text(
        section.name,
        overflow: TextOverflow.fade,
        maxLines: 1,
        style: TextStyle(
            color: Colors.white,
            fontSize: 12
        ),
      ),
    ),
  );
}
ExpansionTile buildTileFromSection({required Section section, void Function(Widget)? openPageFunc}) {
  return ExpansionTile(
    initiallyExpanded: true,
    shape: RoundedRectangleBorder(),
    tilePadding: EdgeInsets.symmetric(horizontal: 5.0),
    childrenPadding: EdgeInsets.symmetric(horizontal: 5.0),
    title: Text(
      section.name,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14
      ),
    ),
    children: List.generate(section.subsections.length, (index) {
      final subSection = section.subsections[index];
      if (subSection.isSection()) {
        return buildTileFromSection(
          section: subSection as Section,
          openPageFunc: openPageFunc
        );
      }
      else {
        return buildTileFromSectionPage(section: subSection as PageSection, openPageFunc: openPageFunc);
      }
    }),
  );
}

class _HomePageState extends State<HomePage> {
  String? currSectionName;

  void _changeSection(String? name) {
    setState(() {
      currSectionName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          HomePageHomeBar(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                HomePageSidebar(),
                Consumer<AppState>(
                  builder: (context, pageState, child) {
                    return Expanded(
                      child: pageState.currentOpenPage == null ? Placeholder()
                          : (pageState.currentOpenPage as Widget)
                    );
                  },
                )
              ],
            ),
          )
        ],
      )
    );
  }
}

class HomePageSidebar extends StatefulWidget {
  const HomePageSidebar({super.key});

  @override
  State<HomePageSidebar> createState() => _HomePageSidebarState();
}

class _HomePageSidebarState extends State<HomePageSidebar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, pageState, child) {
        final currSection = pageState.currentSectionName == null ? null
            : SectionManager.getSectionWithName(pageState.currentSectionName as String);

        return Container(
            width: 200,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white38),
                color: Colors.black
            ),
            child: ListView(
              children: currSection == null ? [] :
                List.generate(currSection.subsections.length, (index) {
                  final sectionTmp = currSection.subsections[index];
                  if (sectionTmp.isPage()) {
                    return buildTileFromSectionPage(
                      section: sectionTmp as PageSection,
                      openPageFunc: (pageWidget) {
                        context.read<AppState>().setOpenPage(pageWidget);
                      }
                    );
                  }
                  else {
                    return buildTileFromSection(
                    section: sectionTmp as Section,
                    openPageFunc: (pageWidget) {
                      context.read<AppState>().setOpenPage(pageWidget);
                    });
                  }
                })
            )
        );
      });
  }
}

class HomePageHomeBar extends StatefulWidget {
  const HomePageHomeBar({super.key});

  @override
  State<HomePageHomeBar> createState() => _HomePageHomeBarState();
}

class _HomePageHomeBarState extends State<HomePageHomeBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white38),
        color: Colors.black
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            spacing: 20,
            children: [
              buildNoEffectButton(
                onPressed: () {},
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.transparent
                  ),
                  child: Icon(
                      Icons.file_copy,
                      size: 30,
                      color: Colors.white
                  ),
                ),
              ),
              buildNoEffectButton(
                onPressed: () {
                  context.read<AppState>().setSectionName("File");
                },
                child: const Text(
                  "File",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14
                  ),
                ),
              ),
              buildNoEffectButton(
                onPressed: () {},
                child: const Text(
                  "Docs",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14
                  )
                )
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 20,
            children: [
              buildAvatarHolder(
                  onPressed: () {}
              )
            ],
          )
        ],
      ),
    );
  }
}

