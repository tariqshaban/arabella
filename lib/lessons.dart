import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'assets/models/chapter.dart';
import 'assets/models/providers/chapters.dart';

class Lessons extends StatefulWidget {
  const Lessons({Key? key, required this.chapter, required this.lesson})
      : super(key: key);

  final Chapter chapter;
  final String lesson;

  @override
  State<Lessons> createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('app_name').tr(),
      ),
      body: FutureBuilder(
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: MarkdownBody(data: snapshot.data as String),
              ),
            );
          }
          return const SizedBox();
        },
        future: Chapters.getLessonContents(
            context, widget.chapter.chapterName, widget.lesson),
      ),
    );

    // return CarouselSlider(
    //   options: CarouselOptions(
    //     aspectRatio: 2.5,
    //     viewportFraction: 0.75,
    //     enableInfiniteScroll: false,
    //     padEnds: false,
    //   ),
    //   items: widget.chapters.chapters[widget.which].lessons.map((lesson) {
    //     return Builder(
    //       builder: (BuildContext context) {
    //         return Padding(
    //           padding: const EdgeInsets.all(8),
    //           child: ClipRRect(
    //             borderRadius: BorderRadius.circular(15),
    //             child: InkWell(
    //               onTap: () {},
    //               borderRadius: BorderRadius.circular(15),
    //               splashColor: Theme.of(context).colorScheme.primary,
    //               child: Ink(
    //                 child: Stack(children: <Widget>[
    //                   ColorFiltered(
    //                     colorFilter: ColorFilter.mode(
    //                         Colors.black.withOpacity(0.7), BlendMode.dstATop),
    //                     child: Image.asset(
    //                       Chapters.getImageFromLesson(
    //                         widget.chapters.chapters[widget.which].chapterName,
    //                         lesson,
    //                       ),
    //                       width: 250,
    //                       fit: BoxFit.cover,
    //                     ),
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.all(5),
    //                     child: Container(
    //                       decoration: BoxDecoration(
    //                         color: Colors.black.withOpacity(0.5),
    //                         borderRadius: BorderRadius.circular(15),
    //                       ),
    //                       child: Padding(
    //                         padding: const EdgeInsetsDirectional.fromSTEB(
    //                             3, 2, 3, 2),
    //                         child: Text(
    //                           Chapters.getLessonTranslatableName(
    //                                   widget.chapters.chapters[widget.which]
    //                                       .chapterName,
    //                                   lesson)
    //                               .tr(),
    //                           style: const TextStyle(color: Colors.white),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ]),
    //               ),
    //             ),
    //           ),
    //         );
    //       },
    //     );
    //   }).toList(),
    // );
  }
}
