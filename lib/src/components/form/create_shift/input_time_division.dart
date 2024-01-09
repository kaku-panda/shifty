import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/components/form/modal_window.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/undo_redo.dart';


class InputTimeDivision extends StatefulWidget {
  
  const InputTimeDivision({
    super.key,
  });

  @override
  InputTimeDivisionState createState() => InputTimeDivisionState();
}

class InputTimeDivisionState extends State<InputTimeDivision> {
  Size screenSize = const Size(0, 0);
  bool isDark = false;

  // 時間区分のカスタムのための変数
  List<TimeDivision> timeDivs = [];
  List<TimeDivision> timeDivsTemp = [];
  int durationTemp = 60;

  // シフト時間区部設定のための parameters
  DateTime startTime = DateTime(1, 1, 1, 9, 0);
  DateTime endTime = DateTime(1, 1, 1, 21, 0);
  DateTime duration = DateTime(1, 1, 1, 0, 60);

  UndoRedo<List<TimeDivision>> undoredoCtrl = UndoRedo<List<TimeDivision>>(50);

    @override
  void initState() {
    super.initState();
    insertBuffer(timeDivs);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Text(
              "③ 基本となる時間区分を設定して下さい。",
              style: isDark
                  ? Styles.defaultStyleWhite15
                  : Styles.defaultStyleBlack15,
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.04),

        SizedBox(
          width: screenSize.width * 0.90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildInputBox(
                SizedBox(
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "始業時間",
                      style: Styles.defaultStyleGrey15,
                    ),
                  ),
                ),
                buildTimePicker(
                  startTime,
                  DateTime(1, 1, 1, 0, 0),
                  DateTime(1, 1, 1, 23, 59),
                  5,
                  setStartTime,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text("〜", style: Styles.headlineStyleGreen15),
              ),
              buildInputBox(
                SizedBox(
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "終業時間",
                      style: Styles.defaultStyleGrey15,
                    ),
                  ),
                ),
                buildTimePicker(
                  endTime,
                  startTime.add(const Duration(hours: 1)),
                  DateTime(1, 1, 1, 23, 59),
                  5,
                  setEndTime,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text("...", style: Styles.headlineStyleGreen15),
              ),
              buildInputBox(
                SizedBox(
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "管理間隔",
                      style: Styles.defaultStyleGrey15,
                    ),
                  ),
                ),
                buildTimePicker(
                  duration,
                  DateTime(1, 1, 1, 0, 10),
                  DateTime(1, 1, 1, 6, 0),
                  5,
                  setDuration,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        SizedBox(
          width: screenSize.width * 0.9,
          height: 40,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              shadowColor: Styles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Styles.primaryColor),
            ),
            onPressed: () {
              setState(() {
                createMimimumDivision(startTime, endTime, duration);
                // insertBuffer(shiftFrame.timeDivs);
              });
            },
            child: Text("入力", style: Styles.headlineStyleGreen15),
          ),
        ),
        // Divider(height: screenSize.height * 0.04, thickness: 1),
        SizedBox(height: screenSize.height * 0.02),

        ////////////////////////////////////////////////////////////////////////////
        /// 登録した時間区分一覧
        ////////////////////////////////////////////////////////////////////////////
        Text(
          "時間区分一覧（タップで結合）",
          style: Styles.defaultStyleGrey15,
          textAlign: TextAlign.left,
        ),
        SizedBox(height: screenSize.height * 0.04),
        (timeDivs.isEmpty)
            ? Text(
                "登録されている時間区分がありません。",
                style: Styles.defaultStyleGrey15,
              )
            : buildScheduleEditor(),
      ],
    );
  }

  Widget buildTimePicker(DateTime init, DateTime min, DateTime max,
      int interval, Function(DateTime) callback) {
    DateTime temp = init;

    return SizedBox(
      height: 50,
      width: screenSize.width / 4,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: Styles.hiddenColor,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          side: const BorderSide(color: Styles.hiddenColor),
        ),
        onPressed: () async {
          await showModalWindow(
            context,
            0.4,
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.maxFinite,
              child: Theme(
                data: isDark ? ThemeData.dark() : ThemeData.light(),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: init,
                  minuteInterval: interval,
                  minimumDate: min,
                  maximumDate: max,
                  onDateTimeChanged: (val) {
                    setState(
                      () {
                        temp = val;
                        callback(val);
                      },
                    );
                  },
                  use24hFormat: true,
                ),
              ),
            ),
          );
        },
        child: Text(
          '${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}',
          style: Styles.headlineStyleGreen15,
        ),
      ),
    );
  }

  void createMimimumDivision(DateTime start, DateTime end, DateTime duration) {
    setState(
      () {
        timeDivs.clear();
        while (start.compareTo(end) < 0) {
          var temp = start
              .add(Duration(hours: duration.hour, minutes: duration.minute));
          if (temp.compareTo(end) > 0) {
            temp = end;
          }
          timeDivs.add(
            TimeDivision(
              name: "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}-${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}",
              startTime: DateTime(1, 1, 1, start.hour, start.minute),
              endTime: DateTime(1, 1, 1, temp.hour, temp.minute),
            )
          );
          start = temp;
        }
        timeDivsTemp = List.of(timeDivs);
        durationTemp = duration.hour * 60 + duration.minute;
      },
    );
  }

  void setDuration(DateTime val) {
    setState(
      () {
        duration = val;
      },
    );
  }

  void setStartTime(DateTime val) {
    setState(
      () {
        startTime = val;
      },
    );
  }

  void setEndTime(DateTime val) {
    setState(
      () {
        endTime = val;
      },
    );
  }

  Widget buildInputBox(Widget? title, Widget child) {
    return Column(
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: title,
          ),
        child
      ],
    );
  }

    ///////////////////////////////////////////////////////////////////////////////////
  /// Build Schedule Editor
  ///////////////////////////////////////////////////////////////////////////////////

  buildScheduleEditor() {
    double height = 40;
    double boader = 3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: Column(
            children: [
              for (final timeDiv in timeDivsTemp)
                SizedBox(
                  height: height + boader,
                  child: Text(
                    "${timeDiv.startTime.hour.toString().padLeft(2, '0')}:${timeDiv.startTime.minute.toString().padLeft(2, '0')}-",
                    style: Styles.defaultStyleGrey15,
                    textHeightBehavior: Styles.defaultBehavior,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              SizedBox(
                height: height + boader,
                child: Text(
                  "${timeDivsTemp.last.endTime.hour.toString().padLeft(2, '0')}:${timeDivsTemp.last.endTime.minute.toString().padLeft(2, '0')}-",
                  style: Styles.defaultStyleGrey15,
                  textHeightBehavior: Styles.defaultBehavior,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(5)),
              for (int i = 0; i < timeDivs.length; i++)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(boader / 2),
                      child: InkWell(
                        onTap: () {
                          setState(
                            () {
                              if (i + 1 != timeDivs.length) {
                                timeDivs[i].endTime = timeDivs[i + 1].endTime;
                                timeDivs[i].name =
                                    "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')}-${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}";
                                timeDivs.removeAt(i + 1);
                              }
                            },
                          );
                          insertBuffer(timeDivs);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Styles.hiddenColor),
                              borderRadius: BorderRadius.circular(5.0)),
                          height: (height *
                                  (((timeDivs[i].endTime.hour * 60 +
                                                  timeDivs[i].endTime.minute) -
                                              (timeDivs[i].startTime.hour * 60 +
                                                  timeDivs[i]
                                                      .startTime
                                                      .minute)) /
                                          durationTemp)
                                      .ceil()) +
                              (boader *
                                  ((((timeDivs[i].endTime.hour * 60 +
                                                      timeDivs[i]
                                                          .endTime
                                                          .minute) -
                                                  (timeDivs[i].startTime.hour *
                                                          60 +
                                                      timeDivs[i]
                                                          .startTime
                                                          .minute)) /
                                              durationTemp)
                                          .ceil() -
                                      1)),
                          child: Center(
                            child: Text(
                              "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')} - ${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}",
                              style: Styles.headlineStyleGreen15,
                              textHeightBehavior: Styles.defaultBehavior,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  redo undo 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////

  void insertBuffer(List<TimeDivision> timeDivs) {
    setState(() {
      undoredoCtrl
          .insertBuffer(timeDivs.map((e) => TimeDivision.copy(e)).toList());
    });
  }

  void timeDivsUndoRedo(bool undo) {
    setState(() {
      if (undo) {
        timeDivs =
            undoredoCtrl.undo().map((e) => TimeDivision.copy(e)).toList();
      } else {
        timeDivs =
            undoredoCtrl.redo().map((e) => TimeDivision.copy(e)).toList();
      }
    });
  }
}
