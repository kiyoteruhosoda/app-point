import 'package:flutter/material.dart';
import 'package:rewardpoints/app/di/service_locator.dart';
import 'package:rewardpoints/presentation/viewmodels/export_import_viewmodel.dart';
import 'package:rewardpoints/presentation/widgets/ui/widgets.dart';
import 'package:rewardpoints/shared/l10n/app_strings.dart';
import 'package:rewardpoints/shared/theme/theme.dart';

class ExportImportPage extends StatefulWidget {
  const ExportImportPage({super.key});

  @override
  State<ExportImportPage> createState() => _ExportImportPageState();
}

class _ExportImportPageState extends State<ExportImportPage> {
  late final ExportImportViewModel _viewModel;
  final _importPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ExportImportViewModel>();
    _viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _importPathController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppMainHeader(title: AppStrings.dataTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          AppSectionHeader(title: AppStrings.dataExportTitle),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dataExportDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: _viewModel.state == ExportImportState.loading
                      ? AppStrings.commonLoading
                      : AppStrings.dataExportButton,
                  onPressed: _viewModel.state == ExportImportState.loading
                      ? null
                      : _doExport,
                  width: double.infinity,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppSectionHeader(title: AppStrings.dataImportTitle),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dataImportDesc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _importPathController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.dataImportPathLabel,
                    hintText: AppStrings.dataImportPathHint,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSecondaryButton(
                  label: _viewModel.state == ExportImportState.loading
                      ? AppStrings.commonLoading
                      : AppStrings.dataImportButton,
                  onPressed: _viewModel.state == ExportImportState.loading
                      ? null
                      : _doImport,
                  width: double.infinity,
                ),
              ],
            ),
          ),
          if (_viewModel.state == ExportImportState.error)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Text(
                _viewModel.error?.message ?? AppStrings.commonError,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _doExport() async {
    await _viewModel.exportData();
    if (!mounted) return;
    if (_viewModel.state == ExportImportState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppStrings.dataExportSuccess}: ${_viewModel.lastMessage}'),
        ),
      );
      _viewModel.reset();
    }
  }

  Future<void> _doImport() async {
    final path = _importPathController.text.trim();
    if (path.isEmpty) return;
    await _viewModel.importData(path);
    if (!mounted) return;
    if (_viewModel.state == ExportImportState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_viewModel.lastMessage ?? AppStrings.dataImportSuccess),
        ),
      );
      _viewModel.reset();
    } else if (_viewModel.state == ExportImportState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error?.message ?? AppStrings.commonError),
        ),
      );
      _viewModel.reset();
    }
  }
}
