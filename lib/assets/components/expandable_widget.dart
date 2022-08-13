import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/providers/panel_expansion_provider.dart';
import 'custom/custom_expansion_panel.dart';

class ExpandableWidget extends StatefulWidget {
  const ExpandableWidget({
    Key? key,
    required this.expandedStateKey,
    required this.header,
    required this.body,
  }) : super(key: key);

  final String expandedStateKey;
  final Widget header;
  final Widget body;

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Card(
        margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
        elevation: 5,
        shadowColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Consumer<PanelExpansionProvider>(
          builder: (context, panelExpansion, child) {
            return InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => panelExpansion.setExpanded(
                  widget.expandedStateKey,
                  !(panelExpansion.isExpanded[widget.expandedStateKey] ??
                      false)),
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomExpansionPanelList(
                    elevation: 0,
                    expandedHeaderPadding: EdgeInsets.zero,
                    animationDuration: const Duration(milliseconds: 300),
                    iconColor: Theme.of(context).colorScheme.primary,
                    children: [
                      CustomExpansionPanel(
                        backgroundColor: Colors.transparent,
                        isExpanded: panelExpansion
                                .isExpanded[widget.expandedStateKey] ??
                            false,
                        headerBuilder: (context, isExpanded) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [widget.header],
                        ),
                        body: widget.body,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
