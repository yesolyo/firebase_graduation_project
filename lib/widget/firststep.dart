import 'dart:io';
import 'dart:ffi';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:convert';


import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:http/http.dart' as http;

import '../model/input_data.dart';



class FirstStep extends StatefulWidget {
  final TextEditingController storenameController;

  FirstStep(this.storenameController);

  @override
  State<FirstStep> createState() => _FirstStepState();
}

class _FirstStepState extends State<FirstStep> {
  late List<String> autoCompleteData;
  bool isLoading = false;
  bool newLoading = false;
  late List<String> items;

  Future fetchAutoCompleteData() async {
    setState(() {
      isLoading = true;
    });

    final String stringData =
    await rootBundle.loadString("lib/model/data.json");

    final List<dynamic> json = jsonDecode(stringData);

    final List<String> jsonStringData = json.cast<String>();

    setState(() {
      isLoading = false;
      autoCompleteData = jsonStringData;
    });
  }

  Future getApiTest () async {
    setState(() {
      newLoading = true;
    });

    final String stringData =
    await rootBundle.loadString("lib/model/store_list.json");

    final List<dynamic> itemJson = jsonDecode(stringData)['item'];

    final List<String> item = itemJson.cast<String>();
    setState(() {
        newLoading = false;
        print(item);
        items = item;
    });
  }




  @override
  void initState() {//set the initial value of text field
    items=['-','-','-','-','-'];
    super.initState();
    fetchAutoCompleteData();
    getApiTest();

  }

  @override
  Widget build(BuildContext context) {
    final inputData = Provider.of<InputData>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Autocomplete(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            } else {
              return autoCompleteData.where((word) => word
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            }
          },
          optionsViewBuilder:
              (context, Function(String) onSelected, options) {
            return Material(
              elevation: 4,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    //title: Text(option.toString()),
                    title: SubstringHighlight(
                      text: option.toString(),
                      term: widget.storenameController.text,
                      textStyleHighlight:
                      TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      onSelected(option.toString());
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: options.length,
              ),
            );
          },
          onSelected: (selectedString) {
            print(selectedString);
          },
          fieldViewBuilder: (context, controller, focusNode,
              onEdittingComplete) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEdittingComplete,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                  BorderSide(color: Colors.grey[300]!),
                ),
                hintText: "Search Something",
                prefixIcon: Icon(Icons.search),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty){
                  return '식당이름을 입력해주세요';
                }
                return null;
              },
              onSaved: (val){
                inputData.store_name = val!;
              },
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text('식당추천리스트',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(
            '1순위:' + items[0],
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.normal),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(
            '2순위:' + items[1],
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.normal),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(
            '3순위:' + items[2],
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.normal),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ]
    );
  }
}
