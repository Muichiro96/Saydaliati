import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geocoding/geocoding.dart';
import 'package:postgres/postgres.dart';
void main() {
  runApp(const MyApp());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _appTitle = 'Home';
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
    ),
    Text(
      'Index 1: List',
    ),
    Map(),
    Text(
      'Index 2: Profile',
    ),
    Text(
      'Index 2: Settings',
    ),
  ];
  void _onItemTapped(int index, String title) {
    setState(() {
      _selectedIndex = index;
      _appTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appTitle),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      body: _widgetOptions[_selectedIndex],
      drawer: Drawer(
          child: ListView(
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(image: AssetImage("images/Welcome.png"),fit: BoxFit.fill)
              ),child: Text(""),
             ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home),
            onTap: () {
              // Update the state of the app.
              _onItemTapped(0, "Home");
              Navigator.pop(context);
              // ...
            },
          ),
          ListTile(
            title: const Text('List'),
            leading: const Icon(Icons.list),
            onTap: () {
              // Update the state of the app.
              // ...
              _onItemTapped(1, "List");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Map'),
            leading: const Icon(Icons.map_sharp),
            onTap: () {
              // Update the state of the app.
              // ...

              _onItemTapped(2, "Map");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // Update the state of the app.
              // ...
              _onItemTapped(3, "Profile");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              // Update the state of the app.
              // ...
              _onItemTapped(4, "Settings");
              Navigator.pop(context);
            },
          ),
        ],
      ) // Populate the Drawer in the next step.
          ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ));
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  Connection? conn;
  BitmapDescriptor? myIcon;
  GoogleMapController? mapController;
  Marker? userLocation;
  String? _city;
  DateTime? date;
  LatLng? _center;
  Position? _currentPosition;
  Set<Marker> markers = {};
  Set<Marker> pharmacieMarkers= {};
  void getConnection() async {
    conn = await Connection.open(Endpoint(
      host: 'localhost',
      database: 'sfa',
      username: 'postgres',
      password: 'root',
    ));
  }
  @override
  void initState() {
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(90, 80)), 'images/myposition.png')
        .then((onValue) {
      myIcon = onValue;
    });
    getConnection();
    DateTime now = DateTime.now();
    date= DateTime(now.year, now.month, now.day);
    super.initState();

    _getUserLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
// Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
// Request permission to get the user's location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }
// Get the current location of the user
    _currentPosition = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best));
   
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    setState(() {
      _city=placemarks[0].locality;
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      userLocation=Marker(
        markerId: const MarkerId('user_location'),
        position: _center!,
        infoWindow: const InfoWindow(title: 'Votre position'),
        icon: myIcon!
      );
      markers.add(userLocation!);
      pharmacieMarkers.add(userLocation!);

    });
  }

  @override
  Widget build(BuildContext context) {
    return _center == null
        ? const Center(child: CircularProgressIndicator())
        : Stack(children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center!,
                zoom: 15.0,
              ),
              markers: pharmacieMarkers.isEmpty?markers:pharmacieMarkers,
            ),

            Align( alignment: Alignment.topRight,child: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                animatedIconTheme: const IconThemeData(size: 22),
                backgroundColor: Colors.green,
                direction: SpeedDialDirection.down,
                visible: true,
                curve: Curves.bounceIn,
                children: [
                  // FAB 1
                  SpeedDialChild(
                      child: const Icon(
                        Icons.nightlight,
                        size: 28,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.green,
                      onTap: () {
                        setState(() async{
                          pharmacieMarkers.clear();
                          pharmacieMarkers.add(userLocation!);
                          final results=await conn!.execute(r'SELECT p.nom,p.adresse,p.telephone,p.lattitude,p.longitude, g.date,g.type,v.nom FROM villes AS v INNER JOIN pharmacies AS pON v.idVille = p.ville_id INNER JOIN garde_pharmacie AS gp ON p.idPharmacie = gp.pharmacie_id INNER JOIN gardes AS g ON gp.garde_id = g.idGarde WHERE v.nom = $1 AND g.date =$2 AND g.type=$3',parameters: [_city,date,'Nuit']);
                          for(final pharmacie in results){
                            final latitude =double.parse(pharmacie[3].toString());
                            final longitude =double.parse(pharmacie[4].toString());
                            pharmacieMarkers.add(Marker(markerId: MarkerId('nuit'),
                              position:  LatLng(latitude,longitude ),
                              infoWindow:  InfoWindow(title: pharmacie[0].toString()),
                            ));
                          };

                        });
                      },
                      label: 'Pharmacies De Garde Nuit',
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                      ),
                      labelBackgroundColor: Colors.green),
                  // FAB 2
                  SpeedDialChild(
                      child: const Icon(
                        Icons.sunny,
                        color: Colors.yellow,
                      ),
                      backgroundColor: Colors.green,
                      onTap: () {
                        setState(() async{
                          pharmacieMarkers.clear();
                          pharmacieMarkers.add(userLocation!);
                          final results=await conn!.execute(r'SELECT p.nom,p.adresse,p.telephone,p.lattitude,p.longitude, g.date,g.type,v.nom FROM villes AS v INNER JOIN pharmacies AS pON v.idVille = p.ville_id INNER JOIN garde_pharmacie AS gp ON p.idPharmacie = gp.pharmacie_id INNER JOIN gardes AS g ON gp.garde_id = g.idGarde WHERE v.nom = $1 AND g.date =$2 AND g.type=$3',parameters: [_city,date,'Jour']);
                          for(final pharmacie in results){
                            final latitude =double.parse(pharmacie[3].toString());
                            final longitude =double.parse(pharmacie[4].toString());
                          pharmacieMarkers.add(Marker(markerId: MarkerId('jour'),
                          position:  LatLng(latitude,longitude ),
                          infoWindow:  InfoWindow(title: pharmacie[0].toString()),
                          ));
                          };

                        });

                      },
                      label: 'Pharmacies De Garde Jour',
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          ),
                      labelBackgroundColor: Colors.green),
                  SpeedDialChild(
                      child: const Icon(
                        Icons.history,
                        size: 28,
                        color: Colors.blueGrey,
                      ),
                      backgroundColor: Colors.green,
                      onTap: () {/* do anything */},
                      label: 'Pharmacies De Garde 24h',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      labelBackgroundColor: Colors.green),
                  SpeedDialChild(
                      child: const Icon(
                        Icons.near_me,
                        size: 28,
                        color: Colors.blueAccent,
                      ),
                      backgroundColor: Colors.green,
                      onTap: () {  setState(() async{
                        pharmacieMarkers.clear();
                        pharmacieMarkers.add(userLocation!);
                        final results=await conn!.execute(r'SELECT p.nom,p.adresse,p.telephone,p.lattitude,p.longitude, g.date,g.type,v.nom FROM villes AS v INNER JOIN pharmacies AS pON v.idVille = p.ville_id INNER JOIN garde_pharmacie AS gp ON p.idPharmacie = gp.pharmacie_id INNER JOIN gardes AS g ON gp.garde_id = g.idGarde WHERE v.nom = $1 AND g.date =$2 AND g.type=$3',parameters: [_city,date,'24h/24']);
                        for(final pharmacie in results){
                          final latitude =double.parse(pharmacie[3].toString());
                          final longitude =double.parse(pharmacie[4].toString());
                          pharmacieMarkers.add(Marker(markerId: MarkerId('24'),
                            position:  LatLng(latitude,longitude ),
                            infoWindow:  InfoWindow(title: pharmacie[0].toString()),
                          ));
                        };

                      });},
                      label: 'Pharmacies Proche De Moi',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      labelBackgroundColor: Colors.green),
                ],
              )

            )
          ]);
  }
}
class ListePharmacies extends StatefulWidget {
  const ListePharmacies({super.key});

  @override
  State<ListePharmacies> createState() => _ListeState();
}

class _ListeState extends State<ListePharmacies> {
  Connection? conn;
  void getConnection() async {
    conn = await Connection.open(Endpoint(
      host: 'localhost',
      database: 'sfa',
      username: 'postgres',
      password: 'root',
    ));
  }
  @override void initState() {
   final results=conn!.execute("SELECT nom FROM villes");

    
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
