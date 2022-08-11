import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Assets/Components/app_drawer.dart';
import 'assets/components/chapter_list.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/covered_material_provider.dart';
import 'assets/models/quiz_metadata.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
            child: Stack(
              children: [
                ListView.separated(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0, MediaQuery.of(context).size.height * 0.2 + 10, 0, 20),
                  separatorBuilder: (BuildContext context, int i) {
                    return const Divider(height: 10, color: Colors.transparent);
                  },
                  itemCount: chapters.chapters.length,
                  itemBuilder: (context, i) {
                    return Card(
                      margin: const EdgeInsets.all(5),
                      elevation: 5,
                      shadowColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12, 0, 12, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ChaptersProvider.getChapterTranslatableName(
                                      chapters.chapters[i].chapterName),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ).tr(),
                                Consumer<CoveredMaterialProvider>(
                                  builder: (context, coveredMaterial, child) {
                                    return IconButton(
                                      tooltip: 'chapters.attempt_quiz'.tr(),
                                      iconSize: 20,
                                      icon: const Icon(
                                        Icons.note_alt,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/quiz',
                                            arguments: {
                                              'chapterName': chapters
                                                  .chapters[i].chapterName,
                                              'questions':
                                                  chapters.chapters[i].questions
                                            });
                                      },
                                      color: (coveredMaterial.getQuizMark(
                                                  chapters.chapters[i]
                                                      .chapterName) >=
                                              QuizMetadata.passingMark)
                                          ? Colors.green
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      splashRadius: 20,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          ChapterList(chapters: chapters, which: 0),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12, 10, 12, 10),
                            child: Consumer<CoveredMaterialProvider>(
                              builder: (context, coveredMaterial, child) {
                                return Row(
                                  children: [
                                    Text(
                                      'chapters.progress',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ).tr(),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: LinearProgressIndicator(
                                            minHeight: 5,
                                            value: coveredMaterial
                                                .getChapterProgress(chapters
                                                    .chapters[i].chapterName),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${(coveredMaterial.getChapterProgress(chapters.chapters[i].chapterName) * 100).round()}%',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width, 40),
                  ),
                  child: Container(
                    height: max(MediaQuery.of(context).size.height * 0.2, 100),
                    decoration: BoxDecoration(
                      boxShadow: const [BoxShadow(blurRadius: 40)],
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 1],
                      ),
                    ),
                    child: AnimatedBackground(
                      behaviour: RandomParticleBehaviour(
                        options: ParticleOptions(
                            particleCount: 50,
                            minOpacity: 0.1,
                            maxOpacity: 0.2,
                            spawnMinSpeed: 5,
                            spawnMaxSpeed: 10,
                            baseColor:
                                Theme.of(context).scaffoldBackgroundColor),
                      ),
                      vsync: this,
                      child: const SizedBox(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
