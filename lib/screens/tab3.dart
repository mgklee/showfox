import 'dart:convert';
import 'dart:developer';
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
  Map<DateTime, List<String>> musicalEvents = {};
  List<String> savedActors = [];
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
    allEvents = newEvents;
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

    setState(() {
      musicalAndActorEvents = newEvents;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    getMusicalList();
    getPref().then((_){
      getEventFromFavorite().then((_){
        makeEventFromBothMusicalAndActor();
        events = allEvents;
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
        if (!events.containsKey(_selectedDay)) {
          events[_selectedDay!] = [];
        }
        events[_selectedDay!]!.add(title);
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: TableCalendar(
                locale: 'ko_KR',
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
                rowHeight: (MediaQuery.of(context).size.height * 0.14) - 50,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(events.length, (index) {
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
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.bottomLeft,
              child: CheckboxListTile(
                title: const Text("원하는 뮤지컬만 골라 보기"),
                value: buttonMusicalPressed,
                activeColor: Colors.orangeAccent,
                onChanged: (bool? value) {
                  buttonMusicalPressed = value ?? false;
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
                },
                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                selected: buttonMusicalPressed,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: CheckboxListTile(
                title: const Text("원하는 배우만 골라 보기"),
                value: buttonActorPressed,
                activeColor: Colors.orangeAccent,
                onChanged: (bool? value) {
                  buttonActorPressed = value ?? false;
                  if (buttonActorPressed){
                    if(buttonMusicalPressed){
                      setState(() {
                        events = musicalAndActorEvents;
                        _selectedEvents.value =
                            _getEventsForDay(_selectedDay ?? _focusedDay);
                      });
                    }
                    else{
                      setState(() {
                        events = actorEvents;
                        _selectedEvents.value =
                            _getEventsForDay(_selectedDay ?? _focusedDay);
                      });
                    }
                  }
                  else {
                    if(buttonMusicalPressed){
                      setState(() {
                        events = musicalEvents;
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
                },
                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                selected: buttonActorPressed,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(value[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}