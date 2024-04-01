import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nebula/configs/constants/Spaces.dart';
import 'package:nebula/features/Data/Models/usermodel.dart';
import 'package:nebula/features/Presentation/Bloc/User_bloc/user_bloc_bloc.dart';
import 'package:nebula/features/Presentation/Pages/MainHomePage/MainHomePage.dart';



class Initial extends StatefulWidget {
  const Initial({super.key});

  @override
  State<Initial> createState() => _InitialState();
}

class _InitialState extends State<Initial> {

  bool _isloading = false;

 final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      surfaceTintColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 5,
            left:10,
            child:Image.asset('assets/sound-wave.png',fit: BoxFit.fill,color: Colors.blue.withOpacity(0.1),)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome',style: GoogleFonts.aBeeZee(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 50,
                        )),
                         Text('Aboard!',style: GoogleFonts.aBeeZee(
                        decoration: TextDecoration.none,
                        color: Colors.indigo,
                        fontSize: 40,
                        )),
                        Spaces.Kheight20,
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent
                          ),
                          child: TextFormField(
                            controller: _textEditingController,
                            style: Spaces.Getstyle(14,Colors.white,FontWeight.normal),
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: Spaces.Getstyle(14,Colors.white.withOpacity(0.4),FontWeight.normal),
                              labelStyle: Spaces.Getstyle(14,Colors.white,FontWeight.normal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                              )
                            )
                          ),
                        ),
                        Spaces.Kheight20,
                        
                        Spaces.Kheight20,
                        GestureDetector(
                          onTap: () {
                            if (_textEditingController.text.isNotEmpty && _textEditingController.text.length >= 5) {
                            setState(() {
                              _isloading= !_isloading;
                            });
                            Usermodel usermodel = Usermodel(name: _textEditingController.text.trim(), date: DateTime.now().toString());
                            BlocProvider.of<UserBlocBloc>(context).add(UserBlocEvent.userdetails(usermodel,'initial'));
                            Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=>const MainHomePage()));
                            } else {
                              Spaces.showtoast('Your name must contain a minimum of 5 characters.');
                            }
                            },
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(10)
                            ),
                              child: const Center(
                              child: Textutil(text: 'Proceed', fontsize: 15, color: Colors.white, fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        Spaces.Kheight20,
                        Text('Disclaimer :- I respect your privacy more than anything else so all of your data is stored on your device only',
                        style: GoogleFonts.aldrich(color: Colors.white,fontSize: 13),)
                    ],
                  ),
                ),
              ),
            ),
          ),
          _isloading==true? Container(
            height:100,
            width:100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.8)
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white,),
            ),
          ):const SizedBox()
        ],
      ),
    );
  }

}