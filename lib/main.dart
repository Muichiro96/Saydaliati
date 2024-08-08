import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _appTitle= 'Home';
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',

    ),
    Text(
      'Index 1: List',

    ),
   Map()
  , Text(
      'Index 2: Profile',

    ), Text(
      'Index 2: Settings',

    ),
  ];
  void _onItemTapped(int index,String title) {
    setState(() {
      _selectedIndex = index;
      _appTitle = title;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title:  Text(_appTitle),
    foregroundColor: Colors.white,
    backgroundColor: Colors.green,
    ),
    body: _widgetOptions[_selectedIndex],
    drawer: Drawer(
    child: ListView(
    children: [

    const UserAccountsDrawerHeader(
    decoration: BoxDecoration(
    color: Colors.green,

    ),
    accountName: Text("username"),
    accountEmail: Text("email@test.com"),
    currentAccountPicture: CircleAvatar(
    backgroundImage:AssetImage("images/homme.png"),
    )),
    ListTile(
    title: const Text('Home'),
    leading: const Icon(Icons.home),
    onTap: () {
    // Update the state of the app.
      _onItemTapped(0,"Home");
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
      _onItemTapped(1,"List");
      Navigator.pop(context);
    },
    ),ListTile(
    title: const Text('Map'),
    leading: const Icon(Icons.map_sharp),
    onTap: () {
    // Update the state of the app.
    // ...

      _onItemTapped(2,"Map");
      Navigator.pop(context);
    },
    ),

    ListTile(
    title: const Text('Profile'),
    leading: const Icon(Icons.account_circle),
    onTap: () {
    // Update the state of the app.
    // ...
      _onItemTapped(3,"Profile");
      Navigator.pop(context);
    },
    ),

    ListTile(
    title: const Text('Settings'),
    leading: const Icon(Icons.settings),
    onTap: () {
    // Update the state of the app.
    // ...
      _onItemTapped(4,"Settings");
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
    return const SafeArea(child: MaterialApp(

      home:   HomePage(),debugShowCheckedModeBanner: false,
      )
    );}
}
class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController? mapController;
  Location location = Location(); // Create a Location instance
  Set<Marker> markers = {};

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final userLocation = await location.getLocation();
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('myLocation'),
        position: LatLng(userLocation.latitude!, userLocation.longitude!),
        infoWindow: InfoWindow(title: 'Your Location'),
      ));
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(userLocation.latitude!, userLocation.longitude!),
        15, // Adjust zoom level as needed
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return

    GoogleMap(

        initialCameraPosition: CameraPosition(
        target: LatLng( 30.4241, -9.5962),
        zoom: 7
    ),markers :markers,onMapCreated: _onMapCreated);
  }
}
