import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AiInsightsCard extends StatefulWidget {
  const AiInsightsCard({Key? key}) : super(key: key);

  @override
  State<AiInsightsCard> createState() => _AiInsightsCardState();
}

class _AiInsightsCardState extends State<AiInsightsCard> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<Map<String, dynamic>> _insights = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Try to generate fresh insights, then list
      await _api.post('/insights/generate', {});
      final res = await _api.safeCall(() async => await _api.getRaw('/insights'));
      final list = (res['data'] ?? []) as List<dynamic>;
      setState(() {
        _insights = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('AI Insights', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SizedBox(
                height: 180,
                child: Center(child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red))),
              )
            else if (_insights.isEmpty)
              SizedBox(
                height: 180,
                child: Center(child: Text('No insights yet', style: theme.textTheme.bodyMedium)),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.separated(
                  itemCount: _insights.length.clamp(0, 5),
                  itemBuilder: (context, i) {
                    final it = _insights[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lightbulb_outline),
                      title: Text((it['title'] ?? it['summary'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text((it['summary'] ?? '').toString(), maxLines: 3, overflow: TextOverflow.ellipsis),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


