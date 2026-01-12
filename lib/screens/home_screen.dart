import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/milk_test_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(milkTestResultsProvider.notifier);
      if (notifier.hasMore) {
        notifier.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final testResults = ref.watch(milkTestResultsProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const SizedBox.shrink();
        }

        return Scaffold(
          drawer: Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  accountName: Text(user.username),
                  accountEmail: Text(user.email ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () => context.go('/home'),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Tests History'),
                  onTap: () => context.go('/tests-history'),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Schedule Tests'),
                  onTap: () => context.go('/schedule-tests'),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Find Nearby Vehicles'),
                  onTap: () => context.go('/find-nearby'),
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: const Text('Milk Analyzer'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (value) {
                  if (value == 'profile') {
                    context.push('/profile');
                  } else if (value == 'find_nearby') {
                    context.push('/find-nearby');
                  } else if (value == 'schedule_tests') {
                    context.push('/schedule-tests');
                  } else if (value == 'tests_history') {
                    context.push('/tests-history');
                  } else if (value == 'logout') {
                    _handleLogout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'find_nearby',
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(width: 12),
                        Text('Find Nearby Vehicles'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'schedule_tests',
                    child: Row(
                      children: [
                        Icon(Icons.schedule),
                        SizedBox(width: 12),
                        Text('Schedule Tests'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'tests_history',
                    child: Row(
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 12),
                        Text('Tests History'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(milkTestResultsProvider.notifier).refresh();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Welcome Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                user.username[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    user.username,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Dashboard Metrics
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: testResults.when(
                      data: (results) => _buildDashboardMetrics(results),
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Test Results Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Tests',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        testResults.when(
                          data: (results) => Text(
                            '${ref.read(milkTestResultsProvider.notifier).totalResults} total',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Test Results List
                testResults.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.science_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No test results yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == results.length) {
                          if (ref
                              .read(milkTestResultsProvider.notifier)
                              .hasMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return const SizedBox(height: 16);
                        }

                        final result = results[index];
                        return _buildTestResultCard(context, result);
                      }, childCount: results.length + 1),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(milkTestResultsProvider.notifier)
                                  .refresh();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _getNavIndex(context),
            onTap: (idx) {
              switch (idx) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/tests-history');
                  break;
                case 2:
                  context.go('/schedule-tests');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  int _getNavIndex(BuildContext context) {
    final loc = (GoRouter.of(context) as dynamic).location ?? '';
    if (loc.startsWith('/tests-history')) return 1;
    if (loc.startsWith('/schedule-tests')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  Widget _buildDashboardMetrics(List<dynamic> results) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    final totalTests = ref.read(milkTestResultsProvider.notifier).totalResults;
    final thisWeek = results
        .where((r) => r.timestampUtc.isAfter(weekAgo))
        .length;
    final thisMonth = results
        .where((r) => r.timestampUtc.isAfter(monthAgo))
        .length;
    final latestDate = results.isNotEmpty
        ? DateFormat(
            'MMM dd, yyyy',
          ).format(results.first.timestampUtc.toLocal())
        : 'N/A';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Tests',
                totalTests.toString(),
                Icons.science,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'This Week',
                thisWeek.toString(),
                Icons.calendar_today,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'This Month',
                thisMonth.toString(),
                Icons.calendar_month,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Latest Test',
                latestDate,
                Icons.update,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultCard(BuildContext context, dynamic result) {
    final dateTime = result.timestampUtc.toLocal();
    final dateStr = DateFormat('MMM dd, yyyy').format(dateTime);
    final timeStr = DateFormat('hh:mm a').format(dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.science, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          result.rawLine ?? 'Sample #${result.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$dateStr • $timeStr'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/test-detail', extra: result);
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }
}
