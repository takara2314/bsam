import 'package:flutter/material.dart';

import 'package:bsam/pages/navi/pop_dialog.dart';

class NaviAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NaviAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => isPopDialog(context),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
