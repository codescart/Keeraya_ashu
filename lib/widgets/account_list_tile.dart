import 'package:flutter/material.dart';

import '../helpers/current_user.dart';

class AccountListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTapFunc;
  final Widget trailing;
  final bool enableDivider;

  AccountListTile(
      {this.title,
      this.subtitle,
      this.icon,
      this.onTapFunc,
      this.trailing,
      this.enableDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          horizontalTitleGap: 0,
          leading: CurrentUser.language == 'Arabic'
              ? trailing
              : icon != null
                  ? Icon(
                      icon,
                      color: Colors.grey[800],
                    )
                  : null,
          trailing: CurrentUser.language != 'Arabic'
              ? trailing
              : icon != null
                  ? Icon(
                      icon,
                      color: Colors.grey[800],
                    )
                  : null,
          title: Text(
            title,
            textDirection: CurrentUser.textDirection,
            textAlign: TextAlign.start,
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  textDirection: CurrentUser.textDirection,
                  textAlign: TextAlign.start,
                )
              : null,
          onTap: onTapFunc,
        ),
        if (enableDivider)
          Divider(
            height: 0,
          ),
      ],
    );
  }
}
