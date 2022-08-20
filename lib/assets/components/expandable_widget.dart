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
  ExpansionController expansionController = ExpansionController();

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => expansionController.switchExpansion(),
          child: AbsorbPointer(
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
              child: CustomExpansionTile(
                title: widget.header,
                leading: widget.icon,
                tilePadding: const EdgeInsets.all(8),
                childrenPadding: const EdgeInsets.all(8),
                collapsedIconColor: Theme.of(context).colorScheme.primary,
                iconColor: Theme.of(context).colorScheme.primary,
                maintainState: true,
                expansionController: expansionController,
                children: [widget.body],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
