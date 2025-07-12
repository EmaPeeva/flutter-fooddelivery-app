import 'package:flutter/material.dart';

class AppWidget {
  // Header style function
  static TextStyle headerStyle() {
    return const TextStyle(
      color: Color.fromARGB(255, 178, 50, 50), 
      fontFamily: 'Oswald',  
      fontSize: 45,  
      fontWeight: FontWeight.bold, 
    );
  } 

   static TextStyle containerStyle() { 
    return const TextStyle(
      color: Color.fromARGB(255, 160, 74, 74), 
      fontFamily: 'Meie_Script',   
      fontSize: 40,  
      fontWeight: FontWeight.bold, 
      
    );
  } 

  static TextStyle ContainerStyle2() { 
    return const TextStyle(
      color: Color.fromARGB(255, 160, 74, 74), 
      fontFamily: 'red-hat-mono',   
      fontSize: 18,     
      fontWeight: FontWeight.bold,  
      
    );

  } 

  static TextStyle ContainerStyle3() { 
    return const TextStyle(
      color: Colors.white,
      fontFamily: 'red-hat-mono',   
      fontSize: 18,     
      fontWeight: FontWeight.bold,  
      
    );
}

 static TextStyle boldTextFeildStyle(){
  return TextStyle(
    color:Colors.black,fontSize: 20.0,fontWeight: FontWeight.bold
  );
 }

 static TextStyle priceTextFeildStyle(){
  return TextStyle(
    color:Colors.black38,fontSize: 24.0,fontWeight: FontWeight.bold
  );
 }

}