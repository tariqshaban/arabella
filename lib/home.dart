import 'dart:math';

import 'package:arabella/assets/models/providers/post_navigation_animation_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/components/lesson_list.dart';
import 'assets/components/navigation_drawer.dart';
import 'assets/helpers/shader_callback_helper.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/covered_material_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool didAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 4000), () {
      context.read<BackgroundAnimationProvider>().changeBackgroundAttributes(
          max(MediaQuery.of(context).size.height * 0.2, 150), 40);
    });
    Future.delayed(const Duration(milliseconds: 4000), () {
      setState(() {
        context.read<PostNavigationAnimationProvider>().animate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('app_name').tr(),
      ),
      drawer: NavigationDrawer(context: context),
      body: Consumer<PostNavigationAnimationProvider>(
          builder: (context, postNavigationAnimationProvider, child) {
        if (postNavigationAnimationProvider.animate) {
          didAnimate = true;
        }
        return AnimatedPadding(
          duration: const Duration(milliseconds: 500),
          padding: didAnimate
              ? const EdgeInsets.symmetric(horizontal: 4)
              : EdgeInsets.only(top: MediaQuery.of(context).size.height),
          child: Consumer<ChaptersProvider>(
            builder: (context, chapters, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(top: 50),
                    child: ShaderMask(
                      shaderCallback: ShaderCallbackHelper.getShaderCallback(),
                      blendMode: BlendMode.dstOut,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: constraints.maxWidth > 1200 ? 2 : 1,
                          mainAxisExtent: 345,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 15,
                        ),
                        padding: EdgeInsetsDirectional.fromSTEB(
                          5,
                          context.read<BackgroundAnimationProvider>().height /
                                  2 -
                              50,
                          5,
                          0,
                        ),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: chapters.chapters.length,
                        itemBuilder: (context, i) {
                          return Card(
                            margin: const EdgeInsetsDirectional.fromSTEB(
                                0, 5, 0, 5),
                            elevation: 5,
                            shadowColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/chapter',
                                  arguments: {
                                    'chapter': chapters.chapters[i],
                                  },
                                );
                              },
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            14, 0, 0, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ChaptersProvider
                                              .getChapterTranslatableName(
                                                  chapters
                                                      .chapters[i].chapterName),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ).tr(),
                                        Hero(
                                          tag:
                                              'attempt_exam ${chapters.chapters[i].chapterName}',
                                          child:
                                              Consumer<CoveredMaterialProvider>(
                                            builder: (context, coveredMaterial,
                                                child) {
                                              return Material(
                                                color: Colors.transparent,
                                                child: IconButton(
                                                  tooltip:
                                                      'chapters.attempt_quiz'
                                                          .tr(),
                                                  iconSize: 20,
                                                  icon: const Icon(
                                                    Icons.note_alt,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                        context, '/quiz',
                                                        arguments: {
                                                          'chapterName':
                                                              chapters
                                                                  .chapters[i]
                                                                  .chapterName,
                                                          'questions': chapters
                                                              .chapters[i]
                                                              .questions
                                                        });
                                                  },
                                                  color: (coveredMaterial
                                                          .didPassQuiz(chapters
                                                              .chapters[i]
                                                              .chapterName))
                                                      ? Colors.green
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                  splashRadius: 20,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  NotificationListener<
                                      OverscrollIndicatorNotification>(
                                    onNotification: (notification) {
                                      notification.disallowIndicator();
                                      return true;
                                    },
                                    child: LessonList(
                                        chapter: chapters.chapters[i]),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            12, 12, 12, 6),
                                    child: Consumer<CoveredMaterialProvider>(
                                      builder:
                                          (context, coveredMaterial, child) {
                                        return Row(
                                          children: [
                                            Text(
                                              'chapters.progress',
                                              style: TextStyle(
                                                height: 1.2,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ).tr(),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(8, 2, 8, 0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child:
                                                      LinearProgressIndicator(
                                                    minHeight: 5,
                                                    value: coveredMaterial
                                                        .getChapterProgress(
                                                            chapters.chapters[i]
                                                                .chapterName),
                                                    backgroundColor:
                                                        Theme.of(context)
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
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}
