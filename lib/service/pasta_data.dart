import 'package:fooddelivery_app/model/pasta_model.dart';

List<PastaModel> getPasta(){
List<PastaModel> pasta=[]; //pizza category
PastaModel pastaModel=new PastaModel(); 

  pastaModel.name="Pasta";
  pastaModel.image="images/pastaa.jpg";   
  pastaModel.star=4.3;
  pastaModel.time="35min"; 
  pastaModel.price="50";
   pastaModel.description="A hearty and comforting Italian favorite made with perfectly cooked noodles, savory sauces like marinara or Alfredo, and your choice of vegetables, herbs, or proteins.";
 pastaModel.isVegan=false;  
  pasta.add(pastaModel);
  pastaModel=new PastaModel();


pastaModel.name="Veggie Pasta";
  pastaModel.image="images/veggiepasta.jpg";    
   pastaModel.star=4.3;
  pastaModel.time="35min"; 
  pastaModel.price="50";
   pastaModel.description="A hearty and comforting Italian favorite made with perfectly cooked noodles, savory sauces like marinara or Alfredo, and your choice of vegetables, herbs, or proteins.";
  pastaModel.isVegan=true;  
  pasta.add(pastaModel);
  pastaModel=new PastaModel();


  pastaModel.name="Pasta";
  pastaModel.image="images/pastaa.jpg";   
  pastaModel.star=4.3;
  pastaModel.time="35min"; 
  pastaModel.price="50";
   pastaModel.description="A hearty and comforting Italian favorite made with perfectly cooked noodles, savory sauces like marinara or Alfredo, and your choice of vegetables, herbs, or proteins.";
 pastaModel.isVegan=false;  
  pasta.add(pastaModel);
  pastaModel=new PastaModel();

  pastaModel.name=" Veggie Pasta";
  pastaModel.image="images/veggiepasta.jpg";   
   pastaModel.star=4.3;
  pastaModel.time="35min"; 
  pastaModel.price="50";
   pastaModel.description="A hearty and comforting Italian favorite made with perfectly cooked noodles, savory sauces like marinara or Alfredo, and your choice of vegetables, herbs, or proteins.";
  pastaModel.isVegan=true;  
  pasta.add(pastaModel);
  pastaModel=new PastaModel();


pastaModel.name="Pasta";
  pastaModel.image="images/pastaa.jpg";   
   pastaModel.star=4.3;
  pastaModel.time="35min"; 
  pastaModel.price="50";
  pastaModel.description="A hearty and comforting Italian favorite made with perfectly cooked noodles, savory sauces like marinara or Alfredo, and your choice of vegetables, herbs, or proteins.";
  pastaModel.isVegan=false; 
  pasta.add(pastaModel);
  pastaModel=new PastaModel();


pastaModel.name="Veggie Pasta";
  pastaModel.image="images/veggiepasta.jpg";    
 pastaModel.star=4.3;
  pastaModel.time="35min"; 
  pastaModel.price="50";
   pastaModel.description="A hearty and comforting Italian favorite made with perfectly cooked noodles, savory sauces like marinara or Alfredo, and your choice of vegetables, herbs, or proteins.";
  pastaModel.isVegan=true; 
  pasta.add(pastaModel);
  pastaModel=new PastaModel(); 



  
 
  

 
 
 return pasta; 

}