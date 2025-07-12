import 'package:flutter/material.dart'; // Basic Flutter UI package
import 'package:fooddelivery_app/model/category_model.dart'; // Data model for food categories
import 'package:fooddelivery_app/model/burger_model.dart'; // Data model for burgers
import 'package:fooddelivery_app/model/dessert_model.dart'; // Data model for desserts
import 'package:fooddelivery_app/model/pizza_model.dart'; // Data model for pizza
import 'package:fooddelivery_app/model/pasta_model.dart'; // Data model for pasta
import 'package:fooddelivery_app/model/salat_model.dart'; // Data model for salad 
import 'package:fooddelivery_app/pages/detail_page.dart'; // Detail screen for food
import 'package:fooddelivery_app/service/burger_data.dart'; // Sample burger data
import 'package:fooddelivery_app/service/dessert_data.dart'; // Sample dessert data
import 'package:fooddelivery_app/service/pasta_data.dart'; // Sample pasta data
import 'package:fooddelivery_app/service/pizza_data.dart'; // Sample pizza data
import 'package:fooddelivery_app/service/salat_data.dart'; // Sample salad data
import 'package:fooddelivery_app/service/shared_pref.dart'; // Shared preferences to get saved data 
import 'package:fooddelivery_app/service/widget_support.dart'; // Custom text styles/widgets
import 'package:fooddelivery_app/service/category_data.dart'; // Category data
import 'package:carousel_slider/carousel_slider.dart';  // Slider for promotions

// Enum for food categories
enum FoodCategory { burger, pizza, pasta, salad, dessert } //It defines a list of possible food categories in

// Enum for filter (all, vegan, non-vegan) 
enum FoodFilter { all, vegan, nonVegan }

// Map to store ratings by food name,key value pair store 
Map<String, double> foodRatings = {}; //ey = food name (e.g. "Burger King Special")

//Value = user rating (e.g. 4.5)

class Home extends StatefulWidget { //it can change its UI when something changes (like filtering food, selecting a category, etc.).
  const Home({super.key});

  @override 
  State<Home> createState() => _HomeState(); // widget to its State class, _HomeState, which will control how the UI works and updates.


}

class _HomeState extends State<Home> { 
  String? profileImageUrl; // Store profile image URL
  List<CategoryModel> categories = []; // Categories list
  List<BurgerModel> burger = []; // Burger data
  List<PizzaModel> pizza=[]; // Pizza data
  List<PastaModel> pasta=[]; // Pasta data
  List<SalatModel> salat=[]; // Salad data
  List<DessertModel> dessert=[]; // Dessert data
  int selectedCategoryIndex = 0; // Which category is selected
  TextEditingController _searchController = TextEditingController(); // Controller for search box
  String _searchQuery = ''; // What the user is typing
  FoodFilter selectedFilter = FoodFilter.all; // Current selected filter

  // Images for promotional slider
  final List<String> promoImages = [
    "images/promotion1.jpg", 
    "images/promotion2.jpg", 
  ];

  @override
  void initState() {
    categories = getCategories(); // Load category list
    burger = getBurger(); // Load burger list
    pizza = getPizza(); // Load pizza list
    pasta = getPasta(); // Load pasta list
    salat = getSalat(); // Load salad list
    dessert = getDessert(); // Load dessert list
    _loadUserProfileImage(); // Load profile image if stored

    // When user types in search field
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase(); // Update the search query
      });
    });

    super.initState();
  }

  // Load profile image from shared preferences
  Future<void> _loadUserProfileImage() async {
    final prefs = SharedpreferenceHelper();
    final imageUrl = await prefs.getUserImage(); // Get image from preferences
    setState(() {
      profileImageUrl = imageUrl;
    });
  }

  // Show dialog to choose food preference (All, Vegan, Non-Vegan)
  void _showPreferenceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Food Preference'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<FoodFilter>(
                title: Text('All'),
                value: FoodFilter.all,
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!; // update the UI when a value changes.
                  });
                  Navigator.pop(context); // Close dialog
                },
              ),
              RadioListTile<FoodFilter>(
                title: Text('Vegan Only'),
                value: FoodFilter.vegan,
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!; // update the UI when a value changes.
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<FoodFilter>(
                title: Text('Non-Vegan'),
                value: FoodFilter.nonVegan,
                groupValue: selectedFilter,
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) { // when Flutter needs to draw the UI.
    return Scaffold( //eturn a widget tree provides a basic structure for your ap
      body: Container(
        margin: EdgeInsets.only(left: 20.0, top: 40.0), // Padding from top/left
        child: Column(
          children: [
            // Header row with logo and profile image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("images/logo.png", height: 50, width: 85, fit: BoxFit.contain),
                    Text("Order your favourite food!", style: AppWidget.ContainerStyle2())
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? Image.network(profileImageUrl!, height: 60, width: 60, fit: BoxFit.cover)
                      : const SizedBox(height: 60, width: 60),
                  ),
                )
              ],
            ),
            SizedBox(height: 20.0),

            // Promotion slider
            CarouselSlider(
              options: CarouselOptions(
                height: 120.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(seconds: 1),
                viewportFraction: 0.8,
              ),
              items: promoImages.map((imagePath) { // oops through each image It takes a list of images
                return Builder(
                  builder: (BuildContext context) {
                    return Container( //Adds padding, rounded corners, and a slight shadow to the container holding the image
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))],
                      ),
                      child: ClipRRect( //Clips the image to match the rounded corners
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 20.0),

            // Search box and filter button
            Row( // Lays out child widgets horizontally 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded( //Makes the container take up all available horizontal space 
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0),
                    margin: EdgeInsets.only(right: 20.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search for food...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPreferenceDialog(context), // Open filter options
                  child: Container(
                    margin: EdgeInsets.only(right: 10.0),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xffef2b39),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tune, color: Colors.white, size: 30.0),
                  )
                ), 
              ],
            ),

            SizedBox(height: 20.0),

            // Food categories horizontal scroll
            Container(
              height: 60,
              child: ListView.builder(
                shrinkWrap: true, //tells the scrollable widget to take only the space it needs
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryTile( //custom widget used to display one category tab (like Burger, Pizza, etc.).
                    image: categories[index].image!, //Sets the image of the tile using the current item in the categories list.
                    name: categories[index].name!,
                    isSelected: selectedCategoryIndex == index, //his checks if this tile is the currently selected category.
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index; // Update selected category
                      });
                    },
                  );
                },
              ),
            ),

            SizedBox(height: 10.0),

            // Show food list by category (burger, pizza, etc.)
            Expanded( // block takes the remaining vertical space (Expanded) and wraps the food list in a Container 
              child: Container(
                margin: EdgeInsets.only(right: 10.0),
                child: Builder( //allows creating a context for widgets inside.
                  builder: (context) {
                    final foodList = selectedCategoryIndex == 0 ? burger : // Based on which category is selected, it chooses the correct lis
                                     selectedCategoryIndex == 1 ? pizza :
                                     selectedCategoryIndex == 2 ? pasta :
                                     selectedCategoryIndex == 3 ? salat :
                                     selectedCategoryIndex == 4 ? dessert : [];

                    final filteredFood = foodList.where((item) { //Filters the selected food list to only show items that match the search and filter.
                      final isVegan = item.isVegan; //Gets whether this food is vegan.
                      final nameMatch = item.name != null && item.name!.toLowerCase().contains(_searchQuery); //hecks if the food's name contains the search text the user typed.

                      final filterMatch = selectedFilter == FoodFilter.all || //hecks if the food matches the selected vegan filter:
                        (selectedFilter == FoodFilter.vegan && isVegan) ||
                        (selectedFilter == FoodFilter.nonVegan && !isVegan);
                      return nameMatch && filterMatch; //only return foods that match both the name and the selected filter.
                    }).toList();

                    return GridView.builder( //scrollable grid view that builds each food item widget dynamically
                      padding: EdgeInsets.zero, //No padding around the grid 
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( //The grid will have 2 columns (2 items in each row).
                        crossAxisCount: 2,
                        childAspectRatio: 0.69,
                        mainAxisSpacing: 20.0, //pace between rows
                        crossAxisSpacing: 15.0, //pace between columns
                      ),
                      itemCount: filteredFood.length, //ells the builder how many items to build —
                      itemBuilder: (context, index) { //Get the item from the filteredFood list using its index.
                        final item = filteredFood[index];
                        return FoodTile(item.name!, item.image!, item.price!, item.star!, item.time!, item.description!); //Builds a custom widget called FoodTi
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget to show a single food item
  Widget FoodTile(String name, String image, String price, double finalrating, String time, String description) {
    return Container(
      margin: EdgeInsets.only(right: 20.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(image, height: 90, width: 120, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 8),
          Text(name, style: AppWidget.boldTextFeildStyle()),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 22),
              SizedBox(width: 4),
              Text(finalrating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              SizedBox(width: 10),
              Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(time, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
          SizedBox(height: 4),
          Text("\$" + price, style: AppWidget.priceTextFeildStyle()),
          Spacer(),
          GestureDetector(
            onTap: () async {
              final newRating = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailPage(image: image, name: name, price: price, description: description, star: finalrating)),
              );
              if (newRating != null) {
                setState(() {
                  foodRatings[name] = newRating; // Save updated rating
                });
              }
            },
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xffef2b39),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text("See details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for each category tab (e.g. Burger, Pizza) custom UI widget that represents a category i
class CategoryTile extends StatelessWidget {
  final String name;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTile({
    required this.image, //means the user must provide these values when using the widget.
    required this.name,
    required this.isSelected,
    required this.onTap,
    super.key, //helps Flutter efficiently compare widgets.
  });

  @override
  Widget build(BuildContext context) { //his widget creates a beautiful category button that:

//Changes color and shadow when selected

//Grows the icon size smoothly

//Lets the user tap to switch categories
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        margin: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Color(0xffef2b39), Color(0xffff616d)], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : LinearGradient(colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5))]
              : [],
          border: Border.all(color: Color(0xffef2b39), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: Duration(milliseconds: 300),
              scale: isSelected ? 1.2 : 1.0,
              child: Image.asset(image, height: 35, width: 35, fit: BoxFit.cover),
            ),
            SizedBox(width: 10.0),
            Text(
              name,
              style: AppWidget.ContainerStyle3().copyWith(
                color: isSelected ? Colors.white : Color(0xffef2b39),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}
 