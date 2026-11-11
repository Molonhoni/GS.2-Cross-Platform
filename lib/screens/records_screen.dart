
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

    _selectedCategory = null;
  }

  void _saveRecord() {
    FocusScope.of(context).unfocus();

    final isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid || _selectedCategory == null) {
      return;
    }

    widget.controller.addRecord(
      title: _titleController.text,
      area: _areaController.text,
      description: _descriptionController.text,
      category: _selectedCategory!,
    );

    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Observação registrada com sucesso.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            'O registro será removido desta sessão. '
            'Essa ação não pode ser desfeita.',
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

    widget.controller.removeRecord(record.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Observação excluída.'),
        behavior: SnackBarBehavior.floating,
      ),
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

  @override
  Widget build(BuildContext context) {
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
        child: ListView(
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
              'Preencha os campos abaixo para '
              'cadastrar uma observação.',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 22),

            Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    key: const Key('record_title_field'),
                    controller: _titleController,
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
                    onChanged: (value) {
                      _selectedCategory = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione uma categoria.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  TextFormField(
                    key: const Key('record_area_field'),
                    controller: _areaController,
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
                    key:
                        const Key('record_description_field'),
                    controller: _descriptionController,
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
                      onPressed: _saveRecord,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Salvar observação'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(17),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: TextButton.icon(
                      onPressed: _clearForm,
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpar campos'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, child) {
                final records = widget.controller.records;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(16),
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
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'As observações cadastradas '
                              'aparecerão aqui.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...records.map(
                        (record) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: 14),
                          child: _RecordCard(
                            record: record,
                            onDelete: () {
                              _confirmDelete(record);
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

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
                      'Versão demonstrativa: os registros '
                      'são mantidos apenas durante a '
                      'execução do aplicativo. '
                      'Não inclua nomes de cidadãos, '
                      'endereços completos ou outros '
                      'dados pessoais. A persistência '
                      'local será implementada na '
                      'próxima etapa.',
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
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final TerritorialRecord record;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.record,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

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
        border: Border.all(color: AppColors.support),
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
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Excluir registro',
                onPressed: onDelete,
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
