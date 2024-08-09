import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

      home: HomePage(), debugShowCheckedModeBanner: false,
    )
    );
  }

}
class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController? mapController;
  LatLng? _center;
  Position? _currentPosition;
  Set<Marker> markers ={};
  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  _onClick(){

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
    _currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      markers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: _center!,
        infoWindow: const InfoWindow(title: 'Votre position'),
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return _center == null
          ? const Center(child: CircularProgressIndicator())
        :Stack(children:<Widget>[GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center!,
            zoom: 15.0,
          ),
          markers: markers,

    ),Align(alignment: Alignment.bottomRight ,child:FloatingActionButton(onPressed: _onClick))]);
  }
}