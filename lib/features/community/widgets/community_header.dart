import 'package:flutter/material.dart';

import '../../home/widgets/flow_logo.dart';

class CommunityHeader extends StatelessWidget {
  const CommunityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: FlowLogo(size: 30),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Comunidad',
                maxLines: 1,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
