import 'package:flutter/material.dart';
import 'package:medical_app/data_stores/doctor_data.dart';
import 'package:medical_app/models/doctor_model.dart';
import 'package:medical_app/ui/doctor_profile.dart';
import 'package:medical_app/ui/widgets/custom_button.dart';
import 'package:medical_app/ui/widgets/custom_textfield.dart';
import 'package:medical_app/ui/widgets/snackbar.dart';

class SearchByName extends StatefulWidget {
  static String routeName = "/searchName";
  const SearchByName({Key? key}) : super(key: key);

  @override
  State<SearchByName> createState() => _SearchByNameState();
}

class _SearchByNameState extends State<SearchByName> {
  final TextEditingController searchStringController = TextEditingController();
  String searchString = "";
  List<Doctor> searchResults = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              searchString == ""
                  ? CustomTextField(
                      controller: searchStringController,
                      hintText: "Enter doctor name to search")
                  : Text(
                      "Results for $searchString\nClick on the doctor name to request appointment",
                      textScaleFactor: 1.2,
                    ),
              SizedBox(
                height: 20,
              ),
              searchString == ""
                  ? CustomButton(
                      onTap: () {
                        setState(() {
                          searchString = searchStringController.text;
                          print("Search string is $searchString");
                        });
                      },
                      text: "Search")
                  : Container(),
              searchString != ""
                  ? FutureBuilder<List<Doctor>>(
                      future: DoctorData().searchDoctorByName(searchString),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text("${snapshot.error.toString()}");
                        }
                        if (snapshot.hasData) {
                          return Expanded(
                              child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DoctorProfile(
                                                            selectedDoc:
                                                                snapshot.data![
                                                                    index])));
                                          },
                                          child: Container(
                                              // height: 100,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.4)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    snapshot
                                                        .data![index].fullName,
                                                    style:
                                                        TextStyle(fontSize: 25),
                                                  ),
                                                  Text(
                                                      "Speciality: ${snapshot.data![index].speciality}"),
                                                  Text(
                                                      "Symptoms treated: ${snapshot.data![index].symptom}")
                                                ],
                                              )),
                                        ),
                                      )));
                        }
                        return Container();
                      })
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
