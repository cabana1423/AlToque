import 'package:flutter/material.dart';

class EnEsperaSolicitud extends StatelessWidget {
  const EnEsperaSolicitud({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: cuerpo(),
      ),
    );
  }

  Widget cuerpo() {
    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: parrafoInformmativo(),
            ),
            Image.asset('images/moto.gif'),
          ],
        ),
      ],
    );
  }

  Widget parrafoInformmativo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          width: 1.0,
          color: const Color.fromARGB(255, 224, 224, 224),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '¡Felicidades estas a poco de formar parte de nuestro equipo! 😊',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Nos complace informarle que su registro se ha completado con éxito. Sin embargo, tendrá que presentar sus documentos originales para la verificación de la información que proporcionó en el formulario. El proceso de verificación es crucial para garantizar que toda la información sea precisa y esté actualizada. Por lo tanto, le pedimos que se apersone a nuestras oficinas con los documentos originales necesarios para el proceso de verificación. Una vez que el proceso esté completo y se haya confirmado que toda la información es correcta, podrá recibir su uniforme y equipo de inmediato. Agradecemos su cooperación y comprensión en este asunto y esperamos poder atenderlo pronto en nuestras oficinas.',
            style: TextStyle(
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
