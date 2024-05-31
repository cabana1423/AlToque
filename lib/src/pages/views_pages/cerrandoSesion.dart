import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/main.dart';
import 'package:gowin/src/pages/sing_in.dart';

class CerrandoSession extends StatefulWidget {
  const CerrandoSession({super.key});

  @override
  State<CerrandoSession> createState() => _CerrandoSessionState();
}

class _CerrandoSessionState extends State<CerrandoSession> {
  @override
  void initState() {
    super.initState();
    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil('/Sing_in', (Route<dynamic> route) => false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
            builder: (BuildContext context) {
              return MyHomePage();
            },
          ),
          (_) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: ShakeY(
        from: 50,
        duration: Duration(seconds: 5),
        infinite: true,
        child: Text(
          'Cerrando Sesion',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));
  }
}
