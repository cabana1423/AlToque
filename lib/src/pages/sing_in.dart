// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gowin/src/pages/Home_Nav.dart';
import 'package:gowin/src/pages/OlvidoContrasenia.dart';
import 'package:gowin/src/pages/configuraciones/QuitarSuspencion.dart';
import 'package:gowin/src/pages/sing_up.dart';
import 'package:gowin/src/pages/gestiones/verificacio.email.dart';
import 'package:gowin/src/utils.pages/loading.dart';
import 'package:gowin/src/utils.pages/toast.notification.dart';
import 'package:gowin/src/utils/constantes.layout.dart';
import 'package:gowin/src/utils/guardar.session.dart';
import 'package:gowin/src/utils/login.dart';
import 'package:gowin/src/utils/variables.dart';
import 'package:http/http.dart' as http;
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// alertr Toast we :)
import 'package:another_flushbar/flushbar.dart';

class SingIn extends StatefulWidget {
  SingIn({Key? key}) : super(key: key);

  @override
  _SingInState createState() => _SingInState();
}

class _SingInState extends State<SingIn> with SingleTickerProviderStateMixin {
  //    text animation
  late AnimationController _animationController;

  void setupAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: defaultDuration);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

//    LOGIN GOGLE WE:)
  // final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  // late GoogleSignInAccount? _currentUser;

  void obtenerZonaHoraria() {
    DateTime dateTime = DateTime.now();
    Constant.shared.zonaHoraria = dateTime.timeZoneName;
    print(Constant.shared.zonaHoraria);
  }

  bool _visible = true;
  @override
  void initState() {
    //this.obtenerZonaHoraria();
    super.initState();
    determinePosition();
    setupAnimation();
    setState(() {
      _visible = false;
    });
    // _googleSignIn.onCurrentUserChanged.listen((account) {
    //   setState(() {
    //     _currentUser = account!;
    //   });
    // });
    // _googleSignIn.signInSilently();
  }

  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();

  FocusNode blankNode = FocusNode();
  Future postLogin() async {
    print('AQUI ESTA EL TOKEN WE ${Constant.shared.tokenFB}');
    String url = "${Constant.shared.urlApi}/users/login";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'email': login.email,
      'password': login.password,
      'tokenFB': Constant.shared.tokenFB,
      //'zonaHoraria': Constant.shared.zonaHoraria,
    });
    if (res.statusCode == 200) {
      Constant.shared.dataUser = jsonDecode(res.body)['res'];
      Constant.shared.listLikes =
          jsonDecode(res.body)['listaLike']['listaLikes'];
      Constant.shared.interacciones =
          jsonDecode(res.body)['listaLike']['interacciones'];
      Constant.shared.token = jsonDecode(res.body)['tokens']['token'];
      Constant.shared.refreshToken =
          jsonDecode(res.body)['tokens']['refreshToken'];
      //guardar datos en storage
      await UserSecureStorages.setEmail(login.email);
      await UserSecureStorages.setId(jsonDecode(res.body)['res']['_id']);
      await UserSecureStorages.setTokenFB(Constant.shared.tokenFB);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeNav(enlace: '', prod: '')));
      // Navigator.of(context).pushReplacementNamed('/Home_Nav');
      FocusScope.of(context).unfocus();
      ToastNotification.toastNotificationSucces(
          jsonDecode(res.body)['msn'].toString(), context);
      //toast_notification(jsonDecode(res.body)['msn']);
    } else if (res.statusCode == 404) {
      ToastNotification.toastNotificationError(
          'Error al conectarse al servidor', context);
      return;
    } else if (jsonDecode(res.body)['msn'] == 'noExiste') {
      ToastNotification.toastNotificationError(
          'Credenciales Incorrectas', context);
    } else {
      if (jsonDecode(res.body)['res']['estado'] == 'suspendido') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuitarSuspencion(
                      data: jsonDecode(res.body),
                      onpressed: postLogin,
                    )));
        return;
      }
      if (jsonDecode(res.body)['res']['estado'] == 'bloqueado') {
        return;
      }
      emailNoVerificada(jsonDecode(res.body)['res']);
    }
  }

  Future post_social(nombre, email, img, password) async {
    log('entro a post google');
    var url = "${Constant.shared.urlApi}/users";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'nombre': nombre,
      'email': email,
      'password': password,
      'url_img': img,
      'estado': "verificada",
      'long': Constant.shared.mylong.toString(),
      'lat': Constant.shared.mylat.toString(),
    });
    if (res.statusCode == 200) {
      login.email = email;
      login.password = password;
      postLogin();
    } else if (res.statusCode == 404) {
      ToastNotification.toastNotificationError(
          'Error al conectarse al servidor', context);
      return;
    } else {
      ToastNotification.toastNotificationError(
          jsonDecode(res.body)['msn'], context);
      // ToastNotification.toastPeque(jsonDecode(res.body)['msn'], context);
    }
  }

  //    VARIABLES
  Login login = Login('', '');
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return loading == true
        ? const Loadings()
        : Scaffold(
            body: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return Stack(children: [
                    SvgPicture.asset('images/login2.svg', fit: BoxFit.fill),
                    Container(
                      // decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //   opacity: 0.9,
                      //   fit: BoxFit.fitHeight,
                      //   image: AssetImage('images/login2.png'),
                      // )),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.06,
                        ),
                        child: Form(
                          key: _formkey,
                          child: ListView(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SlideInDown(
                                    duration:
                                        const Duration(milliseconds: 2500),
                                    child: Image.asset(
                                      'images/loginLogo.png',
                                      width: 200,
                                      height: 230,
                                    ),
                                  ),
                                  _textFormEmail(),
                                  _textFormPass(),
                                  recordarContrasena(),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      height: 50,
                                      width: 400,
                                      //botton signIn
                                      // ignore: deprecated_member_use
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 52, 184, 184),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0)),
                                        ),
                                        onPressed: () {
                                          if (_formkey.currentState!
                                              .validate()) {
                                            print('ok :)');
                                            postLogin();
                                          }
                                        },
                                        child: const Text("Iniciar Sesion",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    child: Container(
                                      height: 50,
                                      width: 400,
                                      //botton signIn
                                      // ignore: deprecated_member_use
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 240, 240, 240),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0)),
                                        ),
                                        onPressed: () async {
                                          // googleSignIn();
                                          await signInWithGoogle();
                                          log('termino la funcion');
                                          if (googleLoginEmail != '' &&
                                              googleLoginData != null) {
                                            socialLogin(googleLoginEmail,
                                                googleLoginData, "google");
                                            // log('entro despues de la funcion');
                                          } else {
                                            ToastNotification
                                                .toastNotificationError(
                                                    'Error al obtener los datos',
                                                    context);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text("Iniciar con Google    ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color.fromARGB(
                                                        255, 32, 32, 32),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Image.asset(
                                              'images/google.png',
                                              width: 32,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text('No tienes una cuenta? '),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SingUp(
                                                            long: Constant
                                                                .shared.mylong,
                                                            lat: Constant
                                                                .shared.mylat,
                                                          )));
                                            },
                                            child: const Text(
                                              'Crea una',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 186, 97, 254)),
                                            )),
                                      ],
                                    ),
                                  ),
                                  // const SizedBox(
                                  //   height: 40,
                                  // ),
                                  // const Text('O inicia con..'),
                                  // //    boton logins
                                  // Center(
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.center,
                                  //     children: [
                                  //       // IconButton(
                                  //       //   onPressed: () {
                                  //       //     _facebook_login();
                                  //       //   },
                                  //       //   icon: const Icon(EvaIcons.facebook),
                                  //       // ),
                                  //       IconButton(
                                  //         onPressed: () async {
                                  //           // googleSignIn();
                                  //           await signInWithGoogle();
                                  //           log('termino la funcion');
                                  //           if (googleLoginEmail != '' &&
                                  //               googleLoginData != null) {
                                  //             socialLogin(googleLoginEmail,
                                  //                 googleLoginData, "google");
                                  //             // log('entro despues de la funcion');
                                  //           } else {
                                  //             ToastNotification
                                  //                 .toastNotificationError(
                                  //                     'Error al obtener los datos',
                                  //                     context);
                                  //           }
                                  //         },
                                  //         icon: const Icon(EvaIcons.google),
                                  //       ),
                                  //       // IconButton(
                                  //       //   onPressed: () {
                                  //       //     signOut();
                                  //       //   },
                                  //       //   icon: Icon(EvaIcons.close),
                                  //       // ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]);
                }),
          );
  }

  Widget recordarContrasena() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OlvidoContrasenia()));
            },
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                  color: Color.fromARGB(255, 186, 97, 254), fontSize: 15),
            )),
      ],
    );
  }

  // Future<void> googleSignIn() async {
  //   setState(() {
  //     loading = true;
  //   });
  //   try {
  //     await _googleSignIn.signIn().then((value) {
  //       log('$value que pasooo');
  //       GoogleSignInAccount? user = value;
  //       socialLogin(user!.email, user, "google");
  //       // print(user);
  //     });
  //   } catch (e) {
  //     setState(() {
  //       loading = false;
  //     });
  //     print('error we pooor que $e');
  //   }
  // }

  var googleLoginEmail = '';
  var googleLoginData;
  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      googleLoginEmail = gUser.email;
      googleLoginData = gUser;
      // log('${gUser.displayName}');
      // GoogleSignIn().signOut();
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log(e.toString());
    }
  }

  void signOut() {
    // _googleSignIn.disconnect();
    GoogleSignIn().signOut();
  }

  void _facebook_login() {
    FacebookAuth.instance
        .login(permissions: ["public_profile", "email"]).then((value) {
      FacebookAuth.instance.getUserData().then((userData) {
        socialLogin(userData["email"], userData, "facebook");
        print(userData);
      });
    });
  }

  Future socialLogin(email, data, tipo) async {
    String url =
        '${Constant.shared.urlApi + "/users/social_login?email=" + email}&tkFB=${Constant.shared.tokenFB}';
    // +
    // '&zt=' +
    // Constant.shared.zonaHoraria;
    var res = await http.get(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    });
    if (res.statusCode == 200) {
      setState(() {
        loading = false;
      });
      if (jsonDecode(res.body)['res']['estado'] == "verificada") {
        Constant.shared.dataUser = jsonDecode(res.body)['res'];
        Constant.shared.listLikes =
            jsonDecode(res.body)['listaLike']['listaLikes'];
        Constant.shared.interacciones =
            jsonDecode(res.body)['listaLike']['interacciones'];
        Constant.shared.token = jsonDecode(res.body)['tokens']['token'];
        Constant.shared.refreshToken =
            jsonDecode(res.body)['tokens']['refreshToken'];
        //valores
        await UserSecureStorages.setEmail(jsonDecode(res.body)['res']['email']);
        await UserSecureStorages.setId(jsonDecode(res.body)['res']['_id']);
        await UserSecureStorages.setTokenFB(Constant.shared.tokenFB);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeNav(enlace: '', prod: '')));

        // Navigator.of(context).pushReplacementNamed('/Home_Nav');
        ToastNotification.toastNotificationSucces(
            jsonDecode(res.body)['msn'].toString(), context);
      } else {
        if (jsonDecode(res.body)['res']['estado'] == 'suspendido') {
          setState(() {
            loading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuitarSuspencion(
                        data: jsonDecode(res.body),
                        onpressed: atras,
                      )));
          return;
        }
        if (jsonDecode(res.body)['res']['estado'] == 'bloqueado') {
          setState(() {
            loading = false;
          });
          return;
        }
        setState(() {
          loading = false;
        });
        emailNoVerificada(jsonDecode(res.body)['res']);
      }
    } else if (res.statusCode == 404) {
      ToastNotification.toastNotificationError(
          'Error al conectarse al servidor', context);
      return;
    } else {
      if (tipo == "google") {
        // _sendDatos_go_fb(data.displayName, data.email, data.photoUrl);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Singingoogle(
                      nombre: data.displayName,
                      email: data.email,
                      img: data.photoUrl,
                      onPressed: post_social,
                    )));
      } else {
        _sendDatos_go_fb(
            data['name'], data['email'], data['picture']['data']['url']);
      }
    }
    setState(() {
      loading = false;
    });
  }

  void atras() {
    Navigator.pop(context);
  }

  void _sendDatos_go_fb(nombre, email, img) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (_) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              scrollable: true,
              content: Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(163, 178, 151, 250)
                        .withOpacity(0.5)),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: CircleAvatar(
                            minRadius: 35,
                            maxRadius: 50,
                            backgroundImage: NetworkImage(img),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(email),
                        const SizedBox(height: 5),
                        Text(
                          nombre,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSerif(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                letterSpacing: .5,
                                fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                                '🙂 Por favor, elige una contraseña segura para completar la creación de tu cuenta... 🔒',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.aBeeZee(
                                    fontSize: 12, color: Colors.black)),
                          ),
                        ),
                        Form(
                            key: _formkey2,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: TextFormField(
                                    controller: TextEditingController(
                                        text: passnewText1),
                                    onChanged: (value) {
                                      passnewText1 = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Los campos estan vacios';
                                      }
                                      return null;
                                    },
                                    obscureText: passnew1,
                                    decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        labelStyle: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                        hintText: 'Contraseña',
                                        hintStyle: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(0, 184, 18, 18),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(78, 30, 70, 91),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                            106, 12, 43, 61),
                                        contentPadding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(20, 24, 20, 24),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                passnew1 = !passnew1;
                                              });
                                            },
                                            icon: passnew1 == true
                                                ? const Icon(Icons
                                                    .remove_red_eye_outlined)
                                                : const Icon(
                                                    Icons.remove_red_eye))),
                                    style: null,
                                  ),
                                ),
                                //    PASSNEW -->2
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: TextFormField(
                                    controller: TextEditingController(
                                        text: passnewText2),
                                    onChanged: (value) {
                                      passnewText2 = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Los campos estan vacios';
                                      } else if (value != passnewText1) {
                                        return 'las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                    obscureText: passnew2,
                                    decoration: InputDecoration(
                                        labelText: 'Repita Contraseña',
                                        labelStyle: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                        hintText: 'Repita Contraseña',
                                        hintStyle: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(0, 184, 18, 18),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(78, 30, 70, 91),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                            106, 12, 43, 61),
                                        contentPadding:
                                            const EdgeInsetsDirectional
                                                .fromSTEB(20, 24, 20, 24),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                passnew2 = !passnew2;
                                              });
                                            },
                                            icon: passnew2 == true
                                                ? const Icon(Icons
                                                    .remove_red_eye_outlined)
                                                : const Icon(Icons
                                                    .remove_red_eye_rounded))),
                                    style: null,
                                  ),
                                ),
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                          child: Container(
                            height: 45,
                            width: 300,
                            //botton signIn
                            // ignore: deprecated_member_use
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 52, 184, 184),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0)),
                              ),
                              onPressed: () {
                                if (_formkey2.currentState!.validate()) {
                                  post_social(nombre, email, img, passnewText1);
                                }
                              },
                              child: const Text("Iniciar",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        )
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(16, 5, 16, 15),
                        //   child: Container(
                        //     height: 45,
                        //     width: 300,
                        //     //botton signIn
                        //     // ignore: deprecated_member_use
                        //     child: ElevatedButton(
                        //       style: ElevatedButton.styleFrom(
                        //         backgroundColor:
                        //             const Color.fromARGB(255, 255, 96, 96),
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(16.0)),
                        //       ),
                        //       onPressed: () {
                        //         signOut();
                        //         Navigator.pop(context);
                        //       },
                        //       child: const Text("Cancelar",
                        //           style: TextStyle(color: Colors.white)),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }));
        });
  }

  void emailNoVerificada(usuario) {
    final _size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            scrollable: false,
            content: Container(
              height: _size.height * 0.3,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(163, 178, 151, 250)
                      .withOpacity(0.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Su cuenta aún no esta verificada...',
                    style: GoogleFonts.alikeAngular(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Verifique su cuenta ',
                    style: GoogleFonts.alikeAngular(
                      fontSize: 17,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      renviarCodigo(usuario);
                      Navigator.pop(context);
                      // FocusScope.of(context).requestFocus(blankNode);
                    },
                    child: Text(
                      'aquí',
                      style: GoogleFonts.alikeAngular(
                        color: const Color.fromARGB(255, 74, 167, 244),
                        fontSize: 17,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future renviarCodigo(usuario) async {
    var url = "${Constant.shared.urlApi}/users/reverifi";
    var res = await http.post(Uri.parse(url), headers: <String, String>{
      'Context-Type': 'application/json;charSet=UTF-8'
    }, body: <String, String>{
      'nombre': usuario['nombre'],
      'email': usuario['email'],
      'id': usuario['_id'],
    });
    if (res.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerificarEmail(idUser: usuario, page: "login")));
    }
  }

  toastNotification(mensaje) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      boxShadows: const [
        BoxShadow(
            color: Color.fromARGB(255, 228, 93, 15),
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      backgroundGradient: const LinearGradient(colors: [
        Color.fromARGB(216, 96, 125, 139),
        Color.fromARGB(164, 0, 0, 0)
      ]),
      isDismissible: false,
      duration: const Duration(seconds: 1),
      icon: const Icon(
        Icons.error,
        size: 40,
        color: Color.fromARGB(255, 238, 63, 40),
      ),
      //showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.blueGrey,
      titleText: const Text(
        "ERROR",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Color.fromARGB(255, 226, 114, 23),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        mensaje,
        style: const TextStyle(
            fontSize: 18.0,
            color: Color.fromARGB(255, 202, 127, 15),
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }

  void showSnacks(String texto) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(texto),
          duration: const Duration(milliseconds: 1500),
        ),
      );

  Widget _textFormEmail() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        style: const TextStyle(color: Color.fromARGB(255, 163, 250, 182)),
        controller:
            TextEditingController(text: /*'vedia@gmail.com'*/ login.email),
        onChanged: (value) {
          login.email = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Eroor en los datos';
          } else if (RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[aa-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return null;
          } else {
            return 'Ingrese un email válido';
          }
        },
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle:
              const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          hintText: 'Ingrese su email...',
          hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(0, 184, 18, 18),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(78, 30, 70, 91),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: const Color.fromARGB(106, 12, 43, 61),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
        ),
      ),
    );
  }

  var myTextEditingController = TextEditingController();
  bool passView = true;
  Widget _textFormPass() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
      child: TextFormField(
        style: const TextStyle(color: Color.fromARGB(255, 163, 250, 182)),
        controller: TextEditingController(text: /*"Hola1234"*/ login.password),
        onChanged: (value) {
          login.password = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Error en los datos';
          } else
            return null;
        },
        obscureText: passView,
        decoration: InputDecoration(
            labelText: 'contraseña',
            labelStyle:
                const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            hintText: 'ingrese su contraseña...',
            hintStyle:
                const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(0, 184, 18, 18),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(78, 30, 70, 91),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: const Color.fromARGB(106, 12, 43, 61),
            contentPadding:
                const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    passView = !passView;
                  });
                },
                icon: passView == true
                    ? const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Color.fromARGB(255, 66, 60, 67),
                        size: 30,
                      )
                    : const Icon(
                        Icons.remove_red_eye_rounded,
                        color: Color.fromARGB(255, 227, 66, 255),
                        size: 30,
                      ))),
      ),
    );
  }

  bool passView2 = true;

  void determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var position =
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position position2) {
      Constant.shared.mylat = position2.latitude;
      Constant.shared.mylong = position2.longitude;
    });
  }

  String passnewText1 = '';
  String passnewText2 = '';
  bool passnew1 = true;
  bool passnew2 = true;
}

class Singingoogle extends StatefulWidget {
  var img;

  var nombre;

  var email;
  final void Function(String, String, String, String) onPressed;

  Singingoogle(
      {super.key,
      required this.nombre,
      required this.email,
      required this.img,
      required this.onPressed});

  @override
  State<Singingoogle> createState() => _SingingoogleState();
}

class _SingingoogleState extends State<Singingoogle> {
  final _formkey2 = GlobalKey<FormState>();

  String passnewText1 = '';

  String passnewText2 = '';

  bool passnew1 = true;

  bool passnew2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 197, 176, 255).withOpacity(0.5)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      minRadius: 35,
                      maxRadius: 50,
                      backgroundImage: NetworkImage(widget.img),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(widget.email),
                  const SizedBox(height: 5),
                  Text(
                    widget.nombre,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerif(
                      textStyle: const TextStyle(
                          color: Colors.black, letterSpacing: .5, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                          '🙂 Por favor, elige una contraseña segura para completar la creación de tu cuenta... 🔒',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.aBeeZee(
                              fontSize: 12, color: Colors.black)),
                    ),
                  ),
                  Form(
                      key: _formkey2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextFormField(
                              controller:
                                  TextEditingController(text: passnewText1),
                              onChanged: (value) {
                                passnewText1 = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Los campos estan vacios';
                                }
                                return null;
                              },
                              obscureText: passnew1,
                              decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  labelStyle: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  hintText: 'Contraseña',
                                  hintStyle: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(0, 184, 18, 18),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(78, 30, 70, 91),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(106, 12, 43, 61),
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20, 24, 20, 24),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passnew1 = !passnew1;
                                        });
                                      },
                                      icon: passnew1 == true
                                          ? const Icon(
                                              Icons.remove_red_eye_outlined)
                                          : const Icon(Icons.remove_red_eye))),
                              style: null,
                            ),
                          ),
                          //    PASSNEW -->2
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextFormField(
                              controller:
                                  TextEditingController(text: passnewText2),
                              onChanged: (value) {
                                passnewText2 = value;
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Los campos estan vacios';
                                } else if (value != passnewText1) {
                                  return 'las contraseñas no coinciden';
                                }
                                return null;
                              },
                              obscureText: passnew2,
                              decoration: InputDecoration(
                                  labelText: 'Repita Contraseña',
                                  labelStyle: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  hintText: 'Repita Contraseña',
                                  hintStyle: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(0, 184, 18, 18),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color.fromARGB(78, 30, 70, 91),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(106, 12, 43, 61),
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          20, 24, 20, 24),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passnew2 = !passnew2;
                                        });
                                      },
                                      icon: passnew2 == true
                                          ? const Icon(
                                              Icons.remove_red_eye_outlined)
                                          : const Icon(
                                              Icons.remove_red_eye_rounded))),
                              style: null,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                    child: Container(
                      height: 45,
                      width: 300,
                      //botton signIn
                      // ignore: deprecated_member_use
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 52, 184, 184),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                        ),
                        onPressed: () {
                          if (_formkey2.currentState!.validate()) {
                            widget.onPressed(widget.nombre, widget.email,
                                widget.img, passnewText1);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Registrar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 5,
                  // ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                    child: Container(
                      height: 45,
                      width: 300,
                      //botton signIn
                      // ignore: deprecated_member_use
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 231, 76, 37),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                        ),
                        onPressed: () {
                          GoogleSignIn().signOut();
                          Navigator.pop(context);
                        },
                        child: const Text("Cancelar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
