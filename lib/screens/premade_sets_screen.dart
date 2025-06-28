import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../data/premade_study_sets.dart';
import '../main.dart';

/**
 * A screen that displays and manages premade study sets for users.
 * 
 * This screen provides an interface for users to browse, import, and manage
 * predefined study sets created by the system. It includes functionality for
 * filtering sets by subject, importing sets to the user's collection, and
 * removing previously imported sets.
 * 
 * Features:
 * - Browse available premade study sets
 * - Filter sets by subject area
 * - Import sets to user's collection
 * - Remove imported sets
 * - Refresh study set data
 * - Pull-to-refresh functionality
 * 
 * @param username The current user's username for personalization
 * @param onSetImported Callback function triggered when a set is imported or removed
 */
class PremadeSetsScreen extends StatefulWidget {
  /** The current user's username for personalization */
  final String username;
  /** Callback function triggered when a set is imported or removed */
  final VoidCallback onSetImported;

  /**
   * Creates a new PremadeSetsScreen instance.
   * 
   * @param key The widget key for this StatefulWidget
   * @param username The current user's username for personalization
   * @param onSetImported Callback function triggered when a set is imported or removed
   */
  const PremadeSetsScreen({
    super.key,
    required this.username,
    required this.onSetImported,
  });

  @override
  _PremadeSetsScreenState createState() => _PremadeSetsScreenState();
}

/**
 * The state class for the PremadeSetsScreen widget.
 * 
 * This class manages the state of the premade sets screen, including loading
 * study sets from the database, handling user interactions, and managing
 * the UI state for filtering and importing sets.
 */
class _PremadeSetsScreenState extends State<PremadeSetsScreen> {
  /** Database helper instance for data operations */
  final DatabaseHelper _dbHelper = DatabaseHelper();
  /** List of available premade study sets */
  List<Map<String, dynamic>> _premadeSets = [];
  /** List of study sets imported by the current user */
  List<Map<String, dynamic>> _importedSets = [];
  /** Flag indicating whether data is currently being loaded */
  bool _isLoading = true;
  /** Currently selected subject filter */
  String _selectedSubject = 'All';

  /**
   * Initializes the screen state.
   * 
   * This method is called when the widget is first created and loads
   * the initial study set data from the database.
   */
  @override
  void initState() {
    super.initState();
    _loadSets();
  }

  /**
   * Refreshes the study sets data from the database.
   * 
   * This method updates the premade sets in the database and reloads
   * the data for display. It shows success or error messages to the user
   * based on the operation result.
   */
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

  /**
   * Loads study sets data from the database.
   * 
   * This method fetches both premade study sets and the user's imported
   * sets from the database and updates the UI state accordingly.
   */
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

  /**
   * Imports a study set to the user's collection.
   * 
   * This method adds a study set to the user's imported sets and
   * notifies the parent widget of the change. It shows success or
   * error messages to the user based on the operation result.
   * 
   * @param studySetId The ID of the study set to import
   */
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

  /**
   * Removes a study set from the user's collection.
   * 
   * This method removes a study set from the user's imported sets and
   * updates the UI accordingly. It shows success or error messages to
   * the user based on the operation result.
   * 
   * @param studySetId The ID of the study set to remove
   */
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
      widget.onSetImported();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove study set: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /**
   * Checks if a study set is already imported by the user.
   * 
   * @param studySetId The ID of the study set to check
   * @return true if the set is imported, false otherwise
   */
  bool _isSetImported(int studySetId) {
    return _importedSets.any((set) => set['id'] == studySetId);
  }

  /**
   * Filters the study sets based on the selected subject.
   * 
   * This method returns either all study sets or only those matching
   * the currently selected subject filter.
   * 
   * @return A filtered list of study sets
   */
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

  /**
   * Builds the premade sets screen UI.
   * 
   * This method creates a scaffold with an app bar, subject filter dropdown,
   * and a list of study sets. It includes pull-to-refresh functionality
   * and handles loading states.
   * 
   * @param context The build context for this widget
   * @return A Scaffold widget containing the premade sets interface
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Sets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshSets,
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
                  dropdownColor: Colors.transparent,
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
                            color: Colors.transparent,
                            elevation: 0,
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
                                                : () =>
                                                    _importSet(studySet['id']),
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
