import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Assets/Components/app_drawer.dart';
import 'assets/components/chapter_list.dart';
import 'assets/models/providers/chapters_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('app_name').tr(),
      ),
      drawer: AppDrawer(context: context),
      body: Consumer<ChaptersProvider>(
        builder: (context, chapters, child) {
          return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return true;
            },
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int i) {
                return const SizedBox(height: 10);
              },
              itemCount: chapters.chapters.length,
              itemBuilder: (context, i) {
                return Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ChaptersProvider.getChapterTranslatableName(
                                chapters.chapters[i].chapterName),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ).tr(),
                          IconButton(
                            tooltip: 'chapters.attempt_quiz'.tr(),
                            iconSize: 20,
                            icon: const Icon(
                              Icons.note_alt,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/quiz', arguments: {
                                'chapterName': chapters.chapters[i].chapterName,
                                'questions': chapters.chapters[i].questions
                              });
                            },
                            color: Theme.of(context).colorScheme.primary,
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    ChapterList(chapters: chapters, which: i),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
