import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Gotham',
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> series = ["F1", "F2", "F3"];
  var chosenValue;
  var nextRaceResponse;
  var newsResponse;
  var timer;
  var nextDate;
  var raceImg;
  String raceCountry = "";

  @override
  void initState() {
    nextRaceResponse = getNextRace().whenComplete(() {
      raceImg = getRaceThumb();
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (nextRaceResponse != null) {
          try {
            timeUntilRace();
          } catch (e) {}
        }
      });
    });
    newsResponse = getNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFFF5F5F5),
      systemNavigationBarColor: Color(0xFFF5F5F5),
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark
    ));

    return FutureBuilder<Map<String, dynamic>>(
      future: nextRaceResponse,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Color(0xFFF5F5F5),
            child: Center(
                child: CircularProgressIndicator()
            ),
          );
        }

        return SafeArea(
            child: Scaffold(
              backgroundColor: Color(0xFFF5F5F5),
              body: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 28),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 16, right: 20),
                          child: IconButton(
                              disabledColor: Colors.blueAccent,
                              icon: Icon(
                                Icons.menu,
                              ),
                              onPressed: () {
                               print(snapshot.data!['raceData']);
                              }),
                        ),
                        Text(
                          'DASHBOARD',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 32),
                          child: CircleAvatar(
                            radius: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 32, top: 32, right: 32),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "RACE WEEKEND",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                                child: Container(
                                  height: 30,
                                  padding: EdgeInsets.only(left: 12, right: 12),
                                  decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(50))
                                      ),
                                      color: Colors.white
                                  ),
                                  child: DropdownButton<String>(
                                    value: chosenValue,
                                    icon: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.keyboard_control,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                    elevation: 4,
                                    items: series.map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    hint: Text(
                                      series[0],
                                    ),
                                    onChanged: (var value) {
                                      setState(() {
                                        chosenValue = value;
                                      });
                                    },
                                  ),
                                )
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'REMAINING TIME',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$timer',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data!['raceThumbnail'].toString(),
                            imageBuilder: (context, imageProvider) => Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.4), BlendMode.exclusion)
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    flex: 9,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              snapshot.data!['raceData']['meetingCountryName'].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              snapshot.data!['raceData']['meetingOfficialName'].toUpperCase(),
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: Colors.grey[100],
                                                fontSize: 13,
                                                fontFamily: 'GothamBook',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                      size: 20,
                                  ),
                                  )
                                ],
                              )
                            ),
                            placeholder: (context, url) => Container(
                              width: MediaQuery.of(context).size.width,
                              height: 92,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(
                                child: Container(
                                  width: 50,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: LinearProgressIndicator()
                                  ),
                                ),
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 8),
                          child: Text(
                            'SPOTLIGHT',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900
                            ),
                          ),
                        ),
                        Container(
                          height: 300,
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: newsResponse,
                            builder: (context, dataSnapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  color: Color(0xFFF5F5F5),
                                  child: Center(
                                      child: CircularProgressIndicator()
                                  ),
                                );
                              }

                              var len = dataSnapshot.data?.length ?? 0; //default length is 0 if null.

                              return PageView.builder(
                                itemCount: len,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(left: 32, right: 32, top: 8),
                                      child: Column(
                                        children: <Widget>[
                                          CachedNetworkImage(
                                              imageUrl: dataSnapshot.data![index]['imageLink'].toString(),
                                              imageBuilder: (context, imageProvider) => Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  height: 200,
                                                  padding: EdgeInsets.all(24),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                    ),
                                                  ),
                                              ),
                                              placeholder: (context, url) => Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context).size.width,
                                                height: 200,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(12)
                                                ),
                                              )
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(top: 12, left: 4, right: 4),
                                            width: MediaQuery.of(context).size.width,
                                            child: Text(
                                              dataSnapshot.data![index]['title'].toString(),
                                              style: TextStyle(
                                                fontFamily: 'Titillium',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.1,
                                                height: 1.3
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                              );

                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
        );
      }
    );
  }

  void getNextRaceOpt() async {

    var url = Uri.parse("http://ergast.com/api/f1/current.json");
    var imgUrl = "https://www.formula1.com/content/dam/fom-website/races/2021/race-listing/Brazil.jpg.transform/9col/image.jpg";
    var response = await http.get(url);

    var jsonRes = jsonDecode(response.body);
    var races = jsonRes["MRData"]["RaceTable"]["Races"];

    var today = DateTime.now();
    var nextRace;

    print(races[9]);

    for (var i in races) {
      print(i['Circuit']['Location']['country']);
    }
  }

  Future<List<Map<String, dynamic>>> getNews() async {

    var unescape = new HtmlUnescape();

    List<Map<String, dynamic>> newsDataList = [];
    Map<String, dynamic> dataMap;
    var title;
    var tag;
    var imgLink;


    var url = Uri.parse("https://www.formula1.com/en/latest/all.html");
    var response = await http.get(url, headers: {'content-type': 'text/html; charset=utf-8'});

    var document = parse(utf8.decode(response.bodyBytes));

    var href = document.getElementsByClassName("f1-cc");

    for (var i in href) {
      title = i.getElementsByClassName("no-margin")[0].text.toString(); //article title
      tag = i.getElementsByClassName("misc--tag")[0].text.trim(); //article tag
      imgLink = i.querySelectorAll('source')[0].attributes['data-srcset']!.split(",")[1].split(" ")[1]; //article img

      dataMap = {'title': title, 'tag': tag, 'imageLink': imgLink};

      newsDataList.add(dataMap);
    }

    return newsDataList;
  }

  Future<String> getRaceThumb() async {

    var nextRaceImg;
    var url = Uri.parse("https://www.formula1.com/en/racing/2021.html");
    var response = await http.get(url);
    var document = parse(utf8.decode(response.bodyBytes));
    var src = document.getElementsByClassName("hero-image");

    // for (var i in src) { //get list of races thumbnail
    //   imgList.add(i.querySelectorAll('source')[0].attributes['data-srcset']!.split(",")[1].split(" ")[1]);
    // }

    for (var i in src) {
      if ((i.querySelectorAll('source')[0].attributes['data-srcset']!.split(",")[1].split(" ")[1]).contains(raceCountry.replaceAll(" ", "_"))) {
        nextRaceImg = (i.querySelectorAll('source')[0].attributes['data-srcset']!.split(",")[1].split(" ")[1]);
        print(nextRaceImg);
      }
    }

    return nextRaceImg;
  }

  Future<Map<String, dynamic>> getNextRace() async {
    var nextRace;
    var nextRaceFull;
    var url = Uri.parse("https://api.formula1.com/v1/event-tracker");
    var response = await http.get(url, headers: {"locale": "en", "apikey": "qPgPPRJyGCIPxFT3el4MF7thXHyJCzAP", "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"});

    if (response.statusCode == 200) {
      nextRace = jsonDecode(response.body)["race"];
      nextRaceFull = jsonDecode(response.body);
      nextDate = DateTime.parse(nextRace['meetingStartDate']);
      raceCountry = nextRace['meetingCountryName'];
      print(nextRace);
    } else {
      print(response.statusCode);
    } //qPgPPRJyGCIPxFT3el4MF7thXHyJCzAP

    var raceImg = await getRaceThumb();

    Map<String, dynamic> data = {'raceThumbnail': raceImg, 'raceData': nextRace, 'raceDataFull': nextRaceFull};
    return data;
  }

  void timeUntilRace() {
    String days = nextDate.difference(DateTime.now()).inDays.toString().padLeft(2, '0');
    String hours = nextDate.difference(DateTime.now()).inHours.remainder(24).toString().padLeft(2, '0');
    String minutes = nextDate.difference(DateTime.now()).inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = nextDate.difference(DateTime.now()).inSeconds.remainder(60).toString().padLeft(2, '0');

    setState(() {
      timer = "$days:$hours:$minutes:$seconds";
    });
  }


}