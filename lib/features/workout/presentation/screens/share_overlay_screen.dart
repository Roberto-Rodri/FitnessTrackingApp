import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/theme.dart';
import '../controllers/workout_providers.dart';

class ShareOverlayScreen extends ConsumerStatefulWidget {
  final int sessionId;

  const ShareOverlayScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ShareOverlayScreen> createState() => _ShareOverlayScreenState();
}

class _ShareOverlayScreenState extends ConsumerState<ShareOverlayScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    
    try {
      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary not found');
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to convert image');
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/workout_share.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      if (!mounted) return;
      
      final box = context.findRenderObject() as RenderBox?;
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Just crushed this workout on IronLog!',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e', style: const TextStyle(color: AppTheme.txt1)),
            backgroundColor: AppTheme.coral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(workoutSummaryProvider(widget.sessionId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('Share Workout', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (summary) {
          String weightUnit = 'kg';
          if (summary.exerciseComparisons.isNotEmpty) {
            weightUnit = summary.exerciseComparisons.first.exercise.weightUnit;
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: RepaintBoundary(
                          key: _globalKey,
                          child: SizedBox(
                            width: 360,
                            height: 640,
                            child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bg1,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.bg3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 32),
                              const Icon(Icons.fitness_center, color: AppTheme.amber, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'IRONLOG',
                                textAlign: TextAlign.center,
                                style: AppTheme.monoLarge(color: AppTheme.txt1).copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const Spacer(),
                              
                              Text(
                                summary.session.routineNameSnapshot,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.txt1,
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ShareStatBox(label: 'VOLUME', value: '${summary.totalVolume.toStringAsFixed(0)}$weightUnit'),
                                  const SizedBox(width: 16),
                                  _ShareStatBox(label: 'SETS', value: '${summary.totalSets}'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (summary.totalPRs > 0)
                                _ShareStatBox(label: 'NEW PRs', value: '${summary.totalPRs}', color: AppTheme.amber),
                                
                              const Spacer(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FilledButton.icon(
                    icon: _isSharing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.bg0, strokeWidth: 2))
                        : const Icon(Icons.share),
                    label: Text(
                      _isSharing ? 'Preparing...' : 'Share to Instagram',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.amber,
                      foregroundColor: AppTheme.bg0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSharing ? null : _shareImage,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShareStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ShareStatBox({required this.label, required this.value, this.color = AppTheme.bg3});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: AppTheme.monoSmall(color: color == AppTheme.bg3 ? AppTheme.txt2 : AppTheme.bg0)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.monoLarge(color: color == AppTheme.bg3 ? AppTheme.txt1 : AppTheme.bg0)),
        ],
      ),
    );
  }
}
