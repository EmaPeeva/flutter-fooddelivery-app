import 'package:fooddelivery_app/model/dessert_model.dart';


List<DessertModel> getDessert(){
  List<DessertModel> dessert=[]; //pizza category 
  DessertModel dessertModel=new DessertModel();

  dessertModel.name=" Veggie Cake";
  dessertModel.image="images/cupcakes.jpg";    
  dessertModel.star=4.3;
  dessertModel.time="35min"; 
  dessertModel.price="50";
  dessertModel.description="Sweet, satisfying treats to complete your meal. Choose from cakes, pastries, or creamy delights — all crafted to bring joy in every bite.";
  dessertModel.isVegan=true;  
  dessert.add(dessertModel);
  dessertModel=new DessertModel();


 dessertModel.name="Cake";
  dessertModel.image="images/cake1.jpg";   
  dessertModel.star=4.3;
  dessertModel.time="35min"; 
  dessertModel.price="50";
    dessertModel.description="Sweet, satisfying treats to complete your meal. Choose from cakes, pastries, or creamy delights — all crafted to bring joy in every bite.";
  dessertModel.isVegan=false;  
  dessert.add(dessertModel);
  dessertModel=new DessertModel();


   dessertModel.name="Veggie Cake";
  dessertModel.image="images/cupcakes.jpg";   
  dessertModel.star=4.3; 
  dessertModel.time="35min"; 
  dessertModel.price="50";
    dessertModel.description="Sweet, satisfying treats to complete your meal. Choose from cakes, pastries, or creamy delights — all crafted to bring joy in every bite.";
 dessertModel.isVegan=true;  
  dessert.add(dessertModel);
  dessertModel=new DessertModel();

   dessertModel.name="Cake";
  dessertModel.image="images/cake1.jpg";   
  dessertModel.star=4.3;
  dessertModel.time="35min"; 
  dessertModel.price="50";
    dessertModel.description="Sweet, satisfying treats to complete your meal. Choose from cakes, pastries, or creamy delights — all crafted to bring joy in every bite.";
    dessertModel.isVegan=false;  
  dessert.add(dessertModel);
  dessertModel=new DessertModel();


   dessertModel.name="Veggie Cake";
  dessertModel.image="images/cupcakes.jpg";   
  dessertModel.star=4.3;
  dessertModel.time="35min"; 
  dessertModel.price="50";
    dessertModel.description="Sweet, satisfying treats to complete your meal. Choose from cakes, pastries, or creamy delights — all crafted to bring joy in every bite.";
  dessertModel.isVegan=true;  
  dessert.add(dessertModel);
  dessertModel=new DessertModel();


   dessertModel.name="Cake";
  dessertModel.image="images/cake1.jpg";    
  dessertModel.star=4.3;
  dessertModel.time="35min"; 
  dessertModel.price="50";
    dessertModel.description="Sweet, satisfying treats to complete your meal. Choose from cakes, pastries, or creamy delights — all crafted to bring joy in every bite.";
  dessertModel.isVegan=false;    
  dessert.add(dessertModel);
  dessertModel=new DessertModel();  

  
 

  

 
 
 return dessert; 

}