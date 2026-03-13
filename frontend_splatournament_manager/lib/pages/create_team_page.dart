import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

class CreateTeamPage extends StatefulWidget {
  final Team? teamToEdit;

  const CreateTeamPage({super.key, this.teamToEdit});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _tagController;
  late final TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.teamToEdit?.name ?? '',
    );
    _tagController = TextEditingController(text: widget.teamToEdit?.tag ?? '');
    _descriptionController = TextEditingController(
      text: widget.teamToEdit?.description ?? '',
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<TeamProvider>(context, listen: false);
      if (widget.teamToEdit != null) {
        await provider.updateTeam(
          widget.teamToEdit!.id,
          name: _nameController.text,
          tag: _tagController.text,
          description: _descriptionController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team erfolgreich aktualisiert')),
        );
      } else {
        await provider.createTeam(
          name: _nameController.text,
          tag: _tagController.text,
          description: _descriptionController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team erfolgreich erstellt')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fehler: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.teamToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Team bearbeiten' : 'Team erstellen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Teamname',
                  hintText: 'Teamname eingeben',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Der Teamname ist erforderlich';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Teamkürzel',
                  hintText: 'Teamkürzel eingeben (max. 3 Zeichen)',
                ),
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Das Teamkürzel ist erforderlich';
                  }
                  if (value.length > 3) {
                    return 'Das Kürzel darf höchstens 3 Zeichen lang sein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung',
                  hintText: 'Teambeschreibung eingeben (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Team aktualisieren' : 'Team erstellen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
