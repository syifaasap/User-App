import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_app/Models/directions_details.dart';
import 'package:user_app/Models/user_models.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List techList = []; //online-active technicianInfo List
DirectionDetailInfo? tripDirectionDetailsInfo; // Mengitung biaya
String? technicianChosenId = "";
String cloudMessagingServerToken =
    "key=AAAAfRa6sBg:APA91bEBE13Ed4sSrEUVHi66v3RtJKZ9SGAv4jqwtG7AejsA5MuTUYs5w9Uuhva8E7BQWmKJRhw9XkcF18dj7feG7K4bOUpRDJQujwbUliYgDy76pTVkjkWgx4plwiJib2dL-PQlaqix";
String userDropOffAddress = "";
String technicianCarDetails = "";
String technicianName = "";
String technicianPhone = "";
double countRatingStars = 0;
String titleStarsRating = "";
