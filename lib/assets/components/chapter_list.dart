import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/providers/chapters.dart';

class ChapterList extends StatefulWidget {
  const ChapterList({Key? key, required this.chapters, required this.which})
      : super(key: key);

  final Chapters chapters;
  final int which;

  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 2.5,
        viewportFraction: 0.75,
        enableInfiniteScroll: false,
        padEnds: false,
      ),
      items: widget.chapters.chapters[widget.which].lessons.map((lesson) {
        return Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(15),
                  splashColor: Theme.of(context).colorScheme.primary,
                  child: Ink(
                    child: Stack(children: <Widget>[
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.7), BlendMode.dstATop),
                        child: Image.asset(
                          Chapters.getImageFromLesson(
                            widget.chapters.chapters[widget.which].chapterName,
                            lesson,
                          ),
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                3, 2, 3, 2),
                            child: Text(
                              Chapters.getLessonTranslatableName(
                                      widget.chapters.chapters[widget.which]
                                          .chapterName,
                                      lesson)
                                  .tr(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
