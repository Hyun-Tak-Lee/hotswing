import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/screens/players/widgets/player_list_tile.dart';
import 'package:hotswing/src/screens/players/widgets/players_right_side_menu.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/widgets/dialogs/confirmation_dialog.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

    // 태블릿에서는 아이템 높이가 작아(한 줄) 250px 정도면 약 4개 분량의 여유가 있음
    final double triggerThreshold = ResponsiveUtils.isTablet(context)
        ? 250.0
        : 200.0;

    // 하단에서 지정된 픽셀만큼 남았을 때 추가 데이터 로드 트리거
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - triggerThreshold) {
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PlayersViewModel>(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: viewModel.isSelectionMode
            ? Text(
                '${viewModel.selectedPlayerIds.length} 선택됨',
                style: const TextStyle(color: Colors.black87),
              )
            : const Text('회원 목록', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: viewModel.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => viewModel.setSelectionMode(false),
              )
            : null,
        actions: [
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
              icon: const Icon(Icons.delete),
              onPressed: () => _showMultiDeleteDialog(context, viewModel),
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () => viewModel.setSelectionMode(true),
            ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: const PlayersRightSideMenu(),
      body: Consumer<PlayersViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.players.isEmpty && viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.players.isEmpty) {
            return const Center(child: Text('No players found.'));
          }

          return ListView.builder(
            controller: _scrollController,
            // 태블릿에서는 좌우 여백을 줘서 리스트가 너무 넓어 보이지 않게 함
            padding: isTablet
                ? const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)
                : EdgeInsets.zero,
            itemCount: viewModel.players.length + (viewModel.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < viewModel.players.length) {
                final player = viewModel.players[index];
                final isSelected = viewModel.selectedPlayerIds.contains(
                  player.id,
                );

                return GestureDetector(
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
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // 하단 로딩 인디케이터
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        },
      ),
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
