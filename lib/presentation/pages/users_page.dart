import 'package:flutter/material.dart';
import 'package:rewardpoints/app/di/service_locator.dart';
import 'package:rewardpoints/presentation/viewmodels/user_list_viewmodel.dart';
import 'package:rewardpoints/presentation/widgets/ui/widgets.dart';
import 'package:rewardpoints/shared/l10n/app_strings.dart';
import 'package:rewardpoints/shared/theme/theme.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final UserListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<UserListViewModel>();
    _viewModel.addListener(_onChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_viewModel.state) {
        UserListState.loading => const AppLoadingView(),
        UserListState.error => AppErrorView(
            message: _viewModel.error?.message ?? AppStrings.commonError,
            onRetry: _viewModel.load,
          ),
        UserListState.empty => AppEmptyView(
            message: AppStrings.usersEmpty,
            icon: Icons.people_outline,
          ),
        UserListState.loaded => _buildList(context),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        tooltip: AppStrings.usersAdd,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      itemCount: _viewModel.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final user = _viewModel.users[index];
        return Dismissible(
          key: ValueKey(user.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            color: Theme.of(context).colorScheme.error,
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          confirmDismiss: (_) => _confirmDelete(context, user.name),
          onDismissed: (_) => _viewModel.deleteUser(user.id),
          child: AppListCard(
            title: user.name,
            subtitle: '${AppStrings.pointBalance}: ${user.pointBalance} pts',
            leading: const Icon(Icons.person_outline),
            onTap: () => Navigator.of(context)
                .pushNamed(
                  '/user-detail',
                  arguments: {'id': user.id, 'name': user.name},
                )
                .then((_) => _viewModel.load()),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.usersDeleteTitle),
        content: Text('${AppStrings.usersDeleteBody} "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.commonDelete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.usersAddTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: AppStrings.usersNameLabel,
            hintText: AppStrings.usersNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _viewModel.createUser(controller.text);
            },
            child: const Text(AppStrings.commonAdd),
          ),
        ],
      ),
    );
  }
}
