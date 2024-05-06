import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forhh/HotelsPage.dart';
import 'package:forhh/ProfilePage.dart';
import 'package:forhh/ShortlyPage.dart';
import 'package:forhh/SubscribersPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget{

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>{

  int page = 0;
  List<Widget> activities = [AviaBilets(), Hotels(), Shortly(), Subscribers(), Profile()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0C0C0C),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade900))
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: BottomNavigationBar(
            selectedItemColor: const Color(0xFF2261BC),
            unselectedItemColor: const Color(0xFF9F9F9F),
            showUnselectedLabels: true,
            backgroundColor: const Color(0xFF0C0C0C),
            onTap: (int) {
              setState(() {
                page = int;
              });
            },
            currentIndex: page,
            elevation: 0,
            items: [

              BottomNavigationBarItem(backgroundColor: const Color(0xFF0C0C0C),
                  icon: Image.asset("assets/images/aviabil.png",scale: 2.5,),
                  activeIcon: Image.asset("assets/images/aviabilSEL.png",scale: 2.5,),
                  label: "Авиабилеты"),

              BottomNavigationBarItem(backgroundColor: const Color(0xFF0C0C0C),
                  icon: Image.asset("assets/images/hotels.png",scale: 2.5,),
                  activeIcon: Image.asset("assets/images/hotelsSEL.png",scale: 2.5,),
                  label: "Отели"),

              BottomNavigationBarItem(backgroundColor: const Color(0xFF0C0C0C),
                  icon: Image.asset("assets/images/shortly.png",scale: 2.5,),
                  activeIcon: Image.asset("assets/images/shortlySEL.png",scale: 2.5,),
                  label: "Короче"),

              BottomNavigationBarItem(backgroundColor: const Color(0xFF0C0C0C),
                  icon: Image.asset("assets/images/subscribers.png",scale: 2.5,),
                  activeIcon: Image.asset("assets/images/subscribersSEL.png",scale: 2.5,),
                  label: "Подписки"),

              BottomNavigationBarItem(backgroundColor: const Color(0xFF0C0C0C),
                  icon: Image.asset("assets/images/profile.png",scale: 2.5,),
                  activeIcon: Image.asset("assets/images/profileSEL.png",scale: 2.5,),
                  label: "Профиль"),

            ],
          ),
        ),
        body: activities[page],
      ),
    );
  }

}

class AviaBilets extends StatefulWidget{

  @override
  State<AviaBilets> createState() => _AviaBiletsState();
}

class _AviaBiletsState extends State<AviaBilets>{

  String lastcity = "";
  bool countrypicked = false;

  List _karti = [];
  List<String> name = [];
  List<String> city = [];
  List<String> price = [];

  TextStyle polevvodahint = const TextStyle(color: Color(0xFF9F9F9F));
  TextStyle polevvodatext = const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500);
  TextStyle citytext = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal);

  TextEditingController fromwhere = TextEditingController();
  TextEditingController towhere = TextEditingController();

  Future getlastcity() async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    setState(() {
      lastcity = prefs.getString("lastcity") ?? "";
      fromwhere.text = lastcity;
    });
  }

  Future getjsondata() async {
    final response = await http
        .get(Uri.parse('https://run.mocky.io/v3/00727197-24ae-48a0-bcb3-63eb35d7a9de'));
    final data = await json.decode(response.body);
    setState(() {
      _karti = data["offers"];
    });
    for (int i = 0; i < _karti.length; i ++) {
      setState(() {
        name.add(data["offers"][i]["title"]);
        city.add(data["offers"][i]["town"]);
        price.add("от ${_karti[i]["price"]["value"]} ₽" );
      });
    }
  }

  String getRandom(int length){
    const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random r = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
  }

  @override
  void initState() {
    super.initState();
    getlastcity();
    getjsondata();
  }

  @override
  Widget build(BuildContext context) {
    return countrypicked == true ? searchpicked() : MaterialApp(
      home:  Scaffold(
        drawer: Container(
          height: 150,
          width: double.infinity,
          color: Colors.red,
        ),
        backgroundColor: const Color(0xFF0C0C0C),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            clipBehavior: Clip.none,
            children: [

              const SizedBox(height: 34,),

              FittedBox(
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 78),
                  child: const Text("Поиск дешевых\nавиабилетов", textAlign: TextAlign.center,maxLines: 2, style: TextStyle(fontSize: 22, color: Color(0xFFD9D9D9)),),
                ),
              ),

              const SizedBox(height: 34,),

              searchplate(),

              const SizedBox(height: 34,),

              const Padding(
                padding: EdgeInsets.only(right: 30),
                child: AutoSizeText("Музыкально отлететь", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500),maxLines: 1,),
              ),

              const SizedBox(height: 12,),

              artistcard(),

            ],
          ),
        )
      ),
    );
  }

  Widget searchplate() {
    return FittedBox(
      child: Container(
        height: 122,
        width: 328,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF2F3035),
            borderRadius: BorderRadius.circular(16)
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xFF3E3F43),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [const BoxShadow(blurRadius: 4, color: Color(0x40000000), offset: Offset(0, 4))]
          ),
          child: Row(
            children: [

              const SizedBox(width: 12,),

              Container(
                height: 24,
                width: 24,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/images/search.png")),
                ),
              ),

              const SizedBox(width: 16,),

              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const SizedBox(height: 10,),

                      searchplatetext(),

                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 16,bottom: 3),
                        height: 1,
                        decoration: BoxDecoration(
                            color: const Color(0xFF5E5F61),
                            borderRadius: BorderRadius.circular(2)
                        ),
                      ),

                      Container(
                        alignment: Alignment.bottomLeft,
                        height: 40,

                        child: TextField(
                          readOnly: true,
                          onTap: () {
                            //show modal
                            showModalBottomSheet(
                              scrollControlDisabledMaxHeightRatio: 1,
                              backgroundColor: const Color(0xFF242529),
                              context: context,
                              builder: (context) {
                                return modalwindow();
                              },
                            );
                          },
                          style: polevvodatext,
                          controller: towhere,
                          decoration: InputDecoration(hintText: "Куда - Турция",
                            border: InputBorder.none,
                            hintStyle: polevvodahint,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget searchplatetext() {
    return Container(
      padding: const EdgeInsets.only(top: 13),
      alignment: Alignment.bottomLeft,
      height: 35,
      child: TextField(
        controller: fromwhere,
        onChanged: (value) async {
          SharedPreferences prefs =
          await SharedPreferences.getInstance();
          prefs.setString("lastcity", fromwhere.value.text);
        },
        onTapOutside: (point) {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        style: polevvodatext,
        decoration: InputDecoration(hintText: "Откуда - Москва",
          border: InputBorder.none,
          hintStyle: polevvodahint,
        ),
      ),
    );
  }

  Widget modalwindow() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [

        Container(
          margin: const EdgeInsets.only(top: 16),
          height: 5,
          width: 38,
          decoration: BoxDecoration(
              color: const Color(0xFF5E5F61),
              borderRadius: BorderRadius.circular(10)
          ),
        ),

        modalsearch(),

        modalfunctions(),

        modalrecomendations(),

        const FittedBox(
          child: SizedBox(height: 220,width: 50,),
        )

      ],
    );
  }

  Widget modalsearch() {
    return Stack(
      alignment: Alignment.center,
      children: [

        FittedBox(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            height: 106,
            width: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF2F3035),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                const SizedBox(width: 12,),

                Padding(padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage("assets/images/aviabil.png")),
                        ),
                      ),

                      Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage("assets/images/searchWHITE.png")),
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(width: 10,),

                modalsearchtext(),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(),
                    Padding(padding: const EdgeInsets.only(top: 16, right: 7),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            towhere.clear();
                          });

                        },
                        iconSize: 24,
                        icon: const Icon(Icons.close, color: Color(0xFFDBDBDB),),
                      ),)
                  ],
                )

              ],
            ),
          ),
        ),

        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 32,left: 30,bottom: 3),
          height: 1,
          decoration: BoxDecoration(
              color: const Color(0xFF5E5F61),
              borderRadius: BorderRadius.circular(2)
          ),
        ),

      ],
    );
  }

  Widget modalfunctions() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Expanded(
            child: FittedBox(
              child: Container(
                alignment: Alignment.center,
                height: 98,
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                          image: const DecorationImage(image: AssetImage("assets/images/hardroute.png")),
                          borderRadius: BorderRadius.circular(8)
                      ),
                    ),

                    const SizedBox(height: 8,),

                    AutoSizeText("Сложный маршрут",minFontSize: 7, maxLines: 2,textAlign: TextAlign.center, style: citytext,),

                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16,),

          Expanded(
            child: FittedBox(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    towhere.text = await getRandom(5);
                    Navigator.pop(context);

                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.setString("towheree", towhere.value.text);
                    prefs.setString("fromwheree", fromwhere.value.text);

                    setState(() {
                      countrypicked = true;
                    });

                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 98,
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              image: const DecorationImage(image: AssetImage("assets/images/anyway.png")),
                              borderRadius: BorderRadius.circular(8)
                          ),
                        ),

                        const SizedBox(height: 8,),

                        AutoSizeText("Куда угодно",minFontSize: 7, maxLines: 1,textAlign: TextAlign.center, style: citytext,),

                      ],
                    ),
                  ),
                )
            ),
          ),

          const SizedBox(width: 16,),

          Expanded(
              child: FittedBox(
                child: Container(
                  alignment: Alignment.center,
                  height: 98,
                  width: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            image: const DecorationImage(image: AssetImage("assets/images/weekend.png")),
                            borderRadius: BorderRadius.circular(8)
                        ),
                      ),

                      const SizedBox(height: 8,),

                      AutoSizeText("Выходные",minFontSize: 7, maxLines: 1,textAlign: TextAlign.center, style: citytext,),

                    ],
                  ),
                ),
              )
          ),

          const SizedBox(width: 16,),

          Expanded(
              child: FittedBox(
                child: Container(
                  alignment: Alignment.center,
                  height: 98,
                  width: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            image: const DecorationImage(image: AssetImage("assets/images/hotbil.png")),
                            borderRadius: BorderRadius.circular(8)
                        ),
                      ),

                      const SizedBox(height: 8,),

                      AutoSizeText("Горячие билеты",minFontSize: 7, maxLines: 2,textAlign: TextAlign.center, style: citytext,),

                    ],
                  ),
                ),
              )
          ),

        ],
      ),
    );
  }

  Widget modalrecomendations() {
    return FittedBox(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 30,horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        height: 286,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: const Color(0xFF2F3035),
            borderRadius: BorderRadius.circular(16)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            FittedBox(
              child: Container(
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: ListTile(
                  onTap: () async {
                    towhere.text = "Стамбул";
                    Navigator.pop(context);

                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.setString("towheree", towhere.value.text);
                    prefs.setString("fromwheree", fromwhere.value.text);

                    setState(() {
                      countrypicked = true;
                    });

                  },
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 2),
                  ),
                  leading: Image.asset("assets/images/stambul.png"),
                  title: AutoSizeText("Стамбул",maxLines: 1,style: polevvodatext,) ,
                  subtitle: const AutoSizeText("Популярное направление",maxLines: 1, style: TextStyle(color: Color(0xFF5E5F61),fontSize: 14),),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
              color: const Color(0xFF3E3F43),
              width: double.infinity,
              height: 1,
            ),

            FittedBox(
              child: Container(

                height: 56,
                width: MediaQuery.of(context).size.width,
                child: ListTile(
                  onTap: () async {
                    towhere.text = "Сочи";
                    Navigator.pop(context);

                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.setString("towheree", towhere.value.text);
                    prefs.setString("fromwheree", fromwhere.value.text);

                    setState(() {
                      countrypicked = true;
                    });

                  },
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 2),
                  ),
                  leading: Image.asset("assets/images/Sochi.png"),
                  title: AutoSizeText("Сочи",maxLines: 1,style: polevvodatext,) ,
                  subtitle: const AutoSizeText("Популярное направление",maxLines: 1, style: TextStyle(color: Color(0xFF5E5F61),fontSize: 14),),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
              color: const Color(0xFF3E3F43),
              width: double.infinity,
              height: 1,
            ),

            FittedBox(
              child: Container(
                height: 56,
                width: MediaQuery.of(context).size.width,
                child: ListTile(
                  onTap: () async {
                    towhere.text = "Пхукет";
                    Navigator.pop(context);

                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.setString("towheree", towhere.value.text);
                    prefs.setString("fromwheree", fromwhere.value.text);

                    setState(() {
                      countrypicked = true;
                    });

                  },
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 2),
                  ),
                  leading: Image.asset("assets/images/Phuket.png"),
                  title: AutoSizeText("Пхукет",maxLines: 1,style: polevvodatext,) ,
                  subtitle: const AutoSizeText("Популярное направление",maxLines: 1, style: TextStyle(color: Color(0xFF5E5F61),fontSize: 14),),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 10, left: 16, right: 16),
              color: const Color(0xFF3E3F43),
              width: double.infinity,
              height: 1,
            ),

          ],
        ),
      ),
    );
  }

  Widget modalsearchtext() {
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 10,),

            Container(
              alignment: Alignment.bottomLeft,
              height: 35,
              child: TextField(
                controller: fromwhere,
                onChanged: (value) async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  prefs.setString("lastcity", fromwhere.value.text);
                },
                onTapOutside: (point) {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                style: polevvodatext,
                decoration: InputDecoration(hintText: "Откуда - Москва",
                  border: InputBorder.none,
                  hintStyle: polevvodahint,
                ),
              ),
            ),

            const SizedBox(height: 3,),

            Container(
              alignment: Alignment.bottomLeft,
              height: 40,

              child: TextField(
                style: polevvodatext,
                controller: towhere,
                onEditingComplete: () async {
                  Navigator.pop(context);

                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  prefs.setString("towheree", towhere.value.text);
                  prefs.setString("fromwheree", fromwhere.value.text);

                  setState(() {
                    countrypicked = true;
                  });
                },
                decoration: InputDecoration(hintText: "Куда - Турция",
                  border: InputBorder.none,
                  hintStyle: polevvodahint,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget artistcard() {
    return FittedBox(
      child: Container(
        height: 213,
        width: 300,
        child: ListView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          children: List.generate(name.length, (index) => Container(
            margin: index == name.length - 1 ? EdgeInsets.zero : const EdgeInsets.only(right: 67),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage("assets/images/${index + 1}.png"),fit: BoxFit.fill),
                      borderRadius: BorderRadius.circular(16)
                  ),
                ),

                Text(name[index], style: polevvodatext,maxLines: 1,),

                const SizedBox(height: 2,),

                Text(city[index], style: citytext,maxLines: 1,),

                const SizedBox(height: 6,),

                Row(
                  children: [

                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      height: 24,
                      width: 24,
                      decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/plane.png")),
                      ),
                    ),

                    Text(price[index],style: citytext,maxLines: 1,)

                  ],
                ),

              ],
            ),
          )),
        ),
      ),
    );
  }

}

class searchpicked extends StatefulWidget{

  @override
  State<searchpicked> createState() => _searchpickedState();
}

class _searchpickedState extends State<searchpicked>{

  List<String> months = ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"];
  List<String> days = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"];

  late String daymonth;
  late String weekday;
  String daymonthweekday = "обратно";
  DateTime? selectedDate = DateTime.now();
  DateTime? selectedDateObr = DateTime.now();

  bool countrypicked = true;

  TextStyle polevvodahint = const TextStyle(color: Color(0xFF9F9F9F));
  TextStyle polevvodatext = const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500);
  TextStyle citytext = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal);

  BoxDecoration filtersDecoration = BoxDecoration(
      color: const Color(0xFF2F3035),
      borderRadius: BorderRadius.circular(50)
  );

  TextEditingController fromwhere = TextEditingController();
  TextEditingController towhere = TextEditingController();

  Future getTime(DateTime? date, String data) async{
    setState(() {
      if(data == "selectedDate") {
        daymonth = "${date!.day} ${months[date.month - 1]}";
        weekday = ", ${days[date.weekday - 1]}";
      }else {
        daymonthweekday = "${date!.day} ${months[date!.month - 1]}, ${days[date!.weekday - 1]}";
      }
    });
  }

  Future getTexts() async{
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    setState(() {
      towhere.text =  prefs.getString("towheree")!;
      fromwhere.text = prefs.getString("fromwheree")!;
    });

  }

  Future _selectDate(BuildContext context, DateTime? date, String data) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (selected != null) {
      setState(() {
        date = selected;
        getTime(date, data);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTime(selectedDate, "selectedDate");
    getTexts();
  }

  @override
  Widget build(BuildContext context) {
    return countrypicked == false ? AviaBilets() : MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0C0C0C),
        body: ListView(
          children: [

            const SizedBox(height: 40,),

            searchplate(),

            filters(),

          ],
        ),
      ),
    );
  }

  Widget searchplate() {
    return Stack(
      alignment: Alignment.center,
      children: [

        FittedBox(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            height: 106,
            width: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF2F3035),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                const SizedBox(width: 3,),

                IconButton(
                  onPressed: () {
                    setState(() {
                      countrypicked = false;
                    });
                  },
                  iconSize: 30,
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                ),

                const SizedBox(width: 10,),

                Expanded(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const SizedBox(height: 10,),

                        Container(
                          alignment: Alignment.bottomLeft,
                          height: 35,
                          child: TextField(
                            controller: fromwhere,
                            onChanged: (value) async {
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              prefs.setString("lastcity", fromwhere.value.text);
                            },
                            onTapOutside: (point) {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            },
                            style: polevvodatext,
                            decoration: InputDecoration(hintText: "Откуда - Москва",
                              border: InputBorder.none,
                              hintStyle: polevvodahint,
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.bottomLeft,
                          height: 40,

                          child: TextField(
                            style: polevvodatext,
                            controller: towhere,
                            onEditingComplete: () {

                            },
                            decoration: InputDecoration(hintText: "Куда - Турция",
                              border: InputBorder.none,
                              hintStyle: polevvodahint,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 0, right: 7),
                      child: IconButton(
                        onPressed: () {
                          String where = fromwhere.value.text;
                          String to = towhere.value.text;
                          setState(() {
                            fromwhere.text = to;
                            towhere.text = where;
                          });

                        },
                        iconSize: 24,
                        icon: const Icon(Icons.swap_vert, color: Color(0xFFDBDBDB),),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(top: 0, right: 7),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            towhere.clear();
                          });

                        },
                        iconSize: 24,
                        icon: const Icon(Icons.close, color: Color(0xFFDBDBDB),),
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
        ),

        FittedBox(
          fit: BoxFit.cover,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 5,bottom: 3, left: 40),
            height: 1,
            width:290,
            decoration: BoxDecoration(
                color: const Color(0xFF5E5F61),
                borderRadius: BorderRadius.circular(2)
            ),
          ),
        )

      ],
    );
  }

  Widget filters() {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 33,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          children: [

            FittedBox(
                child: GestureDetector(
                  onTap: () {
                    _selectDate(context, selectedDateObr, "selectedDateObr");
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 18),
                    decoration: filtersDecoration,
                    width: 89,
                    height: 33,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [

                        daymonthweekday == "обратно" ? const Expanded(child: Icon(Icons.add,size: 20, color: Colors.white,),) : const SizedBox(),

                        Expanded(
                            flex: 2,
                            child: AutoSizeText(daymonthweekday,maxLines: 1, style: const TextStyle( color: Colors.white), textAlign: TextAlign.center,)),

                      ],
                    ),
                  ),
                )
            ),

            FittedBox(
                child: GestureDetector(
                  onTap: () {
                    _selectDate(context, selectedDate, "selectedDate");
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: 18),
                    decoration: filtersDecoration,
                    width: 89,
                    height: 33,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        AutoSizeText(daymonth,maxLines: 1, style: const TextStyle( color: Colors.white),textAlign: TextAlign.center,),

                        AutoSizeText(weekday,maxLines: 1, style: const TextStyle( color: Colors.grey),textAlign: TextAlign.center,),

                      ],
                    ),
                  ),
                )
            ),

            FittedBox(
              child: Container(
                margin: const EdgeInsets.only(right: 18),
                decoration: filtersDecoration,
                width: 104,
                height: 33,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: const Row(
                  children: [

                    Expanded(child: Icon(Icons.person,size: 16, color: Colors.grey,),),

                    Expanded(
                        flex: 2,
                        child: AutoSizeText("1,эконом",maxLines: 1, style: TextStyle( color: Colors.white),)),

                  ],
                ),
              ),
            ),

            FittedBox(
              child: Container(
                decoration: filtersDecoration,
                width: 107,
                height: 33,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: const Row(
                  children: [

                    Expanded(child: Icon(CupertinoIcons.slider_horizontal_3,size: 16, color: Colors.grey,),),

                    Expanded(
                        flex: 2,
                        child: AutoSizeText("фильтры",maxLines: 1, style: TextStyle( color: Colors.white),)),

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }



}