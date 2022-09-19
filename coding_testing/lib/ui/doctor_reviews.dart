import 'package:medical_app/data_stores/user_data.dart';
import 'package:medical_app/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoctorReviews extends StatelessWidget {
  DoctorReviews({required this.reviews, Key? key}) : super(key: key);
  List<ReviewModel> reviews;
  @override
  Widget build(BuildContext context) {
    if (reviews.length == 0) {
      print("YAY");
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Text(
              "No reviews present",
              textScaleFactor: 1.4,
            )),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2)),
                  child: Column(
                    children: [
                      FutureBuilder<String>(
                          future: context
                              .read<UserData>()
                              .getPatientNameFromID(reviews[index].patientId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data ?? "Patient",
                                textScaleFactor: 1.4,
                              );
                            }
                            return Container(
                              height: 20,
                            );
                          }),
                      getStars(reviews[index].stars),
                      Text(reviews[index].description,textScaleFactor: 1.6,)
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

Widget getStars(int stars) {
  List<Widget> list = [];
  for (int i = 0; i < stars; i++) {
    list.add(Icon(Icons.star,color: Colors.amber,));
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: list,
  );
}
