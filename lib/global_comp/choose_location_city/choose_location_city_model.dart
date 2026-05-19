import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/components/current_location_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/city_item/city_item_widget.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/no_set_loc/no_set_loc_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'choose_location_city_widget.dart' show ChooseLocationCityWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChooseLocationCityModel
    extends FlutterFlowModel<ChooseLocationCityWidget> {
  ///  Local state fields for this page.

  PlaceStruct? choosenPlace;
  void updateChoosenPlaceStruct(Function(PlaceStruct) updateFn) {
    updateFn(choosenPlace ??= PlaceStruct());
  }

  List<PlaceStruct> searchResult = [];
  void addToSearchResult(PlaceStruct item) => searchResult.add(item);
  void removeFromSearchResult(PlaceStruct item) => searchResult.remove(item);
  void removeAtIndexFromSearchResult(int index) => searchResult.removeAt(index);
  void insertAtIndexInSearchResult(int index, PlaceStruct item) =>
      searchResult.insert(index, item);
  void updateSearchResultAtIndex(int index, Function(PlaceStruct) updateFn) =>
      searchResult[index] = updateFn(searchResult[index]);

  ///  State fields for stateful widgets in this page.

  // Model for navBack component.
  late NavBackModel navBackModel;
  // Model for currentLocation component.
  late CurrentLocationModel currentLocationModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for CityItem component.
  late CityItemModel cityItemModel1;

  @override
  void initState(BuildContext context) {
    navBackModel = createModel(context, () => NavBackModel());
    currentLocationModel = createModel(context, () => CurrentLocationModel());
    cityItemModel1 = createModel(context, () => CityItemModel());
  }

  @override
  void dispose() {
    navBackModel.dispose();
    currentLocationModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    cityItemModel1.dispose();
  }
}
