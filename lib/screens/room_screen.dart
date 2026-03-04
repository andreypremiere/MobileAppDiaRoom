import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';


class Room extends StatefulWidget {

  const Room({super.key});

  @override
  State<Room> createState() {
    return _RoomState();
  }
}

class _RoomState extends State<Room> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: Color(0xFFC9BBBB),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Color(0xFFFFA6A6).withAlpha(0),
            leading: IconButton(
              onPressed: () {
              },
              icon: SvgPicture.asset(
                'assets/icons/button_back.svg',
                width: 30,
                height: 30,
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(children: [
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage('assets/images/background_profile.png'),
                            fit: BoxFit.cover),
                        color: Color(0xFFCB6C6C)
                    ),
                    child: Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                      child: Stack(
                      children: [
                        Positioned(bottom: 15, left: 15, child: Text("Room name",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SNPro',
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                            shadows: [
                            Shadow(
                            blurRadius: 15.0,       // Насколько сильно размыта тень
                            color: Colors.black54,  // Цвет тени (черный с прозрачностью 54%)
                            offset: Offset(1.0, 1.0), // Смещение тени по X и Y
                          ),]
                          ),
                        )
                        ),
                        Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child:Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 40, // Радиус круга (итоговый размер будет 100x100)
                                backgroundImage: AssetImage('assets/images/avatar.jpg'),
                                // Если фото из сети: NetworkImage('https://...')
                              ),
                              Container(
                                height: 60,
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blueGrey
                                ),
                                child: Center(child: Text("Партнер")),
                              )
                            ],
                          ),
                        ))
                      ],
                    ),)
                  )
                ],)
            ],
          ),
        )
    );
  }
}