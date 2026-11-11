
import 'package:flutter/material.dart';

import '../controllers/record_controller.dart';
import '../core/theme/app_theme.dart';
import '../models/territorial_record.dart';

class RecordsScreen extends StatefulWidget {
  final RecordController controller;

  const RecordsScreen({
    super.key,
    required this.controller,
  });

  @override
  State<RecordsScreen> createState() =>
      _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  RecordCategory? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();

    _titleController.clear();
    _areaController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedCategory = null;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveRecord() async {
    FocusScope.of(context).unfocus();

    final valid =
        _formKey.currentState?.validate() ?? false;

    if (!valid || _selectedCategory == null) {
      return;
    }

    final success = await widget.controller.addRecord(
      title: _titleController.text,
      area: _areaController.text,
      description: _descriptionController.text,
      category: _selectedCategory!,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _clearForm();
      _showMessage(
        'Observação salva localmente com sucesso.',
      );
    } else {
      _showMessage(
        widget.controller.error ??
            'Não foi possível salvar a observação.',
      );
    }
  }

  Future<void> _confirmDelete(
    TerritorialRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir observação?'),
          content: const Text(
            'O registro será excluído do '
            'armazenamento local deste dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final removed = await widget.controller.removeRecord(
      record.id,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      removed
          ? 'Observação excluída com sucesso.'
          : widget.controller.error ??
              'Não foi possível excluir a observação.',
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.accent,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.support,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.accent,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final controller = widget.controller;

    if (!controller.isReady) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.isLoading)
                const CircularProgressIndicator()
              else
                const Icon(
                  Icons.storage_outlined,
                  size: 42,
                  color: AppColors.accent,
                ),
              const SizedBox(height: 16),
              Text(
                controller.isLoading
                    ? 'Recuperando registros locais...'
                    : controller.error ??
                        'Não foi possível carregar os registros.',
                textAlign: TextAlign.center,
              ),
              if (!controller.isLoading) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    controller.loadRecords();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final records = controller.records;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.accent,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 36,
                color: Colors.white,
              ),
              SizedBox(height: 16),
              Text(
                'Observações territoriais',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Registre situações observadas '
                'no território e organize '
                'informações para apoiar a gestão.',
                style: TextStyle(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Nova observação',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Os registros serão armazenados '
          'localmente neste dispositivo.',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 22),

        if (controller.isSaving) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
          const Text(
            'Salvando alterações...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (controller.error != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.error!,
              style: const TextStyle(
                color: Color(0xFF713F00),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Form(
          key: _formKey,
          autovalidateMode:
              AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                key: const Key('record_title_field'),
                controller: _titleController,
                enabled: !controller.isBusy,
                maxLength: 70,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: _fieldDecoration(
                  label: 'Título da observação',
                  hint: 'Ex.: Resíduos acumulados',
                  icon: Icons.title,
                ),
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 5) {
                    return 'Informe um título com '
                        'pelo menos 5 caracteres.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<RecordCategory>(
                key: const Key('record_category_field'),
                initialValue: null,
                isExpanded: true,
                decoration: _fieldDecoration(
                  label: 'Categoria',
                  hint: 'Selecione uma categoria',
                  icon: Icons.category_outlined,
                ),
                items: RecordCategory.values.map(
                  (category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    );
                  },
                ).toList(),
                onChanged: controller.isBusy
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                validator: (value) {
                  return value == null
                      ? 'Selecione uma categoria.'
                      : null;
                },
              ),

              const SizedBox(height: 22),

              TextFormField(
                key: const Key('record_area_field'),
                controller: _areaController,
                enabled: !controller.isBusy,
                maxLength: 60,
                textCapitalization:
                    TextCapitalization.words,
                decoration: _fieldDecoration(
                  label: 'Bairro ou região',
                  hint: 'Ex.: Vila Mariana',
                  icon: Icons.location_on_outlined,
                ),
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 3) {
                    return 'Informe um bairro ou '
                        'região com pelo menos '
                        '3 caracteres.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                key: const Key('record_description_field'),
                controller: _descriptionController,
                enabled: !controller.isBusy,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: _fieldDecoration(
                  label: 'Descrição da ocorrência',
                  hint: 'Descreva a situação observada',
                  icon: Icons.notes_rounded,
                ),
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 10) {
                    return 'A descrição deve ter '
                        'pelo menos 10 caracteres.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('record_save_button'),
                  onPressed: controller.isBusy
                      ? null
                      : () {
                          _saveRecord();
                        },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    controller.isSaving
                        ? 'Salvando...'
                        : 'Salvar observação',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(17),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton.icon(
                onPressed: controller.isBusy
                    ? null
                    : _clearForm,
                icon: const Icon(Icons.clear),
                label: const Text('Limpar campos'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Text(
          'Registros cadastrados (${records.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 16),

        if (records.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.support,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 36,
                  color: AppColors.accent,
                ),
                SizedBox(height: 12),
                Text(
                  'Nenhum registro cadastrado.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )
        else
          ...records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RecordCard(
                record: record,
                enabled: !controller.isBusy,
                onDelete: () {
                  _confirmDelete(record);
                },
              ),
            ),
          ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.support,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Os registros são armazenados apenas '
                  'neste dispositivo ou navegador. '
                  'Não são enviados a um servidor. '
                  'Evite incluir nomes, endereços '
                  'completos ou dados pessoais. '
                  'A limpeza dos dados do aplicativo '
                  'ou navegador pode excluir os registros.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Registros de campo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: _buildContent(),
          ),
        );
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  final TerritorialRecord record;
  final VoidCallback onDelete;
  final bool enabled;

  const _RecordCard({
    required this.record,
    required this.onDelete,
    required this.enabled,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.support,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.support,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: AppColors.accent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      record.category.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Excluir registro',
                onPressed: enabled ? onDelete : null,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            record.description,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          const Divider(height: 28),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  record.area,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(record.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
