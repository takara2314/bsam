import 'package:flutter/material.dart';

import 'package:bsam/models/user.dart';

class AthleteSelect extends StatelessWidget {
  const AthleteSelect({
    super.key,
    required this.users,
    required this.userId,
    required this.changeUser
  });

  final List<User> users;
  final String? userId;
  final void Function(String?) changeUser;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.9,
      margin: const EdgeInsets.only(top: 20, bottom: 30),
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.4,
            child: Column(
              children: [
                for (final user in users.sublist(0, users.length ~/ 2))
                  RadioListTile(
                    title: Text(user.displayName!),
                    value: user.id!,
                    groupValue: userId,
                    onChanged: changeUser,
                  )
              ]
            )
          ),
          SizedBox(
            width: width * 0.4,
            child: Column(
              children: [
                for (final user in users.sublist(users.length ~/ 2))
                  RadioListTile(
                    title: Text(user.displayName!),
                    value: user.id!,
                    groupValue: userId,
                    onChanged: changeUser,
                  )
              ]
            )
          ),
        ]
      )
    );
  }
}
