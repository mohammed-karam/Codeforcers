import 'package:codeforcers/core/data.dart';
import 'package:codeforcers/features/materials/widgets/topic_card.dart';
import 'package:flutter/material.dart';

class Level0ViewBody extends StatelessWidget {
  const Level0ViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      itemCount: level0Topics.length,
      itemBuilder: (context, index) {
        final topic = level0Topics[index];
        return TopicCard(
          index: index,
          title: topic.topicName,
          topicId: topic.id,
          level: 0,
        );
      },
    );
  }
}
