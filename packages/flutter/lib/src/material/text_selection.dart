// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'flat_button.dart';
import 'icon_button.dart';
import 'icons.dart';
import 'material.dart';
import 'theme.dart';

const double _kHandleSize = 22.0; // pixels
const double _kToolbarScreenPadding = 8.0; // pixels

/// Manages a copy/paste text selection toolbar.
class _TextSelectionToolbar extends StatelessWidget {
  _TextSelectionToolbar(this.delegate, {Key key}) : super(key: key);

  final TextSelectionDelegate delegate;
  InputValue get value => delegate.inputValue;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = <Widget>[];

    if (!value.selection.isCollapsed) {
      items.add(new FlatButton(child: new Text('CUT'), onPressed: _handleCut));
      items.add(new FlatButton(child: new Text('COPY'), onPressed: _handleCopy));
    }
    items.add(new FlatButton(
      child: new Text('PASTE'),
      // TODO(mpcomplete): This should probably be grayed-out if there is nothing to paste.
      onPressed: _handlePaste
    ));
    if (value.selection.isCollapsed) {
      items.add(new FlatButton(child: new Text('SELECT ALL'), onPressed: _handleSelectAll));
    }
    // TODO(mpcomplete): implement `more` menu.
    items.add(new IconButton(icon: Icons.more_vert));

    return new Material(
      elevation: 1,
      child: new Container(
        height: 44.0,
         child: new Row(mainAxisAlignment: MainAxisAlignment.collapse, children: items)
      )
    );
  }

  void _handleCut() {
    Clipboard.setClipboardData(new ClipboardData()..text = value.selection.textInside(value.text));
    delegate.inputValue = new InputValue(
      text: value.selection.textBefore(value.text) + value.selection.textAfter(value.text),
      selection: new TextSelection.collapsed(offset: value.selection.start)
    );
    delegate.hideToolbar();
  }

  void _handleCopy() {
    Clipboard.setClipboardData(new ClipboardData()..text = value.selection.textInside(value.text));
    delegate.inputValue = new InputValue(
      text: value.text,
      selection: new TextSelection.collapsed(offset: value.selection.end)
    );
    delegate.hideToolbar();
  }

  Future<Null> _handlePaste() async {
    InputValue value = this.value;  // Snapshot the input before using `await`.
    ClipboardData clip = await Clipboard.getClipboardData(Clipboard.kTextPlain);
    if (clip != null) {
      delegate.inputValue = new InputValue(
        text: value.selection.textBefore(value.text) + clip.text + value.selection.textAfter(value.text),
        selection: new TextSelection.collapsed(offset: value.selection.start + clip.text.length)
      );
    }
    delegate.hideToolbar();
  }

  void _handleSelectAll() {
    delegate.inputValue = new InputValue(
      text: value.text,
      selection: new TextSelection(baseOffset: 0, extentOffset: value.text.length)
    );
  }
}

/// Centers the toolbar around the given position, ensuring that it remains on
/// screen.
class _TextSelectionToolbarLayout extends SingleChildLayoutDelegate {
  _TextSelectionToolbarLayout(this.position);

  final Point position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = position.x - childSize.width/2.0;
    double y = position.y - childSize.height;

    if (x < _kToolbarScreenPadding)
      x = _kToolbarScreenPadding;
    else if (x + childSize.width > size.width - 2 * _kToolbarScreenPadding)
      x = size.width - childSize.width - _kToolbarScreenPadding;
    if (y < _kToolbarScreenPadding)
      y = _kToolbarScreenPadding;
    else if (y + childSize.height > size.height - 2 * _kToolbarScreenPadding)
      y = size.height - childSize.height - _kToolbarScreenPadding;

    return new Offset(x, y);
  }

  @override
  bool shouldRelayout(_TextSelectionToolbarLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}

/// Draws a single text selection handle. The [type] determines where the handle
/// points (e.g. the [left] handle points up and to the right).
class _TextSelectionHandlePainter extends CustomPainter {
  _TextSelectionHandlePainter({ this.color });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()..color = color;
    double radius = size.width/2.0;
    canvas.drawCircle(new Point(radius, radius), radius, paint);
    canvas.drawRect(new Rect.fromLTWH(0.0, 0.0, radius, radius), paint);
  }

  @override
  bool shouldRepaint(_TextSelectionHandlePainter oldPainter) {
    return color != oldPainter.color;
  }
}

/// Builder for material-style copy/paste text selection toolbar.
Widget buildTextSelectionToolbar(
    BuildContext context, Point position, TextSelectionDelegate delegate) {
  final Size screenSize = MediaQuery.of(context).size;
  return new ConstrainedBox(
    constraints: new BoxConstraints.loose(screenSize),
    child: new CustomSingleChildLayout(
      delegate: new _TextSelectionToolbarLayout(position),
      child: new _TextSelectionToolbar(delegate)
    )
  );
}

/// Builder for material-style text selection handles.
Widget buildTextSelectionHandle(
    BuildContext context, TextSelectionHandleType type) {
  Widget handle = new SizedBox(
    width: _kHandleSize,
    height: _kHandleSize,
    child: new CustomPaint(
      painter: new _TextSelectionHandlePainter(
        color: Theme.of(context).textSelectionHandleColor
      )
    )
  );

  // [handle] is a circle, with a rectangle in the top left quadrant of that
  // circle (an onion pointing to 10:30). We rotate [handle] to point
  // straight up or up-right depending on the handle type.
  switch (type) {
    case TextSelectionHandleType.left:  // points up-right
      return new Transform(
        transform: new Matrix4.identity().rotateZ(math.PI / 2.0),
        child: handle
      );
    case TextSelectionHandleType.right:  // points up-left
      return handle;
    case TextSelectionHandleType.collapsed:  // points up
      return new Transform(
        transform: new Matrix4.identity().rotateZ(math.PI / 4.0),
        child: handle
      );
  }
}
