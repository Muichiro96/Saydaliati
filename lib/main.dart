import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
void main() {
  runApp(const MyApp());
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   late GoogleMapController mapController;


  String _appTitle= 'Home';
  int _selectedIndex = 0;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',

    ),
    Text(
      'Index 1: List',

    ),
   GoogleMap(
  initialCameraPosition: CameraPosition(
  target: LatLng(-33.86, 151.20),
  zoom: 14
  ),
  ), Text(
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