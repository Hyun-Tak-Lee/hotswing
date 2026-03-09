import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/screens/players/widgets/player_list_tile.dart';
import 'package:hotswing/src/screens/players/widgets/players_filter_bottom_sheet.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit_form.dart';

import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayersViewModel(),
      child: const _PlayersScreenContent(),
    );
  }
}

class _PlayersScreenContent extends StatefulWidget {
  const _PlayersScreenContent();

  @override
  State<_PlayersScreenContent> createState() => _PlayersScreenContentState();
}

class _PlayersScreenContentState extends State<_PlayersScreenContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final viewModel = Provider.of<PlayersViewModel>(context, listen: false);

    final double triggerThreshold = ResponsiveUtils.isTablet(context)
        ? 250.0
        : 200.0;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - triggerThreshold) {
      viewModel.loadMore();
    }
  }

  void _showFilterBottomSheet(BuildContext context) async {
    final viewModel = Provider.of<PlayersViewModel>(context, listen: false);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: const PlayersFilterBottomSheet(),
        );
      },
    );

    // 바텀 시트가 닫힌 후 필터 일괄 적용하여 쿼리 패치
    viewModel.applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PlayersViewModel>(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  // 좌측 영역
                  if (viewModel.isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: () => viewModel.setSelectionMode(false),
                    )
                  else
                    const SizedBox(width: 8),

                  Expanded(
                    child: Center(
                      child: viewModel.isSelectionMode
                          ? Text(
                              '${viewModel.selectedPlayerIds.length} 선택됨',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Container(
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: '회원 이름 검색',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black54,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                onChanged: (value) {
                                  viewModel.setSearchQuery(value);
                                },
                              ),
                            ),
                    ),
                  ),

                  // 액션 버튼
                  if (viewModel.isSelectionMode) ...[
                    TextButton(
                      onPressed: () => viewModel.selectAll(),
                      child: const Text(
                        'All',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black87),
                      onPressed: () =>
                          _showMultiDeleteDialog(context, viewModel),
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.checklist, color: Colors.black87),
                      onPressed: () => viewModel.setSelectionMode(true),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.sort, color: Colors.black87),
                    onPressed: () => _showFilterBottomSheet(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 본문
        Expanded(
          child: Consumer<PlayersViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.players.isEmpty && viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.players.isEmpty) {
                return const Center(child: Text('No players found.'));
              }

              return ListView.builder(
                controller: _scrollController,
                padding: isTablet
                    ? const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 16.0,
                      )
                    : EdgeInsets.zero,
                itemCount:
                    viewModel.players.length + (viewModel.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < viewModel.players.length) {
                    final player = viewModel.players[index];
                    final isSelected = viewModel.selectedPlayerIds.contains(
                      player.id,
                    );
                    final isEditing = player.id == viewModel.editingPlayerId;

                    return Column(
                      children: [
                        GestureDetector(
                          onLongPress: () {
                            if (!viewModel.isSelectionMode) {
                              viewModel.setSelectionMode(true);
                              viewModel.toggleSelection(player.id);
                            }
                          },
                          onTap: () {
                            if (viewModel.isSelectionMode) {
                              viewModel.toggleSelection(player.id);
                            }
                          },
                          child: Row(
                            children: [
                              if (viewModel.isSelectionMode)
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    viewModel.toggleSelection(player.id);
                                  },
                                ),
                              Expanded(
                                child: PlayerListTile(
                                  player: player,
                                  onDelete: viewModel.isSelectionMode
                                      ? null
                                      : () => _showDeleteDialog(
                                          context,
                                          viewModel,
                                          player,
                                        ),
                                  onEdit: viewModel.isSelectionMode
                                      ? null
                                      : () =>
                                            viewModel.toggleEditMode(player.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: isEditing
                              ? PlayerEditForm(
                                  player: player,
                                  onCancel: () =>
                                      viewModel.toggleEditMode(null),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PlayersViewModel viewModel,
    Player player,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: '플레이어 삭제',
          message: '${player.name} 플레이어를 삭제하시겠습니까?',
          confirmText: '삭제',
          isDestructive: true,
          onConfirm: () {
            viewModel.deletePlayer(player);
          },
        );
      },
    );
  }

  void _showMultiDeleteDialog(
    BuildContext context,
    PlayersViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: '플레이어 삭제',
          message:
              '선택한 ${viewModel.selectedPlayerIds.length}명의 플레이어를 삭제하시겠습니까?',
          confirmText: '삭제',
          isDestructive: true,
          onConfirm: () {
            viewModel.deleteSelectedPlayers();
          },
        );
      },
    );
  }
}
