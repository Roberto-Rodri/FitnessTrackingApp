import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/machine.dart';
import '../controllers/machine_providers.dart';
import 'empty_state.dart';
import 'error_state.dart';

Future<Machine?> showMachinePickerSheet(BuildContext context) {
  final theme = Theme.of(context);
  return showModalBottomSheet<Machine>(
    context: context,
    backgroundColor: theme.colorScheme.surfaceContainerHigh,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => const _MachinePickerSheet(),
  );
}

class _MachinePickerSheet extends ConsumerStatefulWidget {
  const _MachinePickerSheet();

  @override
  ConsumerState<_MachinePickerSheet> createState() => _MachinePickerSheetState();
}

class _MachinePickerSheetState extends ConsumerState<_MachinePickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createMachine() async {
    final name = _searchQuery.trim();
    if (name.isEmpty) return;
    
    setState(() => _isCreating = true);
    try {
      await ref.read(machinesProvider.notifier).createMachine(name);
      final machines = await ref.read(machinesProvider.future);
      final newMachine = machines.firstWhere(
        (m) => m.name.toLowerCase() == name.toLowerCase(),
      );
      if (mounted) {
        Navigator.of(context).pop(newMachine);
      }
    } catch (e) {
      if (mounted) {
        String errMsg = 'Failed to create machine.';
        if (e.toString().contains('already exists')) {
          errMsg = 'A machine with this name already exists.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg, style: const TextStyle(color: AppTheme.txt1)),
            backgroundColor: AppTheme.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final machinesAsync = ref.watch(machinesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Machine',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search or enter new machine',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                onSubmitted: (_) {
                  if (_searchQuery.isNotEmpty && !machinesAsync.isLoading) {
                    _createMachine();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: machinesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorCard(
                  message: 'Failed to load machines',
                  onRetry: () => ref.refresh(machinesProvider),
                ),
                data: (machines) {
                  final filtered = _searchQuery.isEmpty 
                    ? machines 
                    : machines.where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                  final exactMatch = machines.any(
                    (m) => m.name.toLowerCase() == _searchQuery.toLowerCase().trim()
                  );

                  return ListView(
                    controller: scrollController,
                    children: [
                      if (_searchQuery.isNotEmpty && !exactMatch)
                        ListTile(
                          leading: const Icon(Icons.add, color: AppTheme.amber),
                          title: Text(
                            'Create "${_searchQuery.trim()}"',
                            style: const TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold),
                          ),
                          onTap: _isCreating ? null : _createMachine,
                          trailing: _isCreating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                        ),
                      if (filtered.isEmpty && _searchQuery.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: EmptyState(
                            icon: Icon(Icons.precision_manufacturing_outlined, size: 48, color: AppTheme.txt2),
                            headline: 'No machines',
                            subtitle: 'Type above to create your first machine.',
                          ),
                        ),
                      ...filtered.map((machine) {
                        return ListTile(
                          leading: const Icon(Icons.precision_manufacturing_outlined),
                          title: Text(machine.name),
                          onTap: () => Navigator.of(context).pop(machine),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
