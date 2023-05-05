import 'package:edwardstcole_roomme_challenge/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';


class UVAScreen extends StatefulWidget{
  @override
  State<UVAScreen> createState() => _UVAScreenState();
}

class _UVAScreenState extends State<UVAScreen> {
  @override

  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: Text('University of Virginia Students'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(24, 24, 27, 1),
        ),
        child: Center(
          child: FutureBuilder<QuerySnapshot>(
            future: users.get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        data['name'],
                        style: GoogleFonts.poppins(
                          color: Color.fromRGBO(241, 241, 243, 1),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        data['email'],
                        style: GoogleFonts.poppins(
                          color: Color.fromRGBO(241, 241, 243, 1),
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
              
              return CircularProgressIndicator(); // Show a loading spinner if the data is still being fetched
            },
          ),
        ),
      ),
    );
  }
}