import 'package:flutter/material.dart';

class Loadings extends StatelessWidget {
  const Loadings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'images/logo.png',
            width: 150,
            height: 150,
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              backgroundColor: Colors.purple,
            ),
          )
        ],
      ),
    );
  }
}
