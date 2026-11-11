
import 'package:flutter/material.dart';

import '../controllers/record_controller.dart';
import '../core/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  final RecordController controller;

  const PrivacyScreen({
    super.key,
    required this.controller,
  });

  Future<void> _confirmDeleteAll(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir todos os registros?',
          ),
          content: const Text(
            'Todas as observações armazenadas '
            'localmente serão apagadas. '
            'Essa ação não poderá ser desfeita.',
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
              child: const Text(
                'Excluir definitivamente',
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    final success = await controller.clearRecords();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Todos os registros locais foram excluídos.'
              : controller.error ??
                  'Não foi possível excluir os registros.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final count = controller.totalRecords;

        final canDelete = controller.isReady &&
            !controller.isBusy &&
            count > 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Privacidade e acessibilidade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
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
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        size: 36,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Seus dados, suas escolhas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Entenda quais informações '
                        'o Território Vivo utiliza '
                        'e como controlar seus '
                        'registros locais.',
                        style: TextStyle(
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const _InfoSection(
                  icon: Icons.cloud_outlined,
                  title: 'Dados meteorológicos',
                  description:
                      'O aplicativo consulta a API '
                      'Open-Meteo utilizando coordenadas '
                      'fixas aproximadas de São Paulo. '
                      'Não solicita a localização GPS '
                      'do usuário. As informações '
                      'climáticas são utilizadas '
                      'para gráficos e alertas '
                      'demonstrativos.',
                ),

                const SizedBox(height: 14),

                const _InfoSection(
                  icon: Icons.storage_outlined,
                  title: 'Armazenamento local',
                  description:
                      'As observações cadastradas '
                      'são armazenadas neste dispositivo '
                      'ou navegador. Cada registro '
                      'contém título, categoria, '
                      'bairro ou região, descrição '
                      'e data de criação. '
                      'O aplicativo não envia esses '
                      'registros a um servidor.',
                ),

                const SizedBox(height: 14),

                const _InfoSection(
                  icon: Icons.security_outlined,
                  title: 'Cuidados com a privacidade',
                  description:
                      'Não inclua nomes de cidadãos, '
                      'telefones, documentos ou '
                      'endereços completos. '
                      'O armazenamento local não '
                      'foi projetado para proteger '
                      'informações sensíveis. '
                      'Os registros não são '
                      'sincronizados entre dispositivos.',
                ),

                const SizedBox(height: 14),

                const _InfoSection(
                  icon: Icons.accessibility_new_outlined,
                  title: 'Recursos de acessibilidade',
                  description:
                      'O aplicativo utiliza componentes '
                      'com identificação textual, '
                      'botões com áreas de toque '
                      'ampliadas, contraste visual '
                      'e resumos dos gráficos. '
                      'Também oferece suporte '
                      'a recursos de acessibilidade '
                      'do Flutter e do sistema.',
                ),

                const SizedBox(height: 14),

                const _InfoSection(
                  icon: Icons.info_outline,
                  title: 'Limitações do armazenamento',
                  description:
                      'O armazenamento local pode '
                      'ser apagado ao limpar os dados '
                      'do navegador ou desinstalar '
                      'o aplicativo. Não existe '
                      'backup automático. '
                      'Este projeto é demonstrativo '
                      'e não deve ser utilizado '
                      'para armazenar registros '
                      'críticos ou confidenciais.',
                ),

                const SizedBox(height: 28),

                Semantics(
                  header: true,
                  child: const Text(
                    'Gerenciamento dos registros',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.support,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count '
                        '${count == 1 ? 'registro local' : 'registros locais'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Você pode excluir todas '
                        'as observações armazenadas '
                        'neste dispositivo.',
                        style: TextStyle(
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key(
                            'privacy_delete_all_button',
                          ),
                          onPressed: canDelete
                              ? () {
                                  _confirmDeleteAll(context);
                                }
                              : null,
                          icon: const Icon(
                            Icons.delete_forever_outlined,
                          ),
                          label: Text(
                            controller.isSaving
                                ? 'Excluindo...'
                                : 'Apagar todos os registros',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),

                      if (controller.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          controller.error!,
                          style: const TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ],

                      if (controller.isLoading) ...[
                        const SizedBox(height: 14),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Território Vivo — Global Solution '
                  '2026.2. Projeto acadêmico para '
                  'apoio à análise territorial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.description,
  });

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
            children: [
              ExcludeSemantics(
                child: Icon(
                  icon,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
