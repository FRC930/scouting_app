import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
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
            leading: const Icon(Icons.home),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("Home Page"),
            onTap: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );

              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.fact_check),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("Match Scouting"),
            onTap: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );

              Navigator.pushNamed(context, '/match_scouting');
            },
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("Pit Scouting"),
            onTap: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );

              Navigator.pushNamed(context, '/pit_scouting');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("Data Viewer"),
            onTap: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );

              Navigator.pushNamed(context, '/viewer');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("Settings"),
            onTap: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              );

              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("About Us"),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);

              Navigator.pushNamed(context, '/about');
            },
          ),
          const Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text("\u00A9 Mukwonago BEARs Team 930"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
