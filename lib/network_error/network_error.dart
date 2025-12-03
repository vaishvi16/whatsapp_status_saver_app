import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NetworkError extends StatefulWidget {
  const NetworkError({super.key});

  @override
  State<NetworkError> createState() => _NetworkErrorState();
}

class _NetworkErrorState extends State<NetworkError> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset("assets/network_error.json"),
          Text("Oops!! Check your Internet.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23),),
          Text("Try Again later!!",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),)
        ],
      ),),
    );
  }
}
