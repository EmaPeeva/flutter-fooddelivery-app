import 'package:fooddelivery_app/model/burger_model.dart';

List<BurgerModel> getBurger(){
  List<BurgerModel> burger=[]; //pizza category
  BurgerModel burgerModel=new BurgerModel();

  burgerModel.name="Burger";
  burgerModel.image="images/burger1.png";   
  burgerModel.star=4.3; 
  burgerModel.time="35min"; 
  burgerModel.price="50";
  burgerModel.isVegan=false; 
  burgerModel.description="A delicious plant-based burger made with a juicy chickpea and lentil patty, fresh lettuce, tomatoes, vegan mayo, and a soft whole-grain bun. 100% meat-free, dairy-free, and full of flavor.";
  burger.add(burgerModel);
  burgerModel=new BurgerModel();

  
  burgerModel.name=" Veggie Burger";
  burgerModel.image="images/burger3.png"; 
  burgerModel.star=4.3;
  burgerModel.time="30 min";
  burgerModel.price="30"; 
  burgerModel.isVegan=true; 
  burgerModel.description="A delicious plant-based burger made with a juicy chickpea and lentil patty, fresh lettuce, tomatoes, vegan mayo, and a soft whole-grain bun. 100% meat-free, dairy-free, and full of flavor.";  
  burger.add(burgerModel);
  burgerModel=new BurgerModel();

  burgerModel.name=" Burger";
  burgerModel.image="images/burger1.png";  
  burgerModel.star=4.3;
  burgerModel.time="20 min";
 burgerModel.price="30"; 
 burgerModel.isVegan=false;  
 burgerModel.description="A delicious plant-based burger made with a juicy chickpea and lentil patty, fresh lettuce, tomatoes, vegan mayo, and a soft whole-grain bun. 100% meat-free, dairy-free, and full of flavor.";
  burger.add(burgerModel);
  burgerModel=new BurgerModel();


  burgerModel.name=" Veggie Burger";
  burgerModel.image="images/burger3.png"; 
  burgerModel.star=4.3;
  burgerModel.time="25 min";
  burgerModel.price="30"; 
  burgerModel.isVegan=true; 
  burgerModel.description="A delicious plant-based burger made with a juicy chickpea and lentil patty, fresh lettuce, tomatoes, vegan mayo, and a soft whole-grain bun. 100% meat-free, dairy-free, and full of flavor.";
  burger.add(burgerModel);
  burgerModel=new BurgerModel();

  burgerModel.name=" Burger";
  burgerModel.image="images/burger1.png"; 
  burgerModel.star=4.3;
  burgerModel.time="15 min";
  burgerModel.price="30"; 
 burgerModel.isVegan=false; 
 burgerModel.description="A delicious plant-based burger made with a juicy chickpea and lentil patty, fresh lettuce, tomatoes, vegan mayo, and a soft whole-grain bun. 100% meat-free, dairy-free, and full of flavor.";
  burger.add(burgerModel);
  burgerModel=new BurgerModel();

  burgerModel.name=" Veggie Burger";
  burgerModel.image="images/burger3.png"; 
  burgerModel.star=4.3; 
  burgerModel.time="20 min";
  burgerModel.price="30"; 
  burgerModel.isVegan=true;   
  burgerModel.description="A delicious plant-based burger made with a juicy chickpea and lentil patty, fresh lettuce, tomatoes, vegan mayo, and a soft whole-grain bun. 100% meat-free, dairy-free, and full of flavor.";
  burger.add(burgerModel);
  burgerModel=new BurgerModel();


 
 
 return burger;  

}