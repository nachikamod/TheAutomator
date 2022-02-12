// ignore_for_file: file_names

import 'package:automator/services/firestore_service.dart';
import 'package:automator/values/colors.dart';
import 'package:automator/values/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as PortMapping;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                bool _progress = false;
                String _name = "";

                GlobalKey<FormState> _portName = GlobalKey<FormState>();
                showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                        builder: (context, setState) => Dialog(
                              backgroundColor: Color(CustomColors().Card_dark),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Wrap(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Custom Name',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Form(
                                          key: _portName,
                                          child: StreamBuilder(
                                            stream: FirestoreService()
                                                .getPort(data.key),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<
                                                        DocumentSnapshot<
                                                            Object?>>
                                                    snapshot) {
                                              if (snapshot.hasError) {
                                                return const Text(
                                                  'Error',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                );
                                              }
                                              if (snapshot.hasData) {
                                                return TextFormField(
                                                  validator: (value) {
                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    _name = value!;
                                                  },
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0.0),
                                                    ),
                                                    hintText: "Name",
                                                    helperStyle: TextStyle(
                                                        color: Colors.white24),
                                                    hintStyle: TextStyle(
                                                        color: Colors.white24),
                                                  ),
                                                  initialValue: snapshot
                                                      .data!['def_name'],
                                                );
                                              }

                                              return const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Visibility(
                                          visible: !_progress,
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              child: const Text('Set'),
                                              onPressed: () async {
                                                setState(() {
                                                  _progress = true;
                                                });
                                                if (_portName.currentState!
                                                    .validate()) {
                                                  _portName.currentState!
                                                      .save();

                                                  FirestoreService()
                                                      .updatePortMap(data.key, {
                                                    'def_name': _name
                                                  }).then((value) {
                                                    setState(() {
                                                      _progress = false;
                                                    });

                                                    Navigator.pop(context);
                                                  }).catchError((err) {
                                                    setState(() {
                                                      _progress = false;
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Failed to create a timer',
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity: ToastGravity
                                                            .SNACKBAR,
                                                        backgroundColor: Color(
                                                            CustomColors()
                                                                .Card_dark),
                                                        textColor:
                                                            Colors.white);
                                                  });
                                                } else {
                                                  setState(() {
                                                    _progress = false;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: _progress,
                                          child: const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )));
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ))
        ],
        title: StreamBuilder(
          stream: FirestoreService().getPort(data.key),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
            if (snapshot.hasError) {
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            }

            if (snapshot.hasData) {
              return Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                      (snapshot.data!['def_name'] == "")
                          ? 'GPIO ${snapshot.data!['index']}'
                          : snapshot.data!['def_name'],
                      style: const TextStyle(fontSize: 15))
                ],
              );
            }

            return const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirestoreService().getCronJobs(data.key),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error',
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

                    DateTime date =
                        DateFormat("HH:mm").parse("${qs['hour']}:${qs['min']}");

                    String date_12 = DateFormat("hh:mma").format(date);

                    return InkWell(
                      onTap: () {
                        List<bool> isSelected = date_12.substring(5, 7) == 'AM'
                            ? [true, false]
                            : [false, true];
                        List<bool> weekSelected = [];

                        for (bool day in qs['days']) {
                          weekSelected.add(day);
                        }

                        int hours = int.parse(date_12.substring(0, 2));
                        int minutes = int.parse(date_12.substring(3, 5));

                        bool _state = qs['status'];
                        bool _progress = false;

                        GlobalKey<FormState> _timer = GlobalKey<FormState>();

                        showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                                builder: (context, setState) => Dialog(
                                      insetPadding: const EdgeInsets.all(10),
                                      backgroundColor:
                                          Color(CustomColors().Card_dark),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Wrap(
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Select Time',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'State',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        FlutterSwitch(
                                                          value: _state,
                                                          onToggle: (state) {
                                                            setState(() {
                                                              _state = state;
                                                            });
                                                          },
                                                          width: 60,
                                                          height: 30,
                                                          inactiveColor:
                                                              const Color(
                                                                  0xff444746),
                                                          activeColor:
                                                              const Color(
                                                                  0xffd3e3fd),
                                                          toggleColor:
                                                              const Color(
                                                                  0xff001d35),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Form(
                                                    key: _timer,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                              'HH',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            SizedBox(
                                                              width: 70,
                                                              child:
                                                                  TextFormField(
                                                                onSaved:
                                                                    (value) {
                                                                  hours =
                                                                      int.parse(
                                                                          value!);
                                                                },
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                          "" ||
                                                                      value!
                                                                          .isEmpty) {
                                                                    return "Hours cant be empty";
                                                                  }

                                                                  if (int.parse(
                                                                          value) >
                                                                      12) {
                                                                    return "Hours cant be greater than 12";
                                                                  }

                                                                  if (value ==
                                                                      "0") {
                                                                    return "Hours cant be 0";
                                                                  }
                                                                  return null;
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLength: 2,
                                                                maxLines: 1,
                                                                initialValue: hours
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        30),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            0.0),
                                                                  ),
                                                                  hintText:
                                                                      "Hour",
                                                                  helperStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.white24),
                                                                  hintStyle: TextStyle(
                                                                      color: Colors
                                                                          .white24),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                              'MM',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            SizedBox(
                                                              width: 70,
                                                              child:
                                                                  TextFormField(
                                                                onSaved:
                                                                    (value) {
                                                                  minutes =
                                                                      int.parse(
                                                                          value!);
                                                                },
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                          "" ||
                                                                      value!
                                                                          .isEmpty) {
                                                                    return "Minutes cant be empty";
                                                                  }

                                                                  if (int.parse(
                                                                          value) >
                                                                      60) {
                                                                    return "Minutes cant be greater than 60";
                                                                  }

                                                                  return null;
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLength: 2,
                                                                maxLines: 1,
                                                                initialValue:
                                                                    minutes
                                                                        .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        30),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            0.0),
                                                                  ),
                                                                  hintText:
                                                                      "Hour",
                                                                  helperStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Colors.white24),
                                                                  hintStyle: TextStyle(
                                                                      color: Colors
                                                                          .white24),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        ToggleButtons(
                                                            direction:
                                                                Axis.vertical,
                                                            children: const [
                                                              Text(
                                                                'AM',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              Text(
                                                                'PM',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              )
                                                            ],
                                                            onPressed: (i) {
                                                              setState(() {
                                                                isSelected[0] =
                                                                    !isSelected[
                                                                        0];
                                                                isSelected[1] =
                                                                    !isSelected[
                                                                        1];
                                                              });
                                                            },
                                                            isSelected:
                                                                isSelected),
                                                      ],
                                                    )),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                ToggleButtons(
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 40,
                                                            minHeight: 40,
                                                            maxWidth: 40,
                                                            maxHeight: 40),
                                                    children: const [
                                                      Text(
                                                        'Su',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Mo',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Tu',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'We',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Th',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Fr',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Sa',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )
                                                    ],
                                                    onPressed: (i) {
                                                      setState(() {
                                                        weekSelected[i] =
                                                            !weekSelected[i];
                                                      });
                                                    },
                                                    isSelected: weekSelected),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Visibility(
                                                  visible: !_progress,
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      child: const Text('Set'),
                                                      onPressed: () async {
                                                        setState(() {
                                                          _progress = true;
                                                        });
                                                        if (_timer.currentState!
                                                            .validate()) {
                                                          _timer.currentState!
                                                              .save();

                                                          DateTime date =
                                                              DateFormat(
                                                                      "hh:mma")
                                                                  .parse(
                                                                      "$hours:$minutes${(isSelected[0]) ? 'AM' : 'PM'}");
                                                          String date_24 =
                                                              DateFormat(
                                                                      "HH:mm")
                                                                  .format(date);

                                                          FirestoreService()
                                                              .updateTimer(
                                                                  qs.id, {
                                                            'hour': int.parse(
                                                                "${date_24[0]}${date_24[1]}"),
                                                            'min': int.parse(
                                                                "${date_24[3]}${date_24[4]}"),
                                                            'port_key':
                                                                data.key,
                                                            'index': data.index,
                                                            'days':
                                                                weekSelected,
                                                            'status': _state
                                                          }).then((value) {
                                                            setState(() {
                                                              _progress = false;
                                                            });

                                                            Navigator.pop(
                                                                context);
                                                          }).catchError((err) {
                                                            setState(() {
                                                              _progress = false;
                                                            });
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    'Failed to create a timer',
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .SNACKBAR,
                                                                backgroundColor:
                                                                    Color(CustomColors()
                                                                        .Card_dark),
                                                                textColor:
                                                                    Colors
                                                                        .white);
                                                          });
                                                        } else {
                                                          setState(() {
                                                            _progress = false;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: _progress,
                                                  child: const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )));
                      },
                      child: Dismissible(
                        key: Key(qs.id),
                        onDismissed: (direction) {
                          FirestoreService().deleteCronJob(qs.id);
                        },
                        child: Card(
                          color: Color(CustomColors().Card_dark),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          date_12.substring(0, 5),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 50),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          date_12.substring(5, 7),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    FlutterSwitch(
                                      value: qs['status'],
                                      width: 60,
                                      height: 30,
                                      inactiveColor: const Color(0xff444746),
                                      activeColor: const Color(0xffd3e3fd),
                                      toggleColor: const Color(0xff001d35),
                                      onToggle: (bool value) {},
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: qs['days'].length,
                                      itemBuilder: (context, j) {
                                        List<String> days = [
                                          'Su',
                                          'Mo',
                                          'Tu',
                                          'We',
                                          'Th',
                                          'Fr',
                                          'Sa'
                                        ];

                                        return FloatingActionButton(
                                            heroTag: '${qs.id}_$j',
                                            backgroundColor: (qs['days'][j])
                                                ? Color(
                                                    CustomColors().Assets_dark)
                                                : Colors.transparent,
                                            elevation: 0,
                                            mini: true,
                                            onPressed: () {},
                                            child: Text(days[j]));
                                      }),
                                )
                              ],
                            ),
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
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'create',
        onPressed: () {
          List<bool> isSelected = [true, false];
          List<bool> weekSelected = List.generate(7, (index) => false);

          int hours = 1;
          int minutes = 0;

          bool _state = false;
          bool _progress = false;

          GlobalKey<FormState> _timer = GlobalKey<FormState>();

          showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                  builder: (context, setState) => Dialog(
                        insetPadding: const EdgeInsets.all(10),
                        backgroundColor: Color(CustomColors().Card_dark),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Wrap(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Select Time',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'State',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          FlutterSwitch(
                                            value: _state,
                                            onToggle: (state) {
                                              setState(() {
                                                _state = state;
                                              });
                                            },
                                            width: 60,
                                            height: 30,
                                            inactiveColor:
                                                const Color(0xff444746),
                                            activeColor:
                                                const Color(0xffd3e3fd),
                                            toggleColor:
                                                const Color(0xff001d35),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Form(
                                      key: _timer,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'HH',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                width: 70,
                                                child: TextFormField(
                                                  onSaved: (value) {
                                                    hours = int.parse(value!);
                                                  },
                                                  validator: (value) {
                                                    if (value == "" ||
                                                        value!.isEmpty) {
                                                      return "Hours cant be empty";
                                                    }

                                                    if (int.parse(value) > 12) {
                                                      return "Hours cant be greater than 12";
                                                    }

                                                    if (value == "0") {
                                                      return "Hours cant be 0";
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  maxLength: 2,
                                                  maxLines: 1,
                                                  initialValue:
                                                      hours.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 30),
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0.0),
                                                    ),
                                                    hintText: "Hour",
                                                    helperStyle: TextStyle(
                                                        color: Colors.white24),
                                                    hintStyle: TextStyle(
                                                        color: Colors.white24),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'MM',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                width: 70,
                                                child: TextFormField(
                                                  onSaved: (value) {
                                                    minutes = int.parse(value!);
                                                  },
                                                  validator: (value) {
                                                    if (value == "" ||
                                                        value!.isEmpty) {
                                                      return "Minutes cant be empty";
                                                    }

                                                    if (int.parse(value) > 60) {
                                                      return "Minutes cant be greater than 60";
                                                    }

                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  maxLength: 2,
                                                  maxLines: 1,
                                                  initialValue:
                                                      minutes.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 30),
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0.0),
                                                    ),
                                                    hintText: "Hour",
                                                    helperStyle: TextStyle(
                                                        color: Colors.white24),
                                                    hintStyle: TextStyle(
                                                        color: Colors.white24),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          ToggleButtons(
                                              direction: Axis.vertical,
                                              children: const [
                                                Text(
                                                  'AM',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  'PM',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                              onPressed: (i) {
                                                setState(() {
                                                  isSelected[0] =
                                                      !isSelected[0];
                                                  isSelected[1] =
                                                      !isSelected[1];
                                                });
                                              },
                                              isSelected: isSelected),
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ToggleButtons(
                                      constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                          maxWidth: 40,
                                          maxHeight: 40),
                                      children: const [
                                        Text(
                                          'Su',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Mo',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Tu',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'We',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Th',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Fr',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          'Sa',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                      onPressed: (i) {
                                        setState(() {
                                          weekSelected[i] = !weekSelected[i];
                                        });
                                      },
                                      isSelected: weekSelected),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Visibility(
                                    visible: !_progress,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        child: const Text('Set'),
                                        onPressed: () async {
                                          setState(() {
                                            _progress = true;
                                          });
                                          if (_timer.currentState!.validate()) {
                                            _timer.currentState!.save();

                                            DateTime date = DateFormat("hh:mma")
                                                .parse(
                                                    "$hours:$minutes${(isSelected[0]) ? 'AM' : 'PM'}");
                                            String date_24 = DateFormat("HH:mm")
                                                .format(date);

                                            FirestoreService().createTimer({
                                              'hour': int.parse(
                                                  "${date_24[0]}${date_24[1]}"),
                                              'min': int.parse(
                                                  "${date_24[3]}${date_24[4]}"),
                                              'port_key': data.key,
                                              'index': data.index,
                                              'days': weekSelected,
                                              'status': _state
                                            }).then((value) {
                                              setState(() {
                                                _progress = false;
                                              });

                                              Navigator.pop(context);
                                            }).catchError((err) {
                                              setState(() {
                                                _progress = false;
                                              });
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Failed to create a timer',
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity:
                                                      ToastGravity.SNACKBAR,
                                                  backgroundColor: Color(
                                                      CustomColors().Card_dark),
                                                  textColor: Colors.white);
                                            });
                                          } else {
                                            setState(() {
                                              _progress = false;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _progress,
                                    child: const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )));
        },
        backgroundColor: Color(CustomColors().Assets_dark),
        child: const Icon(Icons.add),
      ),
    );
  }
}
