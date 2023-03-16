import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quantum_it/main.dart';
import 'package:quantum_it/user_modal.dart';

import 'api_service.dart';
import 'authentication.dart';
import 'custom_color.dart';
import 'database_helper.dart';
import 'note.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;

  late List<UserModel>? _userModel = [];
  late List<UserModel>? items = [];
  int connected = 0;
  late List<Note>? _notes = [];
  bool _isSigningOut = false;
  TextEditingController editingController = TextEditingController();

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyApp(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _getData() async {
    try {
      _userModel = (await ApiService().getUsers())!;
      items?.addAll(_userModel!);
    } catch (e) {}
    _notes = await getlist();
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connected = 1;
      }
    } on SocketException catch (_) {}
    Future.delayed(const Duration(seconds: 2)).then((value) => setState(() {}));
  }

  static Future<List<Note>> getlist() async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    await databaseHelper.initializeDatabase();
    return await databaseHelper.getNoteList();
  }

  @override
  void initState() {
    _user = widget._user;
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: CustomColors.firebaseNavy,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _user.email.toString(),
                style: TextStyle(fontSize: 18),
              ),
              _isSigningOut
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.redAccent,
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isSigningOut = true;
                        });
                        await Authentication.signOut(context: context);
                        setState(() {
                          _isSigningOut = false;
                        });
                        Navigator.of(context)
                            .pushReplacement(_routeToSignInScreen());
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
            ],
          )),
      body: _userModel == null || _userModel!.isEmpty
          ?  connected==0 && (_notes==null || _notes!.isEmpty) ? const Center(
              child: CircularProgressIndicator(),
            ) : showStatic(_notes)
          : showList(items!),
    );
  }

  showList(List<UserModel> um) {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.deleteAll();

    for (UserModel u in um) {
      helper.insertNote(new Note(
          u.source.name, u.title, u.description, u.urlToImage, u.publishedAt));
    }

    return SafeArea(
      child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                cursorColor: CustomColors.firebaseOrange,
                onChanged: (value) {
                  filterSearchResults(value);
                },
                style: TextStyle(color: CustomColors.firebaseOrange),
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(
                    left: 6.0,
                    right: 6.0,
                    bottom: 20.0,
                  ),
                  child: ListView.builder(
                      itemCount: um.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: Container(
                                  height: 150,
                                  padding: EdgeInsets.all(7),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        // mainAxisAlignment:
                                        // MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            um[index]
                                                .publishedAt
                                                .substring(0, 10),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            um[index].source.name,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: CustomColors
                                                    .firebaseOrange),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        um[index].title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: CustomColors.firebaseNavy),
                                      ),
                                      Text(
                                        um[index].description ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Expanded(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    image: DecorationImage(
                                        image: um[index].urlToImage == null
                                            ? AssetImage(
                                                    'assets.firebase_logo.png')
                                                as ImageProvider
                                            : NetworkImage(
                                                um[index].urlToImage),
                                        fit: BoxFit.fitHeight),
                                  ),
                                ),
                                flex: 3,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                            ],
                          ),
                        );
                      })),
            ),
          ],
        ),
      ),
    );
  }

  void filterSearchResults(String q) {
    String query = q.toLowerCase();
    List<UserModel> dummySearchList = <UserModel>[];
    dummySearchList.addAll(_userModel!);
    if (query.isNotEmpty) {
      List<UserModel> dummyListData = <UserModel>[];
      dummySearchList.forEach((item) {
        if (item.source.name.toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items?.clear();
        items?.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items?.clear();
        items?.addAll(_userModel!);
      });
    }
  }

  showStatic(List<Note>? notes) {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.only(
            left: 6.0,
            right: 6.0,
            bottom: 20.0,
          ),
          child: ListView.builder(
              itemCount: notes?.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Container(
                          height: 150,
                          padding: EdgeInsets.all(7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                // mainAxisAlignment:
                                // MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    notes?[index].publishedAt.substring(0, 10),
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    notes?[index].source,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: CustomColors.firebaseOrange),
                                  ),
                                ],
                              ),
                              Text(
                                notes?[index].title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: CustomColors.firebaseNavy),
                              ),
                              Text(
                                notes?[index].description ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                                image: AssetImage('assets/firebase_logo.png'),
                                fit: BoxFit.fitHeight),
                          ),
                        ),
                        flex: 3,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                    ],
                  ),
                );
              })),
    );
  }
}
/*
title
des
publishedat
sorce
image

 */
