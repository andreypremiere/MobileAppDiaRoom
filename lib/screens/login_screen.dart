import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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
        // backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: PreferredSize(preferredSize: const Size.fromHeight(0.0),
            child: AppBar(),
          ),
          body: Stack(
              children:
              [
                Positioned(
                    top: 10,
                    right: 10,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/registration');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text('Регистрация',
                        style: TextStyle(
                            fontFamily: 'SNPro',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          color: Colors.black
                        ),),
                    )
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 18,
                            offset: const Offset(0, 0)
                        )]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Войти",
                            style: TextStyle(
                                fontFamily: "SNPro",
                                fontSize: 22,
                                fontWeight: FontWeight.w600
                            )
                        ),

                        const SizedBox(height: 10,),
                        TextField(
                          decoration: InputDecoration(
                            hintText: "user_id или номер телефона",
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          cursorColor: const Color(0xFF000000),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/verifyCode', extra: null);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF990000),
                          ),
                          child: Text("Войти", style: TextStyle(
                              fontFamily: "SNPro",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                          )
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]
          )
      ),
    );
  }
}