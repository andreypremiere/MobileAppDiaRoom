import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class VerifyCode extends StatefulWidget {
  final String? userId;

  const VerifyCode({super.key, this.userId});

  @override
  State<VerifyCode> createState() {
    return _VerifyCodeState();
  }
}

class _VerifyCodeState extends State<VerifyCode> {

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
          appBar: PreferredSize(preferredSize: const Size.fromHeight(0.0), child: AppBar()),
          body: Stack(
            children: [
              Positioned(top: 10, left: 10,
                  child: Container(
                    // decoration: BoxDecoration(
                    //   color: Color(0xFFFFFFFF),
                    //   shape: BoxShape.circle
                    // ),
                    child: IconButton(onPressed: () {
                      context.pop();
                    },
                        icon: SvgPicture.asset('assets/icons/button_back.svg', width: 30, height: 30)),
                  )),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10),
                          blurRadius: 18,
                          offset: const Offset(0, 0))]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Удалить потом
                      Text(widget.userId ?? 'id = null'),
                      // Конец удалить потом
                      const Text("Введите код", style: TextStyle(
                          fontSize: 22,
                          fontFamily: "SNPro",
                          fontWeight: FontWeight.w600
                      ),),
                      const Text("Код отправлен на ваш номер телефона", style: TextStyle(
                          fontSize: 14,
                          fontFamily: "SNPro",
                          fontWeight: FontWeight.w400
                      )),
                      SizedBox(height: 10,),
                      TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          // counterText: "",
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                        ),
                        cursorColor: const Color(0xFF000000),
                        keyboardType: TextInputType.number,
                        maxLength: 6, // Устанавливает лимит в 6 символов
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // Разрешает вводить ТОЛЬКО цифры (никаких точек и запятых)
                        ],
                      ),
                      ElevatedButton(onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF990000),
                        ),
                        child: Text("Отправить", style: TextStyle(
                            fontFamily: "SNPro",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white
                        ),),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),

        )
    );
  }
}



