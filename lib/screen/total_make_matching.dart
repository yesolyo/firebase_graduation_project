import 'dart:convert';

import 'package:firebase_graduation_project/screen/mypage_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../model/input_data.dart';
import '../model/register_user.dart';
import '../widget/firststep.dart';
import '../widget/secondstep.dart';
import '../widget/step_button.dart';
import '../widget/thirdstep.dart';
import '../widget/register_listview.dart';
import 'package:http/http.dart' as http;

class TotalMakeMatching extends StatefulWidget {
  const TotalMakeMatching({Key? key}) : super(key: key);

  @override
  State<TotalMakeMatching> createState() => _TotalMakeMatchingState();
}


class _TotalMakeMatchingState extends State<TotalMakeMatching> {

  int selectedStack = 0;
  GlobalKey<FormState> _fkey = GlobalKey<FormState>();
  bool autovalidate = false;
  TextEditingController storenameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();




  void submit() async{
    setState(()=> autovalidate = true);
    if (!_fkey.currentState!.validate()){
      return;
    }
    _fkey.currentState!.save();

    final inputData = Provider.of<InputData>(context,
      listen: false,);
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                color: Colors.grey[100],
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('식당 이름: ${inputData.store_name}'),
                    Text('날짜: ${inputData.promise_date}'),
                    Text('시간: ${inputData.starttime} ~ ${inputData.endtime}'),
                    Text('인원: ${inputData.maxpers}'),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false),
              child: Text('CANCEL'),
            ),
          ],
        );
      },
    );


    if(result){
      _fkey.currentState!.reset();
      storenameController.text = '';
      dateController.text = '';
      startTimeController.text ='';
      endTimeController.text ='';
      setState(()=>autovalidate = false);
    }

    final register = Register(
      date: inputData.promise_date,
      detail:inputData.detail,
      end:inputData.endtime,
      max:inputData.maxpers,
      min:1,
      start:inputData.starttime,
      storeName:inputData.store_name,
      title:inputData.title,
      user_id: inputData.googleAccount!.email,
    );

    createRegister(register);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () {
              print("click");
            },
            child: PopupMenuButton<String>(
              offset: Offset(0, 30),
              shape: ShapeBorder.lerp(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  1),
              onSelected: (String where) {
                print(where);
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(value: "sookmyung", child: Text("숙명여대")),
                  PopupMenuItem(value: "ewha", child: Text("이화여대")),
                ];
              },
              child: Row(
                children: [Text("숙명여대"), Icon(Icons.arrow_drop_down)],
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyPage()),
                  );
                },
                icon: Icon(Icons.perm_identity_outlined)),
          ],
        ),

        body: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.blue[900],
                  width: double.infinity,
                  height: 80.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      StepButton(
                        selected: selectedStack ==0,
                        step: 'Step1',
                        onPressed: ()=>setState(() =>selectedStack =0),
                      ),
                      StepButton(
                        selected: selectedStack ==1,
                        step: 'Step2',
                        onPressed: ()=>setState(() =>selectedStack =1),
                      ),
                      StepButton(
                        selected: selectedStack ==2,
                        step: 'Step3',
                        onPressed: ()=>setState(() =>selectedStack =2),
                      ),
                    ],
                  ),
                ),
                Form(
                    key: _fkey,
                    autovalidateMode: autovalidate
                        ? AutovalidateMode.onUserInteraction
                        :AutovalidateMode.disabled,

                    child: Expanded(
                      child: IndexedStack(
                        index: selectedStack,
                        children: <Widget>[
                          Padding(padding: const EdgeInsets.symmetric
                            (horizontal: 30.0),
                            child: FirstStep(storenameController),
                          ),
                          Padding(padding: const EdgeInsets.symmetric
                            (horizontal: 30.0),
                            child: SecondStep(dateController,startTimeController, endTimeController ),
                          ),
                          Padding(padding: const EdgeInsets.symmetric
                            (horizontal: 30.0),
                            child: ThirdStep(submit: submit),
                          ),

                        ],
                      ),
                    ))
              ],
            )
        )
    );

  }

  Future createRegister(Register register) async {
    final docRegister = FirebaseFirestore.instance.collection('register').doc();
    register.id = docRegister.id;

    final json = register.toJson();
    await docRegister.set(json);

  }
}


