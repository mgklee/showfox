import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../musical.dart';

class Tab3 extends StatefulWidget {
  const Tab3({Key? key}) : super(key: key);

  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  List<Musical> musicals = [];
  List<String> savedMusicals = [];
  List<String> savedActors = [];
  List<String> addedDate = [];
  List<String> addedTitle = [];
  Map<DateTime, List<String>> musicalEvents = {};
  Map<DateTime, List<String>> actorEvents = {};
  Map<DateTime, List<String>> allEvents = {};
  Map<DateTime, List<String>> musicalAndActorEvents = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> events = {};
  final TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<String>> _selectedEvents;
  late final SharedPreferences prefs;
  bool buttonMusicalPressed = false;
  bool buttonActorPressed = false;

  Future<List<Musical>> loadMusicalData() async {
    final String response = await rootBundle.loadString('assets/musical.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => Musical.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> getMusicalList() async {
    musicals = await loadMusicalData();
  }

  Future<void> getAllEvents() async {
    List<Musical>musicalsForEvent = await loadMusicalData();
    Map<DateTime, List<String>> newEvents = {};
    for(var musical in musicalsForEvent) {
      DateTime firstBookDate = changeStringToDateTime(musical.firstTicketOpen.split(' ')[0]);
      DateTime secondBookDate = changeStringToDateTime(musical.secondTicketOpen.split(' ')[0]);
      String firstBookHour = musical.firstTicketOpen.split(' ')[1];
      String secondBookHour = musical.secondTicketOpen.split(' ')[1];
      String firstTerm = musical.firstTerm;
      String secondTerm = musical.secondTerm;
      String title = musical.title;

      if (!newEvents.containsKey(firstBookDate)) {
        newEvents[firstBookDate] = [];
      }
      newEvents[firstBookDate]!.add("[$title] $firstBookHour 1차 티켓 오픈\n($firstTerm)");

      if (!newEvents.containsKey(secondBookDate)) {
        newEvents[secondBookDate] = [];
      }
      newEvents[secondBookDate]!.add("[$title] $secondBookHour 2차 티켓 오픈\n($secondTerm)");
    }
    for (int i = 0;i<min(addedTitle.length, addedDate.length);i++){
      if (!newEvents.containsKey(DateTime.parse(addedDate[i]))){
        newEvents[DateTime.parse(addedDate[i])] = [];
      }
      newEvents[DateTime.parse(addedDate[i])]!.add(addedTitle[i]);
    }
    setState(() {
      allEvents = newEvents;
    });
  }

  Future<void> getPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  List<String> getFavoriteMusical() {
    final List<String>? previousSavedMusicals = prefs.getStringList('savedMusicals');
    return previousSavedMusicals ?? [];
  }

  void getFavoriteMusicalWait() {
    savedMusicals = getFavoriteMusical();
  }

  // Musical JSON read, add musical schedule to Event list
  Future<void> makeEventFromFavoriteMusical() async {
    List<Musical>musicalsForEvent = await loadMusicalData();
    Map<DateTime, List<String>> newEvents = {};

    for(var musical in musicalsForEvent) {
      if (savedMusicals.contains(musical.title)) {
        DateTime startDate = changeStringToDateTime(musical.firstDate);
        DateTime endDate = changeStringToDateTime(musical.lastDate);
        String title = musical.title;

        if (!newEvents.containsKey(startDate)) {
          newEvents[startDate] = [];
        }
        newEvents[startDate]!.add("[$title] 시작일");

        if (!newEvents.containsKey(endDate)) {
          newEvents[endDate] = [];
        }
        newEvents[endDate]!.add("[$title] 마감일");
      }
    }
    for (int i = 0;i<min(addedTitle.length, addedDate.length);i++){
      if (!newEvents.containsKey(DateTime.parse(addedDate[i]))){
        newEvents[DateTime.parse(addedDate[i])] = [];
      }
      newEvents[DateTime.parse(addedDate[i])]!.add(addedTitle[i]);
    }
    setState(() {
      musicalEvents = newEvents;
    });
  }

  List<String> getFavoriteActorsMusical() {
    final List<String>? previousSavedMusicals = prefs.getStringList('savedActors');
    return previousSavedMusicals ?? [];
  }

  void getFavoriteActorsMusicalWait() {
    savedActors = getFavoriteActorsMusical();
  }

  // Musical JSON read, add musical schedule to Event list
  Future<void> makeEventFromSavedActor() async {
    List<Musical>musicalsForEvent = await loadMusicalData();
    Map<DateTime, List<String>> newEvents = {};

    for(var musical in musicalsForEvent) {
      bool actorAppearsInMusical = false;
      for(var actor in savedActors) {
        if (musical.actors.contains(actor)) {
          actorAppearsInMusical = true;
        }
      }
      if (actorAppearsInMusical){
        DateTime startDate = changeStringToDateTime(musical.firstDate);
        DateTime endDate = changeStringToDateTime(musical.lastDate);
        String title = musical.title;

        if (!newEvents.containsKey(startDate)) {
          newEvents[startDate] = [];
        }
        newEvents[startDate]!.add("[$title] 시작일");

        if (!newEvents.containsKey(endDate)) {
          newEvents[endDate] = [];
        }
        newEvents[endDate]!.add("[$title] 마감일");
      }
    }
    for (int i = 0;i<min(addedTitle.length, addedDate.length);i++){
      if (!newEvents.containsKey(DateTime.parse(addedDate[i]))){
        newEvents[DateTime.parse(addedDate[i])] = [];
      }
      newEvents[DateTime.parse(addedDate[i])]!.add(addedTitle[i]);
    }
    setState(() {
      actorEvents = newEvents;
    });
  }

  Future<void> getEventFromFavorite() async {
    getAllEvents();
    getFavoriteMusicalWait();
    getFavoriteActorsMusicalWait();
    makeEventFromFavoriteMusical();
    makeEventFromSavedActor();
  }

  Future<void> makeEventFromBothMusicalAndActor() async {
    Map<DateTime, List<String>> newEvents = {};
    for(var musical in musicals){
      bool actorAppearsInMusical = false;
      for (var actor in savedActors){
        if (musical.actors.contains(actor)) {actorAppearsInMusical = true;}
      }
      if (actorAppearsInMusical || savedMusicals.contains(musical.title)){
        DateTime startDate = changeStringToDateTime(musical.firstDate);
        DateTime endDate = changeStringToDateTime(musical.lastDate);
        String title = musical.title;

        if (!newEvents.containsKey(startDate)) {
          newEvents[startDate] = [];
        }
        newEvents[startDate]!.add("[$title] 시작일");

        if (!newEvents.containsKey(endDate)) {
          newEvents[endDate] = [];
        }
        newEvents[endDate]!.add("[$title] 마감일");
      }
    }
    for (int i = 0;i<min(addedTitle.length, addedDate.length);i++){
      if (!newEvents.containsKey(DateTime.parse(addedDate[i]))){
        newEvents[DateTime.parse(addedDate[i])] = [];
      }
      newEvents[DateTime.parse(addedDate[i])]!.add(addedTitle[i]);
    }
    setState(() {
      musicalAndActorEvents = newEvents;
    });
  }

  List<String> getUserAddedTitle() {
    final List<String>? previousTitles = prefs.getStringList('userAddedTitle');
    return previousTitles ?? [];
  }

  void getUserAddedTitleWait() {
    addedTitle = getUserAddedTitle();
  }

  List<String> getUserAddedDate() {
    final List<String>? previousDates = prefs.getStringList('userAddedDate');
    return previousDates ?? [];
  }

  void getUserAddedDateWait() {
    addedDate = getUserAddedDate();
  }

  Future<void> getUserAddedEvent() async {
    getUserAddedTitleWait();
    getUserAddedDateWait();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    getMusicalList();
    getPref().then((_){
      getUserAddedEvent().then((_){
        getEventFromFavorite().then((_){
          makeEventFromBothMusicalAndActor();
          events = allEvents;
        });
      });
    });
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  DateTime addZ(DateTime dateNotUTC){
    String dateStringWithZ = dateNotUTC.toIso8601String() + "Z";
    DateTime dateWithZ = DateTime.parse(dateStringWithZ);
    return dateWithZ;
  }

  DateTime changeStringToDateTime(String date){
    DateFormat format = DateFormat("yyyy.MM.dd");
    DateTime day = format.parse(date);
    return addZ(day);
  }

  List<String> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  void _addEvent(String title) {
    if (_selectedDay != null && title.isNotEmpty) {
      setState(() {
        if (!allEvents.containsKey(_selectedDay)) {
          allEvents[_selectedDay!] = [];
        }
        allEvents[_selectedDay!]!.add(title);

        if (!actorEvents.containsKey(_selectedDay)) {
          actorEvents[_selectedDay!] = [];
        }
        actorEvents[_selectedDay!]!.add(title);

        if (!musicalEvents.containsKey(_selectedDay)) {
          musicalEvents[_selectedDay!] = [];
        }
        musicalEvents[_selectedDay!]!.add(title);

        if (!musicalAndActorEvents.containsKey(_selectedDay)) {
          musicalAndActorEvents[_selectedDay!] = [];
        }
        musicalAndActorEvents[_selectedDay!]!.add(title);
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
      addedDate.add(_selectedDay!.toIso8601String());
      prefs.setStringList('userAddedDate', addedDate);
      addedTitle.add(title);
      prefs.setStringList('userAddedTitle', addedTitle);
    }
  }

  void getButtonState(){
    if (buttonMusicalPressed){
      if(buttonActorPressed){
        setState(() {
          events = musicalAndActorEvents;
          _selectedEvents.value =
              _getEventsForDay(_selectedDay ?? _focusedDay);
        });
      }
      else{
        setState(() {
          events = musicalEvents;
          _selectedEvents.value =
              _getEventsForDay(_selectedDay ?? _focusedDay);
        });
      }
    }
    else {
      if(buttonActorPressed){
        setState(() {
          events = actorEvents;
          _selectedEvents.value =
              _getEventsForDay(_selectedDay ?? _focusedDay);
        });
      }
      else{
        setState(() {
          events = allEvents;
          _selectedEvents.value =
              _getEventsForDay(_selectedDay ?? _focusedDay);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: const Text("일정 추가"),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _eventController,
                      decoration: const InputDecoration(
                        labelText: '추가할 일정',
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        _addEvent(_eventController.text);
                        _eventController.clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text("추가"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.51,
                // child: Flexible(
                //   flex: 5,
                  child: TableCalendar(
                    locale: 'ko_KR',
                    shouldFillViewport: true,
                    firstDay: DateTime.utc(2021, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    eventLoader: _getEventsForDay,
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    rowHeight: (MediaQuery.of(context).size.height * 0.13) - 50,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(min(events.length, 2), (index) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1.0),
                                child: Text(
                                  '🦊',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                              );
                            }),
                          );
                        }
                        return null;
                      },
                      defaultBuilder: (context, day, focusedDay) {
                        if (day.weekday == DateTime.saturday) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          );
                        } else if (day.weekday == DateTime.sunday) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                // ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 찜한 뮤지컬
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  buttonMusicalPressed = !buttonMusicalPressed;
                                  getButtonState();
                                });
                              },
                              child: Icon(
                                buttonMusicalPressed ? Icons.bookmark : Icons.bookmark_border,
                                color: buttonMusicalPressed ? Colors.red : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  buttonMusicalPressed = !buttonMusicalPressed;
                                  getButtonState();
                                });
                              },
                              child: const Text("찜한 뮤지컬만 보기"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 찜한 배우
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  buttonActorPressed = !buttonActorPressed;
                                  getButtonState();
                                });
                              },
                              child: Icon(
                                buttonActorPressed ? Icons.favorite : Icons.favorite_border,
                                color: buttonActorPressed ? Colors.red : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  buttonActorPressed = !buttonActorPressed;
                                  getButtonState();
                                });
                              },
                              child: const Text("찜한 배우만 보기"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Expanded(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            key: UniqueKey(),
                            background: Container(color: Colors.red,),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction){
                              var valueToRemove = value[index];
                              final dateIndex = addedDate.indexOf(_selectedDay!.toIso8601String());
                              final titleIndex = addedTitle.indexOf(valueToRemove);
                              if (dateIndex != -1 && titleIndex != -1 && addedDate.contains(_selectedDay!.toIso8601String()) && addedTitle.contains(value[index])) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${value[index]} 삭제됨')),
                                );

                                final musicalAndActorEventList = musicalAndActorEvents[_selectedDay!];
                                if (musicalAndActorEventList != null) {
                                  musicalAndActorEventList.remove(valueToRemove);
                                  if (musicalAndActorEventList.isEmpty) {
                                    musicalAndActorEvents.remove(_selectedDay!);
                                  } else {
                                    musicalAndActorEvents[_selectedDay!] = musicalAndActorEventList;
                                  }
                                }

                                final actorEventList = actorEvents[_selectedDay!];
                                if (actorEventList != null) {
                                  actorEventList.remove(valueToRemove);
                                  if (actorEventList.isEmpty) {
                                    actorEvents.remove(_selectedDay!);
                                  } else {
                                    actorEvents[_selectedDay!] = actorEventList;
                                  }
                                }

                                final musicalEventList = musicalEvents[_selectedDay!];
                                if (musicalEventList != null) {
                                  musicalEventList.remove(valueToRemove);
                                  if (musicalEventList.isEmpty) {
                                    musicalEvents.remove(_selectedDay!);
                                  } else {
                                    musicalEvents[_selectedDay!] = musicalEventList;
                                  }
                                }

                                final allEventList = allEvents[_selectedDay!];
                                if (allEventList != null) {
                                  allEventList.remove(valueToRemove);
                                  if (allEventList.isEmpty) {
                                    allEvents.remove(_selectedDay!);
                                  } else {
                                    allEvents[_selectedDay!] = allEventList;
                                  }
                                }

                                addedDate.removeAt(addedDate.indexOf(_selectedDay!.toIso8601String()));
                                addedTitle.removeAt(addedTitle.indexOf(valueToRemove));

                                prefs.setStringList('userAddedDate', addedDate);
                                prefs.setStringList('userAddedTitle', addedTitle);

                                setState(() {
                                  _selectedEvents.value = _getEventsForDay(_selectedDay!);
                                });
                              } else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('존재하는 뮤지컬 일정은 삭제할 수 없습니다.')),
                                );

                                setState(() {
                                  _selectedEvents.value = _getEventsForDay(_selectedDay!);
                                });
                              }
                            },
                            child: ListTile(
                              title: Text(value[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}