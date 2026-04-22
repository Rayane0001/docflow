// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:docflow/config/app_theme.dart';
import 'package:docflow/widgets/app_header.dart';
import 'package:docflow/widgets/nav_bar.dart';
import 'package:docflow/widgets/smart_search_bar.dart';
import 'package:docflow/widgets/toolbar_actions.dart';
import 'package:docflow/widgets/recent_docs_panel.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'DocFlow'),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const SmartSearchBar(),
                const ToolbarActions(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      const Text(
                        'Recent Documents',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/vault'),
                        child: Text(
                          'See all',
                          style: TextStyle(color: kAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: RecentDocsPanel()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 0),
    );
  }
}
