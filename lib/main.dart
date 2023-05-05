import 'package:edwardstcole_roomme_challenge/firebase_options.dart';
import 'package:edwardstcole_roomme_challenge/jmu.dart';
import 'package:edwardstcole_roomme_challenge/uva.dart';
import 'package:edwardstcole_roomme_challenge/vt.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(const MyApp());
}

Future<void> _saveUserData({
  required String name,
  required String email,
  required String bio,
  required Map<String, bool> collegeCheckStatus,
  File? image,
}) async {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  
  String? imageURL;

  if (image != null) {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('user_images').child('$email.jpg');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    imageURL = await taskSnapshot.ref.getDownloadURL();
  }

  return users
      .add({
        'name': name,
        'email': email,
        'bio': bio,
        'colleges': collegeCheckStatus,
        'imageURL': imageURL,
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp (
      debugShowCheckedModeBanner: false,
      title: 'RoomMe Challenge',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/uva': (context) => UVAScreen(),
        '/jmu':(context) => JMUScreen(),
        '/vt':(context) => VTScreen(),
      },
    );
  }
}


class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          bottom: TabBar(
            indicatorWeight: 3,
            labelColor: Color.fromRGBO(28, 83, 172, 1),
            indicatorColor: Color.fromRGBO(28, 83, 172, 1),
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                text: 'Home'
              ),
              Tab(
                icon: Icon(Icons.school),
                text: 'Create Account'
              ),  
            ],
          ),
          title: AutoSizeText(
            'RoomMe Challenge',
            style: GoogleFonts.poppins(
                    color: Color.fromRGBO(24, 24, 27, 1),
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          children: [
            PicturePage(),
            SelectorPage(),
          ],
        ),
            
      ),
      
    );
  }  
}

class PicturePage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var screenWidth = MediaQuery.of(context).size.width;
    var textPadding = EdgeInsets.only(left: screenWidth * 0.1, right: screenWidth * 0.1);

    return Scaffold(
      body: Container( 
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: textPadding,
                child: Image.asset(
                  'assets/images/cole-edwards.jpg',
                  width: 300,
                  //height: 250,
                ),
              ),
              SizedBox(height: 20),

              Container(
                padding: textPadding,
                child: AutoSizeText(
                  'Cole Edwards',
                  style: GoogleFonts.poppins(
                    color: Color.fromRGBO(24, 24, 27, 1),
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  minFontSize: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class CustomCheckboxTile extends StatefulWidget {
  final String college;
  final ValueChanged<bool> onChanged;

  CustomCheckboxTile({required this.college, required this.onChanged});

  @override
  _CustomCheckboxTileState createState() => _CustomCheckboxTileState();
}

class _CustomCheckboxTileState extends State<CustomCheckboxTile> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        widget.college,
        style: GoogleFonts.poppins(
          color: Color.fromRGBO(241, 241, 243, 1),
        ),
      ),
      value: _checked,
      onChanged: (bool? checked) {
        setState(() {
          _checked = checked!;
        });
        widget.onChanged(checked!);
      },
      checkColor: Colors.white,
      activeColor: Color.fromRGBO(28, 83, 172, 1),
    );
  }
}

class SelectorPage extends StatefulWidget {
  
  @override
  State<SelectorPage> createState() => _SelectorPageState();


}

class _SelectorPageState extends State<SelectorPage> {
  
  File? _pickedImage;

  
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var textPadding = EdgeInsets.only(left: screenWidth * 0.1, right: screenWidth * 0.1);

    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _bioController = TextEditingController();


    List<String> colleges = ['UVA', 'JMU', 'VT'];
    Map<String, bool> collegeCheckStatus = {
      'UVA': true,
      'JMU': true,
      'VT': true,
    };
    


    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(24, 24, 27, 1),
          //color: Colors.white,
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: textPadding,
                child: AutoSizeText(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    color: Color.fromRGBO(241, 241, 243, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  minFontSize: 1,
                ),
              ),

              SizedBox(height: 15),

              Text(
                'Profile Pic',
                style: GoogleFonts.poppins(
                  color: Color.fromRGBO(241, 241, 243, 1),
                ),
              ),
              SizedBox(height: 20),
              Container(

                
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: BeveledRectangleBorder(),
                  ),
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Icon(
                    Icons.upload_file,
                    size: 100,
                    color: Color.fromRGBO(28, 83, 172, 1),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          'Name',
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(241, 241, 243, 1),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _nameController,

                          textAlign: TextAlign.center,
                          cursorColor: Color.fromRGBO(241, 241, 243, 1),
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(241, 241, 243, 1),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(24, 24, 27, 1),

                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(241, 241, 243, 1),
                                width: 5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(28, 83, 172, 1)
                              ),
                            ),
                            hintStyle: GoogleFonts.poppins(
                              color: Color.fromRGBO(241, 241, 243, 1),
                            ),
                            hintText: 'John Smith',
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 10),
                  
                  Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: Text(
                          'Email',
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(241, 241, 243, 1),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _emailController,

                          textAlign: TextAlign.center,
                          cursorColor: Color.fromRGBO(241, 241, 243, 1),
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(241, 241, 243, 1),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(24, 24, 27, 1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(241, 241, 243, 1),
                                width: 5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(28, 83, 172, 1)
                              ),
                            ),
                            hintStyle: GoogleFonts.poppins(
                              color: Color.fromRGBO(241, 241, 243, 1),
                            ),
                            hintText: 'example@email.com',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 400,
                        child: Text(
                          'Bio',
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(241, 241, 243, 1),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 400,
                        child: TextFormField(
                          controller: _bioController,

                          textAlign: TextAlign.center,
                          cursorColor: Color.fromRGBO(241, 241, 243, 1),
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(241, 241, 243, 1),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(24, 24, 27, 1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(241, 241, 243, 1),
                                width: 5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(28, 83, 172, 1),
                              ),
                            ),
                            hintStyle: GoogleFonts.poppins(
                              color: Color.fromRGBO(241, 241, 243, 1),
                            ),
                            hintText: 'Love to watch sports, go on hikes, etc.',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          'College',
                          style: GoogleFonts.poppins(
                            color: Color.fromRGBO(241, 241, 243, 1),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Column(
                          children: colleges.map<Widget>((String college) {
                            return CustomCheckboxTile(
                              college: college,
                              onChanged: (bool? checked) {
                                setState(() {
                                  collegeCheckStatus[college] = checked ?? false;
                                });
                                print(collegeCheckStatus);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 25),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(28, 83, 172, 1),
                ),
                child: TextButton(
                  onPressed: () {
                    _saveUserData(
                      name: _nameController.text,
                      email: _emailController.text,
                      bio: _bioController.text,
                      collegeCheckStatus: collegeCheckStatus,
                    );
                  },
                  child: Text(
                    'Submit',
                    style: GoogleFonts.poppins(
                      color: Color.fromRGBO(241, 241, 243, 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Container(
                padding: textPadding,
                child: AutoSizeText(
                  'OR Select A College to View Other Students:',
                  style: GoogleFonts.poppins(
                    color: Color.fromRGBO(215, 215, 219, 1),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  minFontSize: 1,
                ),
              ),
              
              SizedBox(height: 10),

              CollegeButtons(screenWidth: screenWidth, screenHeight: screenHeight),
            ],
          ),
        ),
      ),
    );
  }
}

class CollegeButtons extends StatefulWidget {
  const CollegeButtons({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  final double screenWidth;
  final double screenHeight;

  @override
  State<CollegeButtons> createState() => _CollegeButtonsState();
}

class _CollegeButtonsState extends State<CollegeButtons> {
  
  bool uvaHover = false;
  bool jmuHover = false;
  bool vtHover = false;

  Color uvaBorder = Colors.transparent;


  @override
  Widget build(BuildContext context) {

    return OverflowBar(
      overflowAlignment: OverflowBarAlignment.center,
      spacing: 20,
      overflowSpacing: 5,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: uvaHover? EdgeInsets.only(top: 6, bottom: 6, left: 4, right: 4) : EdgeInsets.all(0), 
          curve: Curves.easeIn,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(35, 45, 75, 1),
                Color.fromRGBO(248, 76, 30, 1),
              ]
            ),
          ),
          child: ElevatedButton(
            
            style: ElevatedButton.styleFrom(
              shape: BeveledRectangleBorder(),
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.all(35),
            ),
            onHover: (val){
               setState((){
                uvaHover = val;
               });
            },
            onPressed: (){
              Navigator.pushNamed(
                context, 
                '/uva',
              );
            },
            child: Image.asset(
              'assets/images/uva.png',
              width: widget.screenWidth * 0.1,
              height: widget.screenHeight * 0.09,
            ),
          ),
        ),
              
        
              
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: jmuHover? EdgeInsets.only(top: 6, bottom: 6, left: 4, right: 4) : EdgeInsets.all(0), 
          curve: Curves.easeIn,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(69, 0, 132, 1),
                Color.fromRGBO(203, 182, 119, 1),
              ]
            ),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: BeveledRectangleBorder(),
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.all(35),
            ),
            onHover: (val){
               setState((){
                jmuHover = val;
               });
            },
            onPressed: (){
              Navigator.pushNamed(
                context, 
                '/jmu',
              );
            },
            child: Image.asset(
              'assets/images/jmu.png',
              width: widget.screenWidth * 0.1,
              height: widget.screenHeight * 0.09,
            )
          ),
        ),
              
              
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: vtHover? EdgeInsets.only(top: 6, bottom: 6, left: 4, right: 4) : EdgeInsets.all(0), 
          curve: Curves.easeIn,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromRGBO(207, 69, 32, 1),
                Color.fromRGBO(99, 0, 49, 1),
              ]
            ),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: BeveledRectangleBorder(),
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.all(35),
            ),
            onHover: (val){
               setState((){
                vtHover = val;
               });
            },
            onPressed: (){
              Navigator.pushNamed(
                context, 
                '/vt',
              );
            },
            child: Image.asset(
              'assets/images/va-tech.png',
              width: widget.screenWidth * 0.1,
              height: widget.screenHeight * 0.09,
            )
          ),
        ),
      ],
    );
  }
}
