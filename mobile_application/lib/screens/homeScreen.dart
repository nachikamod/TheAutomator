// ignore_for_file: file_names

import 'package:automator/services/authentication_service.dart';
import 'package:automator/services/firestore_service.dart';
import 'package:automator/values/colors.dart';
import 'package:automator/values/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
          appBar: AppBar(title: const Text('Controls', style: TextStyle(fontSize: 15),), actions: [
            IconButton(onPressed: () {
              showDialog(context: context, builder: (context) => AlertDialog(
                backgroundColor: Color(CustomColors().Card_dark),
                title: const Text('Logging out', style: TextStyle(color: Colors.white),),
                content: const Text('You are about to logout from the application', style: TextStyle(color: Colors.white),),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthenticationService>().signOut();
                  }, child: const Text('Logout')),
                  TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('Cancel')),
                ],
              ));
            }, icon: const Icon(Icons.logout, color: Colors.white,))
          ],),
          body: StreamBuilder(
        stream: FirestoreService().getPortMappings(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            Fluttertoast.showToast(
                msg: 'Error fetching data',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.SNACKBAR,
                backgroundColor: Color(CustomColors().Card_dark),
                textColor: Colors.white);
            return const Center(
              child: Text(
                'Error loading data',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, i) {
                  QuerySnapshot<Object?>? querySnapshot = snapshot.data;

                  if (querySnapshot != null) {
                    QueryDocumentSnapshot qs = querySnapshot.docs[i];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/timerScreen', arguments: PortMapping(key: qs.id, index: qs['index']));
                      },
                      child: Card(
                        color: Color(CustomColors().Card_dark),
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.new_label_outlined,
                                      color: (qs['status'])
                                          ? Colors.white
                                          : Color(
                                              CustomColors().TextTitle_dark)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'GPIO ${qs['index']}',
                                    style: TextStyle(
                                        color: (qs['status'])
                                            ? Colors.white
                                            : Color(
                                                CustomColors().TextTitle_dark)),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Visibility(
                                  visible: qs['def_name'] != "",
                                  child: Text(qs['def_name'],
                                      style: TextStyle(
                                          color: (qs['status'])
                                              ? Colors.white
                                              : Color(CustomColors()
                                                  .TextTitle_dark),
                                          fontSize: 40))),
                              Visibility(
                                visible: qs['def_name'] != "",
                                child: const SizedBox(
                                  height: 20,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                        color: (qs['status'])
                                            ? Colors.white
                                            : Color(
                                                CustomColors().TextTitle_dark)),
                                  ),
                                  FlutterSwitch(
                                    value: qs['status'],
                                    onToggle: (state) {
                                      FirestoreService().updatePortMap(
                                          qs.id, {'status': state});
                                    },
                                    width: 60,
                                    height: 30,
                                    inactiveColor: const Color(0xff444746),
                                    activeColor: const Color(0xffd3e3fd),
                                    toggleColor: const Color(0xff001d35),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      ));
}
