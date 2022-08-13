import 'dart:convert';

import 'package:arabella/assets/models/providers/covered_material_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import 'assets/components/extended_floating_action_button.dart';
import 'assets/components/points_of_interest.dart';
import 'assets/models/chapter_model.dart';
import 'assets/models/providers/chapters_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CoveredMaterialProvider>()
          .setLessonAsFinished(widget.chapter.chapterName, widget.lesson);
    });

    return Scaffold(
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
                  ).tr(),
                  background: Hero(
                    tag: 'lesson_image ${widget.lesson}',
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.6),
                          BlendMode.dstATop),
                      child: Image.asset(
                        ChaptersProvider.getImageFromLesson(
                          widget.chapter.chapterName,
                          widget.lesson,
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
                padding: const EdgeInsetsDirectional.fromSTEB(8, 10, 8, 0),
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    Expanded(
                      child: NotificationListener<UserScrollNotification>(
                        onNotification: (notification) {
                          if (notification.direction == ScrollDirection.idle) {
                            return true;
                          }

                          context.read<ScrollDirectionProvider>().direction =
                              notification.direction;
                          return true;
                        },
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            MarkdownBody(data: snapshot.data as String),
                            FutureBuilder(
                              builder: (ctx, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.data as bool) {
                                  return Card(
                                    margin: const EdgeInsetsDirectional
                                        .fromSTEB(5, 15, 5, 5),
                                    elevation: 5,
                                    shadowColor:
                                        Theme.of(context).colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListView(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(5, 5, 5, 5),
                                      shrinkWrap: true,
                                      children: [
                                        const Text(
                                          'lessons.points_of_interest',
                                          style: TextStyle(fontSize: 20),
                                        ).tr(),
                                        PointsOfInterest(
                                          chapterName:
                                              widget.chapter.chapterName,
                                          lessonName: widget.lesson,
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0, 10, 0, 0),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              future: containsPointsOfInterest(),
                            ),
                            const SizedBox(height: 75),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
          future: ChaptersProvider.getLessonContents(
              context, widget.chapter.chapterName, widget.lesson),
        ),
      ),
      floatingActionButton: (getNextLessonIndex() != -1)
          ? ExtendedFloatingActionButton(
              text: const Text('lessons.next_lesson').tr(),
              icon: const Icon(Icons.navigate_next),
              iconFirst: false,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/lesson', arguments: {
                  'chapter': widget.chapter,
                  'lesson': widget.chapter.lessons[getNextLessonIndex()]
                });
              },
            )
          : ExtendedFloatingActionButton(
              text: const Text('lessons.finish_chapter').tr(),
              icon: const Icon(Icons.exit_to_app),
              iconFirst: false,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
    );
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

    String file = await rootBundle.loadString('assets/maps/maps_manifest.json');

    try {
      dynamic pointsOfInterest =
          json.decode(file)[chapterName][lessonName]['points_of_interest'];

      return pointsOfInterest != null;
    } catch (_) {
      return false;
    }
  }
}
