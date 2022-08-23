import 'package:flutter/material.dart';

import 'custom/custom_expansion_tile.dart';

class ExpandableWidget extends StatefulWidget {
  const ExpandableWidget({
    Key? key,
    required this.expandedStateKey,
    this.icon,
    required this.header,
    required this.body,
  }) : super(key: key);

  final String expandedStateKey;
  final Widget header;
  final Widget? icon;
  final Widget body;

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
      elevation: 5,
      shadowColor: Theme.of(context).colorScheme.primary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: CustomExpansionTile(
        key: widget.key,
        title: widget.header,
        leading: widget.icon,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        collapsedIconColor: Theme.of(context).colorScheme.primary,
        iconColor: Theme.of(context).colorScheme.primary,
        maintainState: true,
        children: [widget.body],
      ),
    );
  }
}
