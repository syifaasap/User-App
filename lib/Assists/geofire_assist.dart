import 'package:user_app/Models/active_nearby_available_technicians.dart';

class GeofireAssists {
  static List<ActiveNearbyAvailableTechnicians>
      activeNearbyAvailableTechniciansList = [];

  static void deleteOfflineTechnicianFromList(String techniciansId) {
    int indexNumber = activeNearbyAvailableTechniciansList
        .lastIndexWhere((element) => element.techniciansId == techniciansId);
    activeNearbyAvailableTechniciansList.removeAt(indexNumber);
  }

  static void updateActiveNearbyAvailableTechniciansLocation(
      ActiveNearbyAvailableTechnicians techniciansMoves) {
    int indexNumber = activeNearbyAvailableTechniciansList.indexWhere(
        (element) => element.techniciansId == techniciansMoves.techniciansId);

    activeNearbyAvailableTechniciansList[indexNumber].locationLatitude =
        techniciansMoves.locationLatitude;
    activeNearbyAvailableTechniciansList[indexNumber].locationLongitude =
        techniciansMoves.locationLongitude;
  }
}
