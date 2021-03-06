// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  testWidgets('LayoutBuilder parent size', (WidgetTester tester) {
    Size layoutBuilderSize;
    Key childKey = new UniqueKey();

    tester.pumpWidget(
      new Center(
        child: new SizedBox(
          width: 100.0,
          height: 200.0,
          child: new LayoutBuilder(
            builder: (BuildContext context, Size size) {
              layoutBuilderSize = size;
              return new SizedBox(
                key: childKey,
                width: size.width / 2.0,
                height: size.height / 2.0
              );
            }
          )
        )
      )
    );

    expect(layoutBuilderSize, const Size(100.0, 200.0));
    RenderBox box = tester.renderObject(find.byKey(childKey));
    expect(box.size, equals(const Size(50.0, 100.0)));
  });

  testWidgets('LayoutBuilder stateful child', (WidgetTester tester) {
    Size layoutBuilderSize;
    StateSetter setState;
    Key childKey = new UniqueKey();
    double childWidth = 10.0;
    double childHeight = 20.0;

    tester.pumpWidget(
      new LayoutBuilder(
        builder: (BuildContext context, Size size) {
          layoutBuilderSize = size;
          return new StatefulBuilder(
            builder: (BuildContext context, StateSetter setter) {
              setState = setter;
              return new SizedBox(
                key: childKey,
                width: childWidth,
                height: childHeight
              );
            }
          );
        }
      )
    );

    expect(layoutBuilderSize, equals(const Size(800.0, 600.0)));
    RenderBox box = tester.renderObject(find.byKey(childKey));
    expect(box.size, equals(const Size(10.0, 20.0)));

    setState(() {
      childWidth = 100.0;
      childHeight = 200.0;
    });
    tester.pump();
    box = tester.renderObject(find.byKey(childKey));
    expect(box.size, equals(const Size(100.0, 200.0)));
  });

  testWidgets('LayoutBuilder stateful parent', (WidgetTester tester) {
    Size layoutBuilderSize;
    StateSetter setState;
    Key childKey = new UniqueKey();
    double childWidth = 10.0;
    double childHeight = 20.0;

    tester.pumpWidget(
      new Center(
        child: new StatefulBuilder(
          builder: (BuildContext context, StateSetter setter) {
            setState = setter;
            return new SizedBox(
              width: childWidth,
              height: childHeight,
              child: new LayoutBuilder(
                builder: (BuildContext context, Size size) {
                  layoutBuilderSize = size;
                  return new SizedBox(
                    key: childKey,
                    width: size.width,
                    height: size.height
                  );
                }
              )
            );
          }
        )
      )
    );

    expect(layoutBuilderSize, equals(const Size(10.0, 20.0)));
    RenderBox box = tester.renderObject(find.byKey(childKey));
    expect(box.size, equals(const Size(10.0, 20.0)));

    setState(() {
      childWidth = 100.0;
      childHeight = 200.0;
    });
    tester.pump();
    box = tester.renderObject(find.byKey(childKey));
    expect(box.size, equals(const Size(100.0, 200.0)));
  });
}
