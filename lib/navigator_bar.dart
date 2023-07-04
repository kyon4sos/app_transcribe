import 'package:flutter/material.dart';

class Destination {
  const Destination(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

const List<Destination> destinations = <Destination>[
  Destination(Icons.task, '任务', Colors.cyanAccent),
  Destination(Icons.settings, '设置', Colors.greenAccent),
  // Destination(Icons.messenger_outline_rounded, 'Messages'),
  // Destination(Icons.group_outlined, 'Groups'),
];

class NavigatorBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  const NavigatorBar(
      {super.key,
      required this.selectedIndex,
      required this.onDestinationSelected});

  VoidCallback _handleTap(int i) {
    return onDestinationSelected != null
        ? () => onDestinationSelected!(i)
        : () {};
  }

  @override
  Widget build(BuildContext context) {
    final clolrScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (int i = 0; i < destinations.length; i++)
          NavItem(
            label: destinations[i].label,
            icon: destinations[i].icon,
            isSelected: selectedIndex == i,
            color: destinations[i].color,
            onTap: _handleTap(i),
          ),
      ],
    );
  }
}

class NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final void Function() onTap;
  const NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSelected ? Colors.blue : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              )
            ],
          ),
        ),
      ),
    );
  }
}
