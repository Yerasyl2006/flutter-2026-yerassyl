import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'list_screen.dart';
import 'meetup_form.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _titles = ['Meetups', 'Favourites', 'Profile'];

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: ListenableBuilder(
                listenable: appState,
                builder:
                    (context, child) => Text(
                      appState.profile.name.isEmpty
                          ? 'Guest'
                          : '${appState.profile.name}\n${appState.profile.group}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
              ),
            ),
            for (var i = 0; i < _titles.length; i++)
              ListTile(
                title: Text(_titles[i]),
                selected: _index == i,
                onTap: () {
                  Navigator.pop(context);
                  _go(i);
                },
              ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          ListScreen(),
          ListScreen(onlyFavourites: true),
          ProfileScreen(),
        ],
      ),
      floatingActionButton:
          _index == 2
              ? null
              : FloatingActionButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MeetupForm()),
                    ),
                child: const Icon(Icons.add),
              ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Meetups'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
