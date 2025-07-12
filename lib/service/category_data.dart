//we will store all the category image and name
import 'package:fooddelivery_app/model/category_model.dart';
List<CategoryModel> getCategories(){ //list of categories

  List<CategoryModel> category=[];  //list category model with category which will be empty list to store image nad name one by one 
  CategoryModel categoryModel=new  CategoryModel();

   categoryModel.name="Burger";
   categoryModel.image="images/hamburger.jpg";  
   category.add(categoryModel); //ading to the category list 
   categoryModel=new CategoryModel();


  categoryModel.name="Pizza";
   categoryModel.image="images/pizza.png"; 
   category.add(categoryModel); //ading to the category list 
   categoryModel=new CategoryModel();


  categoryModel.name="Pasta";
   categoryModel.image="images/pasta.jpg"; 
   category.add(categoryModel); //ading to the category list 
   categoryModel=new CategoryModel();


   categoryModel.name="Salat";
   categoryModel.image="images/salats.jpg"; 
   category.add(categoryModel); //ading to the category list 
   categoryModel=new CategoryModel();

    categoryModel.name="Dessert";
   categoryModel.image="images/cake.jpg"; 
   category.add(categoryModel); //ading to the category list 
   categoryModel=new CategoryModel();

   return category;

   
   
   
   

}