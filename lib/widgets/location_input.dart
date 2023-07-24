import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:native_device_feature/models/place.dart';
import 'package:native_device_feature/screens/map_screen.dart';

class LocationInputWidget extends StatefulWidget {
  const LocationInputWidget({
    super.key,
    required this.onSelectedLocation,
  });

  final void Function(PlaceLocation location) onSelectedLocation;
  @override
  State<LocationInputWidget> createState() {
    return _LocationInputWidget();
  }
}

class _LocationInputWidget extends State<LocationInputWidget> {
  PlaceLocation? _pickedLocation;
  bool _isGettingLocation = false;

  void _savePlace(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude=YOUR_API_KEY',
    );

    final response = await http.get(url);
    final responseData = json.decode(response.body);
    final address = responseData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocation = PlaceLocation(
          latitude: latitude, longitude: longitude, address: address);
      _isGettingLocation = false;
    });
    widget.onSelectedLocation(_pickedLocation!);
  }

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center$lat,$lng=&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C$lat,$lng&key=YOUR_API_KEY&signature=YOUR_SIGNATURE';
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();

    final lat = locationData.latitude;
    final long = locationData.longitude;

    if (lat == null || long == null) {
      return;
    }

    _savePlace(lat, long);
  }

  void _onSelectMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(),
      ),
    );
    if (_pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation!.latitude, _pickedLocation!.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Center(
      child: Text(
        'No location chosen',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      previewContent = const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(
                Icons.location_on,
              ),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: _onSelectMap,
              icon: const Icon(
                Icons.map,
              ),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
