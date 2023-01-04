import 'package:bearscouts/nav_drawer.dart';
import 'package:bearscouts/themefile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// About us page is static
class BEARScoutsAboutUs extends StatelessWidget {
  const BEARScoutsAboutUs({Key? key}) : super(key: key);

  // All of the following stuff is all text and formatting
  // This should not be difficult to figure out
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      drawer: const NavDrawer(),
      body: Container(
        decoration: backgroundDecoration,
        child: ListView(
          children: [
            Padding(
              child: Text(
                "BEARScouts",
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    ?.copyWith(color: const Color.fromARGB(255, 48, 48, 209)),
                textAlign: TextAlign.center,
              ),
              padding: const EdgeInsets.all(10),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                "FRC Team 930 Mukwonago BEARs",
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Text(
                "Established in 2001",
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "About Us",
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 40),
              child: Text(
                "Who We Are",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(color: const Color.fromARGB(255, 48, 48, 209)),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 40, right: 40),
              child: Text(
                "FRC Team 930 Mukwonago BEARs is a FIRST Robotics Competition "
                "team that meets in Mukwonago, Wisconsin. We strive to embody "
                "the core goals and values of FIRST- spreading the message of "
                "STEM by creating a fun and captivating environment.",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 40),
              child: Text(
                "Our History",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(color: const Color.fromARGB(255, 48, 48, 209)),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 40, right: 40),
              child: Text(
                "Since being established in 2001, members of Team 930 have "
                "worked to establish a place of inspiration and dedication in "
                "our 4 subteams: Electromechanical, Programming, Strategy, and "
                "Business. Being a Detroit World Championship Finalist in 2019, "
                "Team 930 has continued to develop future generations of innovators and leaders.",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 40),
              child: Text(
                "What is BEARScouts?",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(color: const Color.fromARGB(255, 48, 48, 209)),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25, left: 40, right: 40),
              child: Text(
                "BEARScouts is a project started by Team 930 to facilitate "
                "better match scouting for all teams. This project is "
                "completely free and open source, and can be seen on Team "
                "930's Github page. This app is completely customizable, and "
                "can be run on tablets, phones, and even computers using the "
                "Flutter framework.",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Have Questions?",
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 40),
              child: Text(
                "Contact Us!",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(color: const Color.fromARGB(255, 48, 48, 209)),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 50),
              child: Row(children: [
                const Text("\u2022  Email: "),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri(
                        scheme: "mailto",
                        path: "team930@gmail.com",
                        query: "subject=Questions about BEARScouts&body=Hey"
                            " Team 930! I have some questions about BEARScouts...",
                      ),
                    );
                  },
                  child: const Text("team930@gmail.com"),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 50),
              child: Row(children: [
                const Text("\u2022  Website: "),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri(
                        scheme: "https",
                        path: "www.team930.com",
                      ),
                    );
                  },
                  child: const Text("team930.com"),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 50),
              child: Row(children: [
                const Text("\u2022  Instagram: "),
                TextButton(
                  onPressed: () {
                    launchUrl(
                      Uri(
                        scheme: "https",
                        path: "www.instagram.com/team930",
                      ),
                    );
                  },
                  child: const Text("@team930"),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// This combines two value listenable builders into one templated class
// This allows the app to listen to two events to decide when to re-render
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  const ValueListenableBuilder2({
    required this.first,
    required this.second,
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: first,
        builder: (_, a, __) {
          return ValueListenableBuilder<B>(
            valueListenable: second,
            builder: (_, b, __) {
              return builder(context, a, b, child);
            },
          );
        },
      );
}
