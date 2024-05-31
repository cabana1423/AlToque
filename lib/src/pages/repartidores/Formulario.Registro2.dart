// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/variables.dart';
// import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ReaprtidorFormulario2 extends StatefulWidget {
  const ReaprtidorFormulario2({Key? key}) : super(key: key);

  @override
  State<ReaprtidorFormulario2> createState() => _ReaprtidorFormulario2State();
}

class _ReaprtidorFormulario2State extends State<ReaprtidorFormulario2> {
  // final List<Asset?> _images = List.generate(8, (_) => null);
  final ImagePicker _imagePicker = ImagePicker();
  final List<File?> multiimages = List.generate(8, (_) => null);
  multiimagePicker(index) async {
    final XFile? pickeimage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickeimage != null) {
      multiimages[index] = File(pickeimage.path);
      // multiimages.add(File(element.path));
      log(pickeimage.path.toString());

      setState(() {});
    }
  }

  String error = '';

  // Future<void> _loadAssets(index) async {
  //   List<Asset> resultList = <Asset>[];
  //   try {
  //     resultList = await MultiImagePicker.pickImages(
  //       maxImages: 1,
  //       enableCamera: true,
  //     );
  //   } on Exception catch (e) {
  //     log(e.toString());
  //     error = e.toString();
  //   }
  //   if (!mounted) return;

  //   setState(() {
  //     if (resultList.isNotEmpty) {
  //       _images[index] = resultList[0];
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: carga == true
          ? carga_()
          : Scaffold(
              body: Container(
              alignment: Alignment.center,
              child: cuerpo(context),
            )),
    );
  }

  Widget carga_() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Enviando Solicitud'),
          SizedBox(
            height: 11,
          ),
          CircularProgressIndicator()
        ],
      ),
    );
  }

  Widget cuerpo(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: parrafoInformmativo(),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: matriz(),
          )),
          boton(context)
        ],
      ),
    );
  }

  Widget matriz() {
    return StaggeredGridView.countBuilder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      staggeredTileBuilder: (int index) => const StaggeredTile.count(1, 0.8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: 8,
      itemBuilder: (BuildContext context, int index) =>
          _buildImageContainer(index),
    );
  }

  Widget _buildImageContainer(int index) {
    return GestureDetector(
      onTap: () => multiimagePicker(index),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 233, 233, 233),
          image: multiimages[index] != null
              ? DecorationImage(image: FileImage(multiimages[index]!))
              : null,
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: texto(index),
            ),
            Align(
                alignment: Alignment.center,
                child: Icon(
                  multiimages[index] != null
                      ? Icons.autorenew
                      : Icons.add_photo_alternate,
                  color: const Color.fromARGB(255, 190, 190, 190),
                  size: 50,
                ))
          ],
        ),
      ),
    );
  }

  texto(valor) {
    return Stack(
      children: [
        Text(
          textTipo(valor),
          textAlign: TextAlign.center,
          style: GoogleFonts.amaranth(
            fontSize: 18,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = const Color.fromARGB(255, 57, 57, 57),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Text(
          textTipo(valor),
          textAlign: TextAlign.center,
          style: GoogleFonts.amaranth(
            fontSize: 18,
            color: const Color.fromARGB(255, 205, 242, 242),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  String textTipo(val) {
    const map = {
      0: 'Foto conductor',
      1: 'cedula de identidad frontal',
      2: 'cedula de identidad reverso',
      3: 'NIT',
      4: 'Licencia',
      5: 'Soat',
      6: 'Placa vehiculo',
      7: 'Foto Vehiculo'
    };
    return map[val] ?? 'N/A';
  }

  final futures = <Future>[];
  List datosImg = [];
  Future<void> uploadImagesToS3() async {
    const accessKey = 'AKIAT7B3USE2DARGPK5A';
    const secretKey = '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';
    const bucketName = 'usuarios-files';
    const region = 'us-east-2';

    final s3 = S3(
        region: region,
        credentials:
            AwsClientCredentials(accessKey: accessKey, secretKey: secretKey));
    int index = 0;
    for (final image in multiimages) {
      if (image != null) {
        final key = DateTime.now().millisecondsSinceEpoch.toString();
        final file = await image.readAsBytes();
        final path = '$key.jpg';
        var dato = {
          'tipo': textTipo(index),
          'url': 'https://usuarios-files.s3.us-east-2.amazonaws.com/$path',
          'key': path
        };
        Future.delayed(Duration.zero, () {
          datosImg.add(dato);
          futures.add(s3.putObject(
            bucket: bucketName,
            key: path,
            body: file.buffer.asUint8List(),
          ));
        });
      }
      index++;
    }
    await Future.wait(futures).then((value) => update(datosImg)).onError((error,
            stackTrace) =>
        ToastNotification.toastPeque('Error al cargar las imagenes', context));
    // setState(() {
    //   _images.clear();
    // });
  }

  bool carga = false;
  Widget boton(contexts) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 3),
      child: SizedBox(
        height: 50,
        width: 400,
        // ignore: deprecated_member_use
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 52, 184, 184),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
          ),
          onPressed: () {
            log(multiimages.every((element) => element != null).toString());
            if (multiimages.every((element) => element != null)) {
              ToastNotification.toastPeque(
                  'Su solicitud se esta enviando, le avisaremos cuando este lista',
                  context);
              setState(() {
                carga = true;
              });
              uploadImagesToS3();
            } else {
              ToastNotification.toastNotificationError(
                  'Formulario incompleto, intente de nuevo despues de revisar',
                  context);
              setState(() {
                carga = false;
              });
            }
          },
          child: const Text("Enviar", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Future<String> update(datos) async {
    // log('ESAMOS EN PUT');
    String url =
        "${Constant.shared.urlApi}/users/?id=${Constant.shared.dataUser['_id']}";
    var res = await http.put(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'documentos': json.encode(datos)
    });
    setState(() {
      carga = false;
    });
    if (res.statusCode == 200) {
      // actualizarDatosUser();
      // Navigator.of(context).pushAndRemoveUntil(
      //   CupertinoPageRoute(
      //     builder: (BuildContext context) {
      //       return Perfil();
      //     },
      //   ),
      //   (_) => false,
      // );
      Navigator.pop(context);
      Navigator.pop(context);
      ToastNotification.toastNotificationSucces(
          json.decode(res.body)['msn'].toString(), context);
      return 'success';
    } else {
      ToastNotification.toastNotificationError(
          json.decode(res.body)['msn'].toString(), context);
      return 'fail';
    }
  }

  // actualizarDatosUser() async {
  //   var url =
  //       "${Constant.shared.urlApi}/users/id?id=${Constant.shared.dataUser['id']}";
  //   var response =
  //       await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
  //   if (response.statusCode == 200) {
  //     Constant.shared.dataUser = json.decode(response.body);
  //   }
  // }

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Importante!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Por favor, asegúrate de cargar imagenes de tus documentos reales para procesar tu solicitud correctamente, cabe mencionar que el proceso de verificacion se realizara con los documentos fisicos.',
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
