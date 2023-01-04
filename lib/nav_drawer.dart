import 'package:flutter/material.dart';

/// NavDrawer is the class that is used to render the bar that comes
/// out from the side of the screen as a menu.
class NavDrawer extends StatelessWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Header with BEAR logo
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
          // This will take the user back to the home page
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
          // This will get the user to the match scouting interface
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
          // This will get the user to the pit scouting interface
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
          // This will get the user to the data viewing page
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
          // Same story here, just the settings page
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
          // The about us page that gives information about the team
          // and the app
          ListTile(
            leading: const Icon(Icons.info),
            iconColor: Theme.of(context).colorScheme.primary,
            title: const Text("About Us"),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);

              Navigator.pushNamed(context, '/about');
            },
          ),
          // This will take up the rest of the space and is a
          // copyright banner
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
