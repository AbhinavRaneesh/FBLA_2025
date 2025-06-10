import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'premade_study_sets.dart';
import 'main.dart';

class PremadeSetsScreen extends StatefulWidget {
  final String username;
  final VoidCallback onSetImported;

  const PremadeSetsScreen({
    super.key,
    required this.username,
    required this.onSetImported,
  });

  @override
  _PremadeSetsScreenState createState() => _PremadeSetsScreenState();
}

class _PremadeSetsScreenState extends State<PremadeSetsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _premadeSets = [];
  List<Map<String, dynamic>> _importedSets = [];
  bool _isLoading = true;
  String _selectedSubject = 'All';

  @override
  void initState() {
    super.initState();
    _loadSets();
  }

  Future<void> _refreshSets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseHelper().refreshPremadeSets();
      await _loadSets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Study sets refreshed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing sets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final premadeSets = await DatabaseHelper().getPremadeStudySets();
      final importedSets =
          await DatabaseHelper().getUserImportedSets(widget.username);

      setState(() {
        _premadeSets = premadeSets;
        _importedSets = importedSets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading study sets: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _importSet(int studySetId) async {
    try {
      await _dbHelper.importPremadeSet(widget.username, studySetId);
      await _loadSets();
      widget.onSetImported();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study set imported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import study set: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeSet(int studySetId) async {
    try {
      await DatabaseHelper().removeImportedSet(widget.username, studySetId);

      setState(() {
        _importedSets.removeWhere((set) => set['id'] == studySetId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study set removed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Notify parent to update its state
      if (widget.onSetImported != null) {
        widget.onSetImported();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove study set: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isSetImported(int studySetId) {
    return _importedSets.any((set) => set['id'] == studySetId);
  }

  List<Map<String, dynamic>> _getFilteredSets() {
    if (_selectedSubject == 'All') {
      return _premadeSets;
    }
    return _premadeSets.where((set) {
      final premadeSet =
          PremadeStudySetsRepository.getPremadeSetByName(set['name']);
      return premadeSet?.subject == _selectedSubject;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Sets'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshSets,
            tooltip: 'Refresh Study Sets',
          ),
        ],
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Subject',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    dropdownColor: const Color(0xFF1D1E33),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      'All',
                      'Math',
                      'Science',
                      'Computer Science',
                    ].map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSubject = value;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _getFilteredSets().length,
                          itemBuilder: (context, index) {
                            final studySet = _getFilteredSets()[index];
                            final isImported = _isSetImported(studySet['id']);
                            final premadeSet =
                                PremadeStudySetsRepository.getPremadeSetByName(
                                    studySet['name']);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _getSubjectColor(
                                                    premadeSet?.subject ?? '')
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getSubjectIcon(
                                                premadeSet?.subject ?? ''),
                                            color: _getSubjectColor(
                                                premadeSet?.subject ?? ''),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                studySet['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                studySet['description'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Subject: ${premadeSet?.subject ?? 'Unknown'}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isImported)
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _removeSet(studySet['id']),
                                              ),
                                            ElevatedButton(
                                              onPressed: isImported
                                                  ? null
                                                  : () => _importSet(
                                                      studySet['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isImported
                                                    ? Colors.grey
                                                    : Colors.blueAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                isImported
                                                    ? 'Imported'
                                                    : 'Import',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math':
        return Colors.blue;
      case 'Science':
        return Colors.green;
      case 'Computer Science':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Math':
        return Icons.calculate;
      case 'Science':
        return Icons.science;
      case 'Computer Science':
        return Icons.computer;
      default:
        return Icons.school;
    }
  }
}
