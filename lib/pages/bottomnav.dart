import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery_app/pages/home.dart';
import 'package:fooddelivery_app/pages/order.dart';
import 'package:fooddelivery_app/pages/wallet.dart';
import 'package:fooddelivery_app/pages/profile.dart'; 

class BottomNav extends StatefulWidget { 
 
 const BottomNav({super.key});


 @override
  
  State <BottomNav> createState() => _BottomNavState();
  
 
}


class _BottomNavState extends State<BottomNav>{
  late List<Widget> pages;

late Home HomePage;
late Order order;
late ChatPage chat;
late ProfilePage profilePage;

int currentTableIndex=0;

@override
void initState(){

  HomePage=Home();
  order=Order();
 chat=ChatPage();
  profilePage=ProfilePage(); 

  pages=[HomePage,order,chat,profilePage]; //pages list 
  super.initState();

}

@override
  Widget build(BuildContext context){
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        color:const Color.fromARGB(255, 236, 74, 74),
        animationDuration:Duration(milliseconds:500),
        onTap: (int index){
          setState((){
            currentTableIndex=index;
          });
        },
        items:[
          Icon(
            Icons.home,
            color:Colors.white,
            size:30.0,
          ),
          Icon(Icons.shopping_bag,color:Colors.white,size:30.0),
          Icon(Icons.chat,color:Colors.white,size:30.0), 
          Icon(Icons.person,color:Colors.white,size:30.0)
        ]),

body:pages[currentTableIndex],
      );
     
}

}