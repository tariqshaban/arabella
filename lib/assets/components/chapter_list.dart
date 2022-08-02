import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/providers/chapters_provider.dart';

class ChapterList extends StatefulWidget {
  const ChapterList({Key? key, required this.chapters, required this.which})
      : super(key: key);

  final ChaptersProvider chapters;
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
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/lessons', arguments: {
                    'chapter': widget.chapters.chapters[widget.which],
                    'lesson': lesson
                  });
                },
                borderRadius: BorderRadius.circular(15),
                splashColor: Theme.of(context).colorScheme.primary,
                child: Ink(
                  child: Stack(children: <Widget>[
                    Hero(
                      tag: 'lesson_image $lesson',
                      child: Image.asset(
                        ChaptersProvider.getImageFromLesson(
                          widget.chapters.chapters[widget.which].chapterName,
                          lesson,
                        ),
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Text(
                          ChaptersProvider.getLessonTranslatableName(
                                  widget.chapters.chapters[widget.which]
                                      .chapterName,
                                  lesson)
                              .tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
