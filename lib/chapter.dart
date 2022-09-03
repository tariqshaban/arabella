import 'package:arabella/assets/helpers/dynamic_tr.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assets/components/learning_description.dart';
import 'assets/components/learning_outcomes.dart';
import 'assets/components/learning_progress.dart';
import 'assets/components/lesson_list_vertical.dart';
import 'assets/helpers/shader_callback_helper.dart';
import 'assets/models/chapter_model.dart';
import 'assets/models/providers/background_animation_provider.dart';
import 'assets/models/providers/chapters_provider.dart';

class Chapter extends StatefulWidget {
  const Chapter({Key? key, required this.chapter}) : super(key: key);

  final ChapterModel chapter;

  @override
  State<Chapter> createState() => _ChapterState();
}

class _ChapterState extends State<Chapter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ChaptersProvider.getChapterTranslatableName(
                widget.chapter.chapterName))
            .dtr(context),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(5, 50, 5, 5),
        child: ShaderMask(
          shaderCallback: ShaderCallbackHelper.getShaderCallback(),
          blendMode: BlendMode.dstOut,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(
              4,
              context.read<BackgroundAnimationProvider>().height / 2 - 50,
              4,
              0,
            ),
            children: [
              LearningProgress(chapter: widget.chapter),
              LayoutBuilder(
                builder: (context, constraints) {
                  return constraints.maxWidth > 600
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: LearningDescription(
                                    chapter: widget.chapter)),
                            const SizedBox(width: 20),
                            Flexible(
                                child:
                                    LearningOutcomes(chapter: widget.chapter)),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LearningDescription(chapter: widget.chapter),
                            LearningOutcomes(chapter: widget.chapter),
                          ],
                        );
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Divider(thickness: 2),
              ),
              LessonListVertical(chapter: widget.chapter),
            ],
          ),
        ),
      ),
    );
  }
}
