import 'package:flutter/material.dart';

import '../../../routes/flux_navigate.dart';
import '../helper/header_view.dart';
import 'models/story_config.dart';
import 'story_card.dart';
import 'story_collection.dart';
import 'story_constants.dart';

class StoryWidget extends StatefulWidget {
  final bool isFullScreen;
  final Map<String, dynamic> config;
  final bool showChat;
  final Function(Map)? onTapStoryText;

  const StoryWidget({
    Key? key,
    required this.config,
    this.onTapStoryText,
    this.isFullScreen = false,
    this.showChat = false,
  }) : super(key: key);

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  StoryConfig get _storyConfig => StoryConfig.fromJson(widget.config);

  List<StoryCard> renderListStoryCard(
      {double? ratioWidth, double? ratioHeight}) {
    var items = <StoryCard>[];
    for (var item in _storyConfig.data ?? []) {
      items.add(
        StoryCard(
          story: item,
          key: UniqueKey(),
          onTap: widget.onTapStoryText,
          ratioWidth: ratioWidth,
          ratioHeight: ratioHeight,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_storyConfig.active == false) {
      return const SizedBox();
    }

    if (widget.isFullScreen) {
      return StoryCollection(
        listStory: renderListStoryCard(),
        pageCurrent: 0,
        isHorizontal: _storyConfig.isHorizontal,
        showChat: widget.showChat,
        isTab: true,
      );
    } else {
      return _renderListCartStory();
    }
  }

  Widget _renderListCartStory() {
    const _space = SizedBox(width: 12.0);
    final screenSize = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraint) {
        final _widthItem = (constraint.maxWidth -
                (StoryConstants.spaceBetweenStory *
                    _storyConfig.countColumn!)) /
            _storyConfig.countColumn!;
        final _heightItem = StoryConstants.aspectRatio * _widthItem - 10;
        var _listStoryCard = renderListStoryCard(
          ratioWidth: screenSize.width / _widthItem,
          ratioHeight: screenSize.height / _heightItem,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderView(
              headerText: _storyConfig.name ?? ' ',
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _space,
                  ...List.generate(
                    _listStoryCard.length,
                    (index) {
                      return SizedBox(
                        width: _widthItem,
                        height: _heightItem,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  left: StoryConstants.spaceBetweenStory),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(_storyConfig.radius!),
                                child: InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 2,
                                  child: _listStoryCard[index],
                                ),
                              ),
                            ),
                            _openFullScreenStory(context, index),
                          ],
                        ),
                      );
                    },
                  ),
                  _space,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _openFullScreenStory(BuildContext context, int index) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        key: ValueKey('${StoryConstants.storyTapKey}$index'),
        onTap: () {
          FluxNavigate.push(
            MaterialPageRoute(
              builder: (context) => StoryCollection(
                listStory: renderListStoryCard(),
                pageCurrent: index,
                isHorizontal: _storyConfig.isHorizontal,
              ),
            ),
            forceRootNavigator: true,
          );
        },
      ),
    );
  }
}
