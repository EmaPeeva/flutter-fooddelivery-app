import 'package:fooddelivery_app/model/salat_model.dart';

List<SalatModel> getSalat(){
  List<SalatModel> salat=[]; //pizza category 
  SalatModel salatModel=new SalatModel();

  salatModel.name="Salat";
  salatModel.image="images/salat1.png";   
    salatModel.star=4.3; 
  salatModel.time="35min"; 
  salatModel.price="50";
  salatModel.description="A fresh and healthy mix of crisp greens, colorful vegetables, and delicious dressings. Perfect as a light meal or a nutritious side dish.";
  salatModel.isVegan=false;  
  salat.add(salatModel);
  salatModel=new SalatModel();

salatModel.name=" Veggie Salat";
  salatModel.image="images/veggiesalat.jpg";   
    salatModel.star=4.3;
  salatModel.time="35min"; 
  salatModel.price="50";
    salatModel.description="A fresh and healthy mix of crisp greens, colorful vegetables, and delicious dressings. Perfect as a light meal or a nutritious side dish.";
  salatModel.isVegan=true;  
  salat.add(salatModel);
  salatModel=new SalatModel();

  salatModel.name="Salat";
  salatModel.image="images/salat1.png";   
    salatModel.star=4.3;
  salatModel.time="35min"; 
  salatModel.price="50";
    salatModel.description="A fresh and healthy mix of crisp greens, colorful vegetables, and delicious dressings. Perfect as a light meal or a nutritious side dish.";
  salatModel.isVegan=false;
  salat.add(salatModel);
  salatModel=new SalatModel();

salatModel.name="Veggie Salat";
  salatModel.image="images/veggiesalat.jpg";   
    salatModel.star=4.3;
  salatModel.time="35min"; 
  salatModel.price="50";
    salatModel.description="A fresh and healthy mix of crisp greens, colorful vegetables, and delicious dressings. Perfect as a light meal or a nutritious side dish.";
  salatModel.isVegan=true; 
  salat.add(salatModel);
  salatModel=new SalatModel();

salatModel.name="Salat";
  salatModel.image="images/salat1.png";   
    salatModel.star=4.3;
  salatModel.time="35min"; 
  salatModel.price="50";
    salatModel.description="A fresh and healthy mix of crisp greens, colorful vegetables, and delicious dressings. Perfect as a light meal or a nutritious side dish.";
  salatModel.isVegan=false;  
  salat.add(salatModel);
  salatModel=new SalatModel();

salatModel.name="Veggie Salat";
  salatModel.image="images/veggiesalat.jpg";   
  salatModel.star=4.3;
  salatModel.time="35min"; 
  salatModel.price="50";
    salatModel.description="A fresh and healthy mix of crisp greens, colorful vegetables, and delicious dressings. Perfect as a light meal or a nutritious side dish.";
  salatModel.isVegan=true;  
  salat.add(salatModel);
  salatModel=new SalatModel();  

  
 

  

 
 
 return salat;

}