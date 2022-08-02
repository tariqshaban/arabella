import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import 'assets/components/extended_floating_action_button.dart';
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    ChaptersProvider.getLessonTranslatableName(
                        widget.chapter.chapterName, widget.lesson),
                  ).tr(),
                  background: Hero(
                    tag: 'lesson_image ${widget.lesson}',
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
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return true;
                          },
                          child: SingleChildScrollView(
                            child: MarkdownBody(data: snapshot.data as String),
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
                Navigator.popAndPushNamed(context, '/lessons', arguments: {
                  'chapter': widget.chapter,
                  'lesson': widget.chapter.lessons[getNextLessonIndex()]
                });
              },
            )
          : null,
    );
  }

  int getNextLessonIndex() {
    int nextIndex = widget.chapter.lessons.indexOf(widget.lesson) + 1;

    return (nextIndex == widget.chapter.lessons.length) ? -1 : nextIndex;
  }
}
