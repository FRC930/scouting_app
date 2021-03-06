import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Scouting App Navigation',
              style: Theme.of(context).textTheme.headline5,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logo.png"),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("Match Scouting"),
            onTap: () {
              Navigator.pop(context);

              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("Match Scouting Settings"),
            onTap: () {
              Navigator.pop(context);

              Navigator.pushNamedAndRemoveUntil(
                  context, '/settings/auth', (_) => false);
            },
          ),
        ],
      ),
    );
  }
}
