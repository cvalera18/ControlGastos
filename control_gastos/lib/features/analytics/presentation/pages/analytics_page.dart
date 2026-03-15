import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/shared/presentation/widgets/empty_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AnalyticsBloc>().add(FetchMonthlySummaryEvent(
            userId: authState.user.id,
            month: _selectedMonth,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
              _fetchData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedMonth.month < DateTime.now().month || _selectedMonth.year < DateTime.now().year
                ? () {
                    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));
                    _fetchData();
                  }
                : null,
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnalyticsLoaded) {
            final summary = state.summary;
            if (summary.count == 0) {
              return const EmptyState(
                icon: Icons.bar_chart_outlined,
                message: 'Sin datos este mes',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('Total del mes', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(summary.total),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text('${summary.count} gastos', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (summary.byCategory.isNotEmpty) ...[
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: summary.byCategory.map((c) {
                          return PieChartSectionData(
                            value: c.total,
                            title: '${c.percentage.toStringAsFixed(0)}%',
                            color: Color(c.categoryColor),
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...summary.byCategory.map((c) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(c.categoryColor),
                          radius: 16,
                          child: Text(c.categoryIcon, style: const TextStyle(fontSize: 12)),
                        ),
                        title: Text(c.categoryName),
                        subtitle: Text('${c.count} gastos · ${c.percentage.toStringAsFixed(1)}%'),
                        trailing: Text(
                          CurrencyFormatter.format(c.total),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                ],
              ],
            );
          }
          if (state is AnalyticsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
