import 'package:fooddelivery_app/model/pizza_model.dart';

List<PizzaModel> getPizza(){
  List<PizzaModel> pizza=[]; //pizza category
  PizzaModel pizzaModel=new PizzaModel();

  pizzaModel.name="Pizza";
  pizzaModel.image="images/pizza1.png";   
  pizzaModel.star=4.3;
  pizzaModel.time="35min"; 
  pizzaModel.price="50";
  pizzaModel.description="A classic Italian dish with a crispy crust, rich tomato sauce, melted mozzarella cheese, and a variety of fresh toppings. Perfectly baked for a golden finish and irresistible flavor.";
  pizzaModel.isVegan=false;  
  pizza.add(pizzaModel);
  pizzaModel=new PizzaModel();

  
  pizzaModel.name=" Veggie Pizza";
  pizzaModel.image="images/pizza2.png"; 
    pizzaModel.star=4.3;
  pizzaModel.time="30 min"; 
  pizzaModel.price="30"; 
  pizzaModel.description="A classic Italian dish with a crispy crust, rich tomato sauce, melted mozzarella cheese, and a variety of fresh toppings. Perfectly baked for a golden finish and irresistible flavor.";
  pizzaModel.isVegan=true;  
  pizza.add(pizzaModel);
  pizzaModel=new PizzaModel();

  pizzaModel.name=" Pizza";
  pizzaModel.image="images/pizza1.png"; 
    pizzaModel.star=4.3;
  pizzaModel.time="20 min";
  pizzaModel.price="30"; 
  pizzaModel.description="A classic Italian dish with a crispy crust, rich tomato sauce, melted mozzarella cheese, and a variety of fresh toppings. Perfectly baked for a golden finish and irresistible flavor.";
  pizzaModel.isVegan=false;  
  pizza.add(pizzaModel);
  pizzaModel=new PizzaModel();
  
   pizzaModel.name=" Veggie Pizza";
  pizzaModel.image="images/pizza2.png"; 
    pizzaModel.star=4.3;
  pizzaModel.time="20 min";
  pizzaModel.price="30"; 
  pizzaModel.description="A classic Italian dish with a crispy crust, rich tomato sauce, melted mozzarella cheese, and a variety of fresh toppings. Perfectly baked for a golden finish and irresistible flavor.";
  pizzaModel.isVegan=true;  
  pizza.add(pizzaModel);
  pizzaModel=new PizzaModel();


 pizzaModel.name="Pizza";
  pizzaModel.image="images/pizza1.png"; 
   pizzaModel.star=4.3;
  pizzaModel.time="20 min";
  pizzaModel.price="30"; 
  pizzaModel.description="A classic Italian dish with a crispy crust, rich tomato sauce, melted mozzarella cheese, and a variety of fresh toppings. Perfectly baked for a golden finish and irresistible flavor.";
  pizzaModel.isVegan=false;  
  pizza.add(pizzaModel);
  pizzaModel=new PizzaModel();



 pizzaModel.name=" Veggie Pizza";
  pizzaModel.image="images/pizza2.png"; 
    pizzaModel.star=4.3; 
  pizzaModel.time="20 min";
  pizzaModel.price="30"; 
  pizzaModel.description="A classic Italian dish with a crispy crust, rich tomato sauce, melted mozzarella cheese, and a variety of fresh toppings. Perfectly baked for a golden finish and irresistible flavor.";
  pizzaModel.isVegan=true;   
  pizza.add(pizzaModel);
  pizzaModel=new PizzaModel();  


  

 
 
 return pizza; 

}