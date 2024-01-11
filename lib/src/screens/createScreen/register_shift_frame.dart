///////////////////////////////////////////////////////////////////////////////////////////
/// import
///////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/components/shift_editor/editor_appbar.dart';
import 'package:shift/src/components/shift_editor/table.dart';
import 'package:shift/src/components/shift_editor/table_title.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/form/dialog.dart';
import 'package:shift/src/components/undo_redo.dart';
import 'package:shift/src/components/form/modal_window.dart';
import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/shift_editor/coordinate.dart';
import 'package:shift/src/components/form/button.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

double cellHeight  = 20;
double cellWidth   = 20;
double titleMargin = 10;
double cellSizeMax = 30;
double cellSizeMin = 10;
double zoomDiv     = 1;
int    bufferMax   = 50;

bool enableEdit     = false;
bool enableZoomIn   = true;
bool enableZoomOut  = true;
int  inputValue     = 1;
Size screenSize     = const Size(0, 0);
bool isDark         = false;

List<bool> displayInfoFlag = [true, true, true, true];

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表の最終チェックに使用するページ (勤務人数も指定)
////////////////////////////////////////////////////////////////////////////////////////////

class CheckShiftTableWidget extends ConsumerStatefulWidget {
  
  const CheckShiftTableWidget({Key? key}) : super(key: key);
  
  @override
  CheckShiftTableWidgetState createState() => CheckShiftTableWidgetState();
}

class CheckShiftTableWidgetState extends ConsumerState<CheckShiftTableWidget> {

  UndoRedo<List<List<int>>> undoredoCtrl = UndoRedo(bufferMax);

  Coordinate? selectedCoordinate;
  
  ShiftFrame shiftFrame = ShiftFrame();
  GlobalKey  editorKey  = GlobalKey<TableEditorState>();

  @override
  Widget build(BuildContext context) {

    shiftFrame = ref.read(shiftFrameProvider).shiftFrame;

    screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom);
    
    ref.read(settingProvider).loadPreferences();
    isDark = ref.read(settingProvider).enableDarkTheme;

    if(undoredoCtrl.buffer.isEmpty){
      insertBuffer(shiftFrame.assignTable);
    }

    int columnLength = shiftFrame.dateTerm[0].end.difference(shiftFrame.dateTerm[0].start).inDays + 1;
    int rowLength    = shiftFrame.timeDivs.length;

    return EditorAppBar(
      context: context,
      ref: ref, 
      registered: true,
      title: "割り当て人数の設定",
      handleInfo: (){
        showInfoDialog(ref.read(settingProvider).enableDarkTheme);
      },
      handleRegister: (){
        if(ref.read(signInProvider).user != null){
          showConfirmDialog(context, ref, "確認", "このシフト表で作成しますか？", "シフト表を作成しました", (){
            shiftFrame.pushShiftFrame();
            crearVariables();
            Navigator.pop(context);
            Navigator.pop(context);
          });
        }
        else{
          showAlertDialog(context, ref, "ログインエラー", "未ログイン状態では\n登録できません。\n'ホーム画面'及び'アカウント画面'から\n'ログイン画面'に移動してください。", true);
        }
      },
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// ツールボタン
            /// height : screenSize.height * 0.075
            ////////////////////////////////////////////////////////////////////////////////////////////
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  //　拡大縮小ボタン
                  ToolButton(icon: Icons.zoom_in,  pressEnable: enableZoomIn,  width: screenSize.width/7, onPressed: handleZoomIn),
                  ToolButton(icon: Icons.zoom_out, pressEnable: enableZoomOut, width: screenSize.width/7, onPressed: handleZoomOut),
                  // 範囲入力ボタン
                  ToolButton(icon: Icons.filter_alt_outlined, pressEnable: true, width: screenSize.width/7, onPressed: handleRangeFill),
                  // タッチ入力ボタン
                  ToolButton(icon: Icons.touch_app_outlined, pressEnable: true, offEnable: !enableEdit, width: screenSize.width/7, onPressed: handleTouchEdit, onLongPressed: handleChangeInputValue),
                  // Redo Undo ボタン
                  ToolButton(icon: Icons.undo, pressEnable: undoredoCtrl.enableUndo(), width: screenSize.width/7, onPressed: handleUndo),
                  ToolButton(icon: Icons.redo, pressEnable: undoredoCtrl.enableRedo(), width: screenSize.width/7, onPressed: handleRedo)
                  ],
                ),
              ),
            ),
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// メインテーブル
            /// height : screenSize.height * 0.075
            ////////////////////////////////////////////////////////////////////////////////////////////
            TableEditor(
              editorKey:   editorKey,
              tableHeight: screenSize.height * 1.0 - 60,
              tableWidth:  screenSize.width,
              cellHeight:  cellHeight,
              cellWidth:   cellWidth,
              titleHeight: cellHeight*2,
              titleWidth:  cellWidth*3.5,
              titleMargin: titleMargin,
              onChangeSelect: (p0) async {
                setState(() {
                  selectedCoordinate = p0!;
                  if(enableEdit){
                    shiftFrame.assignTable[selectedCoordinate!.row][selectedCoordinate!.column] = inputValue;
                  }
                });
              },
              onInputEnd: (){
                insertBuffer(shiftFrame.assignTable);
              },
              columnTitles: getColumnTitles(cellHeight*2, cellWidth, shiftFrame.dateTerm[0].start, shiftFrame.dateTerm[0].end, isDark),
              rowTitles: getRowTitles(cellHeight, cellWidth*3.5, shiftFrame.timeDivs, isDark),
              cells: List<List<Widget>>.generate(
                rowLength, 
                (i){
                  return List.generate(
                    columnLength,
                    (j){
                      return shiftFrameCell( i, j, j == selectedCoordinate?.column && i == selectedCoordinate?.row);
                    }
                  );
                },
              ),
              enableEdit: enableEdit,
              selected: selectedCoordinate,
              isDark: ref.read(settingProvider).enableDarkTheme
            ),
            // space
            const SizedBox(height: 8)
          ],
        ),
      ),
    );
  }

    ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Cell
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  // Matrix Cell Class Instance
  Widget shiftFrameCell(int row, int column, bool selected) {
    var value = shiftFrame.assignTable[row][column];
    double fontSize = cellHeight / 20 * 10;
    String cellValue = value.toString();
    Color  cellFontColor = colorTable[value][0];
    Color  cellColor =  (selected) ? cellFontColor.withAlpha(100) : cellFontColor.withAlpha(50);

    var cellBoaderWdth = 1.0;
    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        border: Border(
          top:    row == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
          bottom: BorderSide(width: cellBoaderWdth, color: Colors.grey),
          left:   column == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
          right:  BorderSide(width: cellBoaderWdth, color: Colors.grey),
        ),
        color: cellColor
      ),
      child: Center(child: Text(cellValue, style: TextStyle(color: cellFontColor, fontSize: fontSize), textHeightBehavior: Styles.defaultBehavior, textAlign: TextAlign.center))
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Zoom In / Zoom Out 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void zoomIn(){
    if(enableZoomIn && cellHeight < cellSizeMax){
      cellHeight += zoomDiv;
      cellWidth  += zoomDiv;
    }
    if(cellHeight >= cellSizeMax){
      enableZoomIn = false;
    }else{
      enableZoomIn = true;
    }
    if(cellHeight <= cellSizeMin){
      enableZoomOut = false;
    }else{
      enableZoomOut = true;
    }
  }

  void zoomOut(){
    if(enableZoomOut && cellHeight > cellSizeMin){
      cellHeight -= zoomDiv;
      cellWidth  -= zoomDiv;
    }
    if(cellHeight >= cellSizeMax){
      enableZoomIn = false;
    }else{
      enableZoomIn = true;
    }
    if(cellHeight <= cellSizeMin){
      enableZoomOut = false;
    }else{
      enableZoomOut = true;
    }
  }

  void handleZoomIn() {
    setState(() {
      zoomIn();
      editorKey = GlobalKey<TableEditorState>();
    });
  }

  void handleZoomOut() {
    setState(() {
      zoomOut();
      editorKey = GlobalKey<TableEditorState>();
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  redo undo 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void insertBuffer(List<List<int>> table){
    setState(() {
      undoredoCtrl.insertBuffer(table.map((e) => List.from(e).cast<int>()).toList());
    });
  }

  void callUndoRedo(bool undo){
    setState(() {
      if(undo){
        shiftFrame.assignTable = undoredoCtrl.undo().map((e) => List.from(e).cast<int>()).toList();
      }else{
        shiftFrame.assignTable = undoredoCtrl.redo().map((e) => List.from(e).cast<int>()).toList();
      }
    });
  }

  void handleUndo(){
    setState(() {
      callUndoRedo(true);
    });
  }

  void handleRedo(){
    setState(() {
      callUndoRedo(false);
    });
  }
    
  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に塗る色を選択する
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void buildChangeInputValueModaleWindow() {
    showModalWindow(
      context,
      0.5,
      buildModalWindowContainer(
        context,
        List<Widget>.generate(assignNumSelect.length, (index) => Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [ 
              Text(assignNumSelect[index], style: Styles.headlineStyle13,textAlign: TextAlign.center),
            ],
          )
        ),
        0.5,
        (BuildContext context, int index){
          setState(() {});
          inputValue = index; 
        }
      )
    );
  }

  void handleTouchEdit(){
    setState(() {
      editorKey = GlobalKey<TableEditorState>();
      enableEdit = !enableEdit;
    });
  }
  
  void handleChangeInputValue(){
    setState(() {
      buildChangeInputValueModaleWindow();
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表範囲一括入力のためのモーダルウィンドウ
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildRangeFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      AutoFillWidget(shiftTable: shiftFrame)
    ).then((value) {
      if(value != null){
        setState(() {});
        insertBuffer(shiftFrame.assignTable);
      }
    });
  }

  void handleRangeFill(){
    setState(() {
      buildRangeFillModalWindow(context);
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  画面遷移時に変数をクリアするための関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  void crearVariables(){
    ref.read(shiftFrameProvider).shiftFrame = ShiftFrame();
    selectedCoordinate  = Coordinate(column: 0, row: 0);
    undoredoCtrl = UndoRedo(bufferMax);
    selectedCoordinate = null;
  }

    ////////////////////////////////////////////////////////////////////////////////////////////
  ///  割当て人数設定画面の使い方を説明するための関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<int?> showInfoDialog(bool isDarkTheme) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              title: Text("「シフト作成画面②」の使い方", style:  Styles.headlineStyleGreen20, textAlign: TextAlign.center),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.95,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text("この画面では、シフト表の割り当て人数を設定します。", style: Styles.headlineStyleGrey13),
                      
                      // About Shift Table Buttons 
                      const SizedBox(height: 20),
                      TextButton(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child : displayInfoFlag[0] ? Text("-", style: Styles.headlineStyleGreen18) : Text("+", style: Styles.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("割り当て人数の設定について", style: Styles.headlineStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          displayInfoFlag[0] = !displayInfoFlag[0];
                          setState(() {});
                        },
                      ),

                      if(displayInfoFlag[0])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // How to Edit
                            Text("この画面では、シフト表の各日時に対する割り当て人数を設定します。", style: Styles.headlineStyleGrey13),
                            Text("シフト表作成後に割り当て人数を変更することはできません。", style: Styles.headlineStyleRed13),
                            const SizedBox(height: 20),
                            Text("編集方法", style: Styles.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("シフト表の各マスの数字は、その日時の割り当て人数を示すものです。", style: Styles.headlineStyleGrey13),
                            Text("画面上部のツールボタンを使用することで、割り当て人数を編集できます。", style: Styles.headlineStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/create_2_1.png"),
                            ),
                            Text("画面を横向きにすることもできます。", style: Styles.headlineStyleGrey13), 
                            Text("見やすい画面で作業しましょう。", style: Styles.headlineStyleGrey13), 
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/create_2_2.png"),
                            ),
                            Text("登録方法", style: Styles.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("編集後は、画面右上の「登録」ボタンを押して登録して下さい。", style: Styles.headlineStyleGrey13),
                            Text("編集内容を「登録」しない場合、画面遷移時に破棄されます。", style: Styles.headlineStyleRed13),
                            Text("作成したシフト表の共有方法については、「ホーム画面」の i ボタンより参照して下さい。", style: Styles.headlineStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/create_2_3.png"),
                            ),
                          ],
                        ),
                      ),

                      // About Tool Buttons 
                      const SizedBox(height: 20),
                      TextButton(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child : displayInfoFlag[1] ? Text("-", style: Styles.headlineStyleGreen18) : Text("+", style: Styles.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("ツールボタンについて", style: Styles.headlineStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          displayInfoFlag[1] = !displayInfoFlag[1];
                          setState(() {});
                        },
                      ),

                      if(displayInfoFlag[1])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("画面上部のツールボタンを用いることで、効率的な編集を行うことができます。", style: Styles.headlineStyleGrey13),
                            const SizedBox(height: 20),
                            // Zoom Out / In Button
                            Text("拡大・縮小ボタン", style: Styles.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("表の拡大・縮小ができます。", style: Styles.headlineStyleGrey13),
                            Text("見やすいサイズで作業しましょう。", style: Styles.headlineStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/create_2_4.png"),
                            ),
                          
                            // Filterring Input Button
                            Text("一括入力ボタン", style: Styles.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("特定の「日時」に「割当て人数」一括入力できます。", style: Styles.headlineStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/create_2_5.png"),
                            ),

                            // Draw Button                             
                            Text("タッチ入力ボタン", style: Styles.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("タップ後に表のマスをなぞることで細かい1マス単位の割り当て人数を編集できます。", style: Styles.headlineStyleGrey13),
                            Text("設定する割当て人数は、ボタンを長押しすることで選択できます。", style: Styles.headlineStyleGrey13),
                            Text("注意 : 使用中、表のスクロールが無効化されます。スクロールが必要な場合は、もう一度「タッチ入力ボタン」をタップし、無効化してください。", style: Styles.headlineStyleRed13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("assets/how_to_use/create_2_6.png"),
                                  Image.asset("assets/how_to_use/create_2_7.png"),
                                ],
                              ),
                            ),
 

                            // Redo / Undo Button
                            const SizedBox(height: 10),
                            Text("戻る・進む ボタン", style: Styles.headlineStyle15),
                            const SizedBox(height: 10),
                            Text("編集した割り当て表を「前の状態」や「次の状態」に戻すことができます。", style: Styles.headlineStyleGrey13),
                            Text("注意 : 遡れる状態は最大50であり、一度シフト表作成画面を閉じると過去の変更履歴は破棄されます。", style: Styles.headlineStyleRed13),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('閉じる', style: Styles.headlineStyleGreen13),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      }
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
///  シフト表の Auto-Fill 機能のためのクラス (モーダルウィンドウとして使用)
////////////////////////////////////////////////////////////////////////////////////////////

class AutoFillWidget extends StatefulWidget {
  
  final ShiftFrame _shiftFrame;
  const AutoFillWidget({Key? key, required ShiftFrame shiftTable}) : _shiftFrame = shiftTable, super(key: key);

  @override
  AutoFillWidgetState createState() => AutoFillWidgetState();
}

class AutoFillWidgetState extends State<AutoFillWidget> {
  
  bool viewHistry = false;
  var selectorsIndex = [0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    var table        = widget._shiftFrame;
    var timeDivs1List = List.generate(table.timeDivs.length + 1, (index) => (index == 0) ? '全て' : table.timeDivs[index-1].name);
    var timeDivs2List = List.generate(table.timeDivs.length + 1, (index) => (index == 0) ? '-' : table.timeDivs[index-1].name);

    ////////////////////////////////////////////////////////////////////////////////////////////
    /// Auto-Fillの引数の入力UI
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    return LayoutBuilder(
      builder: (context, constraints) {
        var modalHeight  = screenSize.height * 0.5;
        var modalWidth   = screenSize.width - 10 - screenSize.width * 0.08;
        var paddingHeght = modalHeight * 0.04;
        var buttonHeight = modalHeight * 0.2;
        var widgetHeight = buttonHeight + paddingHeght * 2;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
          child: SizedBox(
            height: modalHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: SizedBox(
                        child: CustomTextButton(
                          text:   weekSelect[selectorsIndex[0]],
                          enable:   false,
                          width:  modalWidth * (100 / 330),
                          height: buttonHeight,
                          action: (){
                            setState(() {
                              buildSelectorModaleWindow(weekSelect, 0);
                            });
                          }
                        )
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: Styles.headlineStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text:   weekdaySelect[selectorsIndex[1]],
                        enable:   false,
                        width:  modalWidth * (100 / 330),
                        height: buttonHeight,
                        action: (){
                          setState(() {
                            buildSelectorModaleWindow(weekdaySelect, 1);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: Styles.headlineStyleGrey13))),
                    SizedBox(height: widgetHeight, width: modalWidth * (100 / 330))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text:   timeDivs1List[selectorsIndex[2]],
                        enable:   false,
                        width:  modalWidth * (100 / 330),
                        height: buttonHeight,
                        action: (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs1List, 2);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("~", style: Styles.headlineStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                         text:   timeDivs2List[selectorsIndex[3]],
                         enable:   false,
                         width:  modalWidth * (100 / 330),
                         height: buttonHeight,
                         action: (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs2List, 3);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (50 / 330), child: Center(child: Text("の区分は", style: Styles.headlineStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text:   "${selectorsIndex[4]} 人",
                        enable:   false,
                        width:  modalWidth * (65 / 330),
                        height: buttonHeight,
                        action: (){
                          setState(() {
                            buildSelectorModaleWindow(
                              List<Widget>.generate(assignNumSelect.length, (index) => Row(
                                mainAxisAlignment:  MainAxisAlignment.center,
                                children: [
                                  Text(assignNumSelect[index], style: Styles.headlineStyle13,textAlign: TextAlign.center),
                                ],
                              )),
                              4
                            );
                          });
                        }
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text:   "一括入力",
                        enable:   true,
                        width:  modalWidth,
                        height: buttonHeight,
                        action: (){
                          setState(() {
                            var rule = AssignRule(
                              week:      selectorsIndex[0],
                              weekday:   selectorsIndex[1],
                              timeDivs1: selectorsIndex[2],
                              timeDivs2: selectorsIndex[3],
                              assignNum: selectorsIndex[4]
                            );
                            widget._shiftFrame.applyRuleToShiftFrame(rule);
                            Navigator.pop(context, rule); // これだけでModalWindowのFuture<dynamic>から返せる
                            setState(() {});
                          });
                        }
                      ),
                    ),
                  ]
                )
              ],
            ),
          ),
        );
      }
    );

    ////////////////////////////////////////////////////////////////////////////////////////////
    ///  履歴表示　UI
    ////////////////////////////////////////////////////////////////////////////////////////////
    // : Padding(
    //   padding: const EdgeInsets.all(10.0),
    //   child: SingleChildScrollView(
    //     child: SizedBox(
    //       width: 250,
    //       height: MediaQuery.of(context).size.height * 0.40,
    //       child: (widget._shiftTable.assignRules.isEmpty) ? Center(child: Text("登録されている履歴がありません", style: MyFont.defaultStyleGrey15)) : ReorderableListView.builder(
    //         shrinkWrap: true,
    //         buildDefaultDragHandles: false,
    //         itemCount: widget._shiftTable.assignRules.length,
    //         itemBuilder: (context, i) => registerAutoFill(
    //           i, 
    //           weekSelect[widget._shiftTable.assignRules[i].week], 
    //           weekdaySelect[widget._shiftTable.assignRules[i].weekday],
    //           timeDivs1List[widget._shiftTable.assignRules[i].timeDivs1],
    //           timeDivs2List[widget._shiftTable.assignRules[i].timeDivs2],
    //           widget._shiftTable.assignRules[i].assignNum.toString(),
    //           context
    //         ),
    //         onReorder: (int oldIndex, int newIndex) {
    //           setState(() {
    //             if (oldIndex < newIndex) {
    //               newIndex -= 1;
    //             }
    //             final AssignRule item = widget._shiftTable.assignRules.removeAt(oldIndex);
    //             widget._shiftTable.assignRules.insert(newIndex, item);
    //           });
    //         }
    //       ),
    //     ),
    //   ),
    // );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  buildTextButtonを押すとさらに選択モーダルウィンドウを表示するための実装
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildSelectorModaleWindow(List list, int resultIndex) {
    showModalWindow(
      context,
      0.5,
      buildModalWindowContainer(
        context,
        list,
        0.5,
        (BuildContext context, int index){
          selectorsIndex[resultIndex] = index;
          setState(() {});
        }
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Range-Fill条件を登録
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget registerRangeFill(int index, String weekSelect, String weekdaySelect, String timeDivs1Select, String timeDivs2Select,  String assignNumSelect, BuildContext context) {
    return ReorderableDragStartListener(
      key: Key(index.toString()),
      index: index,
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: Styles.hiddenColor
          ),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 170,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(weekSelect,      style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' の ',          style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(weekdaySelect,   style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' の ',          style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(timeDivs1Select, style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' - ',           style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(timeDivs2Select, style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' の勤務人数は ',  style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(assignNumSelect, style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' 人',           style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.delete, size: 20),
              color: Styles.hiddenColor,
            ),
          ],
        ),
      ),
    );
  }
}