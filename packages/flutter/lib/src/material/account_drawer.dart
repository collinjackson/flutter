// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'debug.dart';
import 'drawer.dart';
import 'drawer_header.dart';
import 'theme.dart';

/// A scrolling drawer with account information pinned to the top
///
/// Part of the material design [Drawer].
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [DrawerHeader]
///  * [Drawer]
///  * [DrawerItem]
///  * <https://www.google.com/design/spec/patterns/navigation-drawer.html>
class AccountDrawer extends StatelessWidget {
  const AccountDrawer({
    Key key,
    this.coverPhoto,
    this.avatar,
    this.subtitle,
    this.trailing,
    this.child
  }) : super(key: key);

  /// The widget to use as the background of the drawer header
  ///
  /// Typically a [NetworkImage] widget.
  final Widget coverPhoto;

  /// The widget that identifies the account
  ///
  /// Typically a [NetworkImage] widget.
  final Widget avatar;

  /// Additional content displayed after the avatar.
  ///
  /// Typically includes the current user's name and/or email.
  final Widget subtitle;

  /// A widget to display following the subtitle.
  ///
  /// Typically an [Icon] widget wrapped in a [GestureDetector]
  final Widget trailing;

  /// A widget to display below the drawer header
  ///
  /// Typically a [Block] widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new Column(
        children: [
          new AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: new DrawerHeader(
              backgroundChild: coverPhoto,
              child: new Column(
                children: [
                  new Row(
                    children: [
                      new Container(
                        width: 64.0,
                        height: 64.0,
                        child: new ClipOval(child: avatar)
                      )
                    ]
                  ),
                  new Row(
                    children: [
                      new Flexible(child: subtitle),
                      trailing,
                    ]
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start
              )
            )
          ),
          new Flexible(
            child: child
          )
        ]
      )
    );
  }
}
