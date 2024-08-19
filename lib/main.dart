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
  final  DarkMode;
  const HomePage({super.key,required this.DarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  String _appTitle = 'Map';
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[


    const Map(),
    const ListePharmacies(),
     const ContactForm()
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
            title: const Text('Map'),
            leading: const Icon(Icons.map),
            onTap: () {
              // Update the state of the app.
              _onItemTapped(0, "Map");
              Navigator.pop(context);
              // ...
            },
          ),
          ListTile(
            title: const Text('Liste'),
            leading: const Icon(Icons.list),
            onTap: () {
              // Update the state of the app.
              // ...
              _onItemTapped(1, "List");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Contact'),
            leading: const Icon(Icons.mail),
            onTap: () {
              // Update the state of the app.
              // ...

              _onItemTapped(2, "Contactez-nous");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            leading: const Icon(Icons.settings),
            onTap: () {
              // Update the state of the app.
              // ...
              setState(() {
                _widgetOptions.add(
                    settings(toggleMode : widget.DarkMode));
              });

              _onItemTapped(3, "Settings");
              Navigator.pop(context);
            },
          ),
        ],
      ) // Populate the Drawer in the next step.
          ),
    );
  }
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  ThemeMode _themeMode=ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: MaterialApp(
          theme: ThemeData(primaryColor: Color(0xFF30df7b), brightness: Brightness.light,),
          darkTheme: ThemeData(
            primaryColor: Color(0xFF1a904d),
            brightness: Brightness.dark,
          ),
          themeMode: _themeMode,
          home: HomePage(DarkMode : (bool state){
          setState(() {

          _themeMode=state?ThemeMode.dark:ThemeMode.light;
          });
          }),
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

  BitmapDescriptor? myIcon;
  BitmapDescriptor? day;
  BitmapDescriptor? night;
  BitmapDescriptor? allDay;
  BitmapDescriptor? pharmacy;
  GoogleMapController? mapController;
  Marker? userLocation;
  String? _city;
  DateTime? date;
  LatLng? _center;
  Position? _currentPosition;
  Set<Marker> markers = {};
  Set<Marker> pharmacieMarkers= {};


  @override
  void initState() {
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(80, 75)), 'images/myposition.png')
        .then((onValue) {
      myIcon = onValue;
    });
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(55, 50)), 'images/jour.png')
        .then((onValue) {
      day = onValue;
    });
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(55, 50)), 'images/nuit.png')
        .then((onValue) {
      night = onValue;
    });
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(55, 50)), 'images/allDay.png')
        .then((onValue) {
      allDay = onValue;
    });
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(55, 50)), 'images/pharmacie.png')
        .then((onValue) {
      pharmacy = onValue;
    });


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
                      onTap: () async{
                        final con=await Connection.open(Endpoint(
                          host: '192.168.11.110',
                          port: 5432,
                          database: 'sfa',
                          username: 'postgres',
                          password: 'root',
                        ),settings: ConnectionSettings(sslMode: SslMode.disable),
                        );

                        final results=await con.execute(r'SELECT p.nom,p.adresse,p.telephone,p.lattitude,p.longitude, g.date,g.type,v.nom FROM villes AS v INNER JOIN pharmacies AS p ON v."idVille" = p."ville_id" INNER JOIN garde_pharmacie AS gp ON p."idPharmacie" = gp."pharmacie_id" INNER JOIN gardes AS g ON gp."garde_id" = g."idGarde" WHERE v.nom = $1 AND g.date =$2 AND g.type=$3',parameters: [_city,date,"Nuit"]);

                        setState(() {
                          pharmacieMarkers.clear();
                          pharmacieMarkers.add(userLocation!);
                          for(final pharmacie in results){
                            final latitude =double.parse(pharmacie[3].toString());
                            final longitude =double.parse(pharmacie[4].toString());
                            pharmacieMarkers.add(Marker(markerId: MarkerId(pharmacie[0].toString()),
                              position:  LatLng(latitude,longitude ),
                                infoWindow:  InfoWindow(title: pharmacie[0].toString(),snippet:"Adresse : ${pharmacie[1].toString()} \nTéléphone: ${pharmacie[2].toString()}  "),
                              icon: night!
                            ));
                          };

                        });await con.close();},
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
                      onTap: () async{
                        final con=await Connection.open(Endpoint(
                          host: '192.168.11.110',
                          port: 5432,
                          database: 'sfa',
                          username: 'postgres',
                          password: 'root',
                        ),settings: ConnectionSettings(sslMode: SslMode.disable),
                        );
                        final results=await con.execute(r'SELECT p.nom,p.adresse,p.telephone,p.lattitude,p.longitude, g.date,g.type,v.nom FROM villes AS v INNER JOIN pharmacies AS p ON v."idVille" = p."ville_id" INNER JOIN garde_pharmacie AS gp ON p."idPharmacie" = gp."pharmacie_id" INNER JOIN gardes AS g ON gp."garde_id" = g."idGarde" WHERE v.nom = $1 AND g.date =$2 AND g.type=$3',parameters: [_city,date,'Jour']);


                        setState(() {
                          pharmacieMarkers.clear();
                          pharmacieMarkers.add(userLocation!);
                          for(final pharmacie in results){
                            final latitude =double.parse(pharmacie[3].toString());
                            final longitude =double.parse(pharmacie[4].toString());
                          pharmacieMarkers.add(Marker(markerId: MarkerId(pharmacie[0].toString()),
                          position:  LatLng(latitude,longitude ),
                              infoWindow:  InfoWindow(title: pharmacie[0].toString(),snippet:"Adresse : ${pharmacie[1].toString()} \nTéléphone: ${pharmacie[2].toString()}  "),
                            icon: day!
                          ));
                          };

                        });
                        await con.close();
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
                      onTap: () async{
                        final con= await Connection.open(Endpoint(
                          host: '192.168.11.110',
                          port: 5432,
                          database: 'sfa',
                          username: 'postgres',
                          password: 'root',
                        ),settings: ConnectionSettings(sslMode: SslMode.disable),
                        );

                        final results=await con.execute(r'SELECT p.nom,p.adresse,p.telephone,p.lattitude,p.longitude, g.date,g.type,v.nom FROM villes AS v INNER JOIN pharmacies AS p ON v."idVille" = p."ville_id" INNER JOIN garde_pharmacie AS gp ON p."idPharmacie" = gp."pharmacie_id" INNER JOIN gardes AS g ON gp."garde_id" = g."idGarde" WHERE v.nom = $1 AND g.date =$2 AND g.type=$3' ,parameters: [_city,date,"24h/24"]);

                        setState(() {
                          pharmacieMarkers.clear();
                          pharmacieMarkers.add(userLocation!);
                          for(final pharmacie in results){
                            final latitude =double.parse(pharmacie[3].toString());
                            final longitude =double.parse(pharmacie[4].toString());
                            pharmacieMarkers.add(Marker(markerId: MarkerId(pharmacie[0].toString()),
                              position:  LatLng(latitude,longitude ),
                                infoWindow:  InfoWindow(title: pharmacie[0].toString(),snippet:"Adresse : ${pharmacie[1].toString()} \nTéléphone: ${pharmacie[2].toString()}  "),
                              icon: allDay!
                            ));
                          };

                        }); await con.close();},
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
                      onTap: ()async{
    final con= await Connection.open(Endpoint(
    host: '192.168.11.110',
    port: 5432,
    database: 'sfa',
    username: 'postgres',
    password: 'root',
    ),settings: ConnectionSettings(sslMode: SslMode.disable),
    );

    final results=await con.execute(r'SELECT p.nom,p.adresse,p.telephone,p.lattitude,p.longitude,v.nom FROM villes AS v INNER JOIN pharmacies AS p ON v."idVille" = p."ville_id" WHERE v.nom = $1 ' ,parameters: [_city]);

    setState(() {
    pharmacieMarkers.clear();
    pharmacieMarkers.add(userLocation!);
    for(final pharmacie in results){
    final latitude =double.parse(pharmacie[3].toString());
    final longitude =double.parse(pharmacie[4].toString());
    pharmacieMarkers.add(Marker(markerId: MarkerId(pharmacie[0].toString()),
    position:  LatLng(latitude,longitude ),
    infoWindow:  InfoWindow(title: pharmacie[0].toString(),snippet:"Adresse : ${pharmacie[1].toString()} \n Téléphone: ${pharmacie[2].toString()}  "),
      icon: pharmacy!
    ));
    };

    }); await con.close();},
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
  String? dropdownValue;
  List<Card>? liste;
  List<String> villes=[' '];
  void start() async {
    final conn = await Connection.open(Endpoint(
      host: '192.168.11.110',
      port: 5432,
      database: 'sfa',
      username: 'postgres',
      password: 'root',
    ),settings: ConnectionSettings(sslMode: SslMode.disable),);
    final results=await conn.execute("SELECT v.nom FROM villes AS v");

    setState(() {
      villes = results.map((row) => row[0].toString()).toList();
    });
    await conn.close();
  }

  @override
  void initState() {
    start();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(children:<Widget>[ Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground,fontSize: 16),
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
              items: villes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SizedBox(width: 8.0),
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.green),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered))
                    return Colors.green.withOpacity(0.04);
                  if (states.contains(WidgetState.focused) ||
                      states.contains(WidgetState.pressed))
                    return Colors.green.withOpacity(0.12);
                  return null; // Defer to the widget's default.
                },
              ),
            ),
            onPressed: () async {
    final conn = await Connection.open(Endpoint(
    host: '192.168.11.110',
    port: 5432,
    database: 'sfa',
    username: 'postgres',
    password: 'root',
    ),settings: ConnectionSettings(sslMode: SslMode.disable),);
    final results=await conn.execute(r'SELECT p.nom,p.adresse,p.telephone,v.nom FROM pharmacies AS p INNER JOIN villes AS v ON v."idVille"=p."ville_id" WHERE v.nom=$1 ',parameters: [dropdownValue]);

    setState(() {
    liste = results.map((row) =>  Card(
    child: Column(
    mainAxisSize: MainAxisSize.min,
      children: <Widget>[
         ListTile(
          leading: Icon(Icons.home_work_outlined),
          title: Text(row[0].toString()),
          subtitle: Text(row[1].toString()),
        ),
        Row(
        children: [ Icon(Icons.phone, color: Colors.blue, size: 20),
          SizedBox(width: 8.0),
          Expanded(child: Text(row[2].toString())),],
        ),
      ],
    ),
      ),).toList();
    });
    await conn.close();
    }
            ,
            child: Text('Chercher'),
          ),
        ],
      ),
    ),liste != null? Expanded(child:ListView(children: liste!)):Center(child: Text(" "),)]);
  }
}
class ContactForm extends StatefulWidget {
  const ContactForm ({super.key});
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Envoi Message')),
      );

      // Here you can process the form data, e.g., send it to a server
      final conn = await Connection.open(Endpoint(
        host: '192.168.11.110',
        port: 5432,
        database: 'sfa',
        username: 'postgres',
        password: 'root',
      ),settings: ConnectionSettings(sslMode: SslMode.disable),);
      final results=await conn.execute(r'insert into contacts (nom,email,message) values ($1,$2,$3)',parameters: [_nameController,_emailController,_messageController]);


    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0), // Add spacing between fields
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0), // Add spacing between fields
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Message'),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0), // Add spacing before button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
class settings extends StatefulWidget {
  final toggleMode;
  const settings({super.key,required this.toggleMode});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {

  bool isDarkMode = false;
  void _toggleTheme(bool state) {
    setState(() {

      isDarkMode  = state;

    });
    widget.toggleMode(state);
  }
  @override
  Widget build(BuildContext context) {
    setState(() {
      isDarkMode= Theme.of(context).brightness==Brightness.dark;
    });
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Dark Mode Switch
            SwitchListTile(
              title: Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (bool isOn) {
                isOn
                    ? _toggleTheme(true)
                    : _toggleTheme(false);
              },
            ),
          ],
        ),
      );

  }
}

