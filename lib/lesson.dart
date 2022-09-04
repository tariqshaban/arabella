import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:arabella/assets/helpers/dynamic_tr.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'assets/components/expandable_widget.dart';
import 'assets/components/extended_floating_action_button.dart';
import 'assets/components/points_of_interest.dart';
import 'assets/models/chapter_model.dart';
import 'assets/models/providers/assets_provider.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/chapters_provider.dart';
import 'assets/models/providers/covered_material_provider.dart';
import 'assets/models/providers/scroll_direction_provider.dart';

class Lesson extends StatefulWidget {
  const Lesson({Key? key, required this.chapter, required this.lesson})
      : super(key: key);

  final ChapterModel chapter;
  final String lesson;

  @override
  State<Lesson> createState() => _LessonState();
}

class _LessonState extends State<Lesson> {
  late Future<String> getLessonContents = ChaptersProvider.getLessonContents(
      context, widget.chapter.chapterName, widget.lesson);
  late Future<bool> doesContainsPointsOfInterest = containsPointsOfInterest();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<BackgroundAnimationProvider>()
          .changeBackgroundAttributes(0, 0);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CoveredMaterialProvider>()
          .setLessonAsFinished(widget.chapter.chapterName, widget.lesson);
    });

    return WillPopScope(
      onWillPop: () async {
        context.read<BackgroundAnimationProvider>().changeBackgroundAttributes(
            max(MediaQuery.of(context).size.height * 0.1, 150), 40);
        return true;
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverSafeArea(
                top: false,
                sliver: SliverAppBar(
                  pinned: true,
                  expandedHeight: 150,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      ChaptersProvider.getLessonTranslatableName(
                          widget.chapter.chapterName, widget.lesson),
                      style: Theme.of(context).textTheme.headline6,
                    ).dtr(context),
                    background: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.6),
                          BlendMode.dstATop),
                      child: Hero(
                        tag: 'lesson_image ${widget.lesson}',
                        child: Image.file(
                          File(
                            ChaptersProvider.getImageFromLesson(
                              context.read<AssetsProvider>(),
                              widget.chapter.chapterName,
                              widget.lesson,
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: FutureBuilder(
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Expanded(
                        child: NotificationListener<UserScrollNotification>(
                          onNotification: (notification) {
                            if (notification.direction ==
                                ScrollDirection.idle) {
                              return true;
                            }
                            context.read<ScrollDirectionProvider>().direction =
                                notification.direction;
                            return true;
                          },
                          child: SingleChildScrollView(
                            // Used instead of listview to prevent widget rebuild
                            padding: const EdgeInsets.only(top: 10),
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            child: Column(
                              children: [
                                FutureBuilder(
                                  builder: (ctx, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data as bool) {
                                      return ExpandableWidget(
                                        expandedStateKey: 'points_of_interest',
                                        icon: const Icon(Icons.map),
                                        header: const Text(
                                          'lessons.points_of_interest',
                                          style: TextStyle(fontSize: 20),
                                        ).tr(),
                                        body: PointsOfInterest(
                                          chapterName:
                                              widget.chapter.chapterName,
                                          lessonName: widget.lesson,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                  future: doesContainsPointsOfInterest,
                                ),
                                const SizedBox(height: 25),
                                Consumer<AssetsProvider>(
                                    builder: (context, assetsProvider, child) {
                                  return MarkdownBody(
                                    imageDirectory: assetsProvider
                                        .applicationDocumentsDirectory,
                                    fitContent: false,
                                    data: snapshot.data as String,
                                    onTapLink: (text, url, title) async {
                                      await launchUrl(
                                        Uri.parse(url!),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  );
                                }),
                                const SizedBox(height: 75),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
            future: getLessonContents,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.bottomStart,
                child: (getPreviousLessonIndex() != -1)
                    ? ExtendedFloatingActionButton(
                        text: 'lessons.previous_lesson'.tr(),
                        heroTag: 'left fab',
                        icon: const Icon(Icons.navigate_before),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/lesson',
                              arguments: {
                                'chapter': widget.chapter,
                                'lesson': widget
                                    .chapter.lessons[getPreviousLessonIndex()]
                              });
                        },
                      )
                    : const SizedBox(),
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: (getNextLessonIndex() != -1)
                    ? ExtendedFloatingActionButton(
                        text: 'lessons.next_lesson'.tr(),
                        heroTag: 'right fab',
                        icon: const Icon(Icons.navigate_next),
                        iconFirst: false,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/lesson',
                              arguments: {
                                'chapter': widget.chapter,
                                'lesson':
                                    widget.chapter.lessons[getNextLessonIndex()]
                              });
                        },
                      )
                    : ExtendedFloatingActionButton(
                        text: 'lessons.finish_chapter'.tr(),
                        heroTag: 'right fab',
                        icon: const Icon(Icons.exit_to_app),
                        iconFirst: false,
                        onPressed: () {
                          context
                              .read<BackgroundAnimationProvider>()
                              .changeBackgroundAttributes(
                                  max(MediaQuery.of(context).size.height * 0.1,
                                      150),
                                  40);
                          Navigator.of(context).pop();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int getPreviousLessonIndex() {
    int previousIndex = widget.chapter.lessons.indexOf(widget.lesson) - 1;

    return (previousIndex < 0) ? -1 : previousIndex;
  }

  int getNextLessonIndex() {
    int nextIndex = widget.chapter.lessons.indexOf(widget.lesson) + 1;

    return (nextIndex == widget.chapter.lessons.length) ? -1 : nextIndex;
  }

  Future<bool> containsPointsOfInterest() async {
    String chapterName = widget.chapter.chapterName
        .substring(widget.chapter.chapterName.indexOf('-') + 1);
    String lessonName = widget.lesson
        .substring(widget.lesson.indexOf('-') + 1, widget.lesson.indexOf('.'));

    String file = await File(
            '${(await getApplicationDocumentsDirectory()).path}/assets/maps/maps_manifest.json')
        .readAsString();

    try {
      dynamic pointsOfInterest =
          json.decode(file)[chapterName][lessonName]['points_of_interest'];

      return pointsOfInterest != null;
    } catch (_) {
      return false;
    }
  }
}
