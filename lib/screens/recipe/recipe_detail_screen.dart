import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import 'package:url_launcher/url_launcher.dart';



class RecipeDetailScreen extends StatefulWidget {
final Recipe recipe;


const RecipeDetailScreen({
super.key,
required this.recipe,
});

@override
State<RecipeDetailScreen> createState() =>
_RecipeDetailScreenState();
}


class _RecipeDetailScreenState
extends State<RecipeDetailScreen> {
  Future<void> showMarketDialog() async {

  showModalBottomSheet(
    context: context,

    builder: (context) {

      return Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            const Text(
              "Market Seç",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(
                Icons.shopping_cart,
                color: Colors.orange,
              ),

              title: const Text("Migros"),

              onTap: () async {

                Navigator.pop(context);

                await launchUrl(
                  Uri.parse(
                    "https://www.migros.com.tr",
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.shopping_bag,
                color: Colors.purple,
              ),

              title: const Text("Trendyol"),

              onTap: () async {

                Navigator.pop(context);

                await launchUrl(
                  Uri.parse(
                    "https://www.trendyol.com",
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.delivery_dining,
                color: Colors.green,
              ),

              title: const Text("Getir"),

              onTap: () async {

                Navigator.pop(context);

                await launchUrl(
                  Uri.parse(
                    "https://getir.com",
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}


final Map<String, bool> ingredientStatus = {};

@override
Widget build(BuildContext context) {
final ingredients = widget.recipe.ingredients;
final steps = widget.recipe.steps;

final calories = widget.recipe.calories;
final protein = widget.recipe.protein;
final carbs = widget.recipe.carbs;
final fat = widget.recipe.fat;

return DefaultTabController(
  length: 3,

  child: Scaffold(

    appBar: AppBar(
      title: const Text("Tarif Detayı"),

      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),

    

        body: Column(
          children: [

            ClipRRect(
  borderRadius: const BorderRadius.only(
    bottomLeft: Radius.circular(25),
    bottomRight: Radius.circular(25),
  ),

  child: Image.network(
    widget.recipe.image,
    width: double.infinity,
    height: 180,
    fit: BoxFit.cover,

    errorBuilder:
        (context, error, stackTrace) {
      return Container(
        height: 180,
        width: double.infinity,
        color: Colors.grey.shade300,

        child: const Center(
          child: Icon(
            Icons.restaurant,
            size: 80,
          ),
        ),
      );
    },
  ),
),

            Container(
              padding:
              const EdgeInsets.all(16),

              child: Column(
                children: [

                  Text(
                    widget.recipe.title,
                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      fontSize: 24,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    "${calories.toStringAsFixed(0)} kcal • ${widget.recipe.servings} porsiyon",
                    style:
                    const TextStyle(
                      color:
                      Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceEvenly,

                    children: [

                      _infoCard(
                        Icons.timer,
                        "Hazırlık",
                        "${widget.recipe.readyInMinutes} dk",
                      ),

                      _infoCard(
                        Icons.people,
                        "Porsiyon",
                        "${widget.recipe.servings}",
                      ),

                      _infoCard(
                        Icons.favorite,
                        "Sağlık",
                        widget
                            .recipe
                            .healthScore
                            .toInt()
                            .toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const TabBar(
              labelColor:
              Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,

               labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
               ),


              tabs: [

                Tab(
                  text:
                  "Malzemeler",
                ),

                Tab(
                  text:
                  "Hazırlanış",
                ),

                Tab(
                  text:
                  "Besin",
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [

                  ListView(
                    padding:
                    const EdgeInsets
                        .all(16),

                    children: [
                      ...ingredients.map<Widget>((ingredient) {

  String ingredientName =
       ingredient.toString();

  ingredientStatus.putIfAbsent(
    ingredientName,
    () => true,
  );

  return Card(
    margin: const EdgeInsets.only(
      bottom: 10,
    ),

    child: Padding(
      padding: const EdgeInsets.all(12),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Expanded(
            child: Text(
              ingredientName,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                ingredientStatus[
                    ingredientName] =
                    !ingredientStatus[
                        ingredientName]!;
              });
            },

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color:
                    ingredientStatus[
                            ingredientName]!
                        ? Colors.green
                        : Colors.red,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(
                ingredientStatus[
                        ingredientName]!
                    ? "Mevcut"
                    : "Eksik",

                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}),
const SizedBox(height: 20),

SizedBox(
  width: double.infinity,

  child: ElevatedButton.icon(
    onPressed: () {
       showMarketDialog();
    },

    icon: const Icon(
      Icons.shopping_cart,
    ),

    label: const Text(
      "Eksikleri Satın Al",
    ),
  ),
),

                      
                    ],
                  ),
SingleChildScrollView(
  padding: const EdgeInsets.all(16),

  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [

      const Text(
        "Hazırlanış",
      ),

      const SizedBox(
        height: 10,
      ),

      ...steps.asMap().entries.map<Widget>((entry) {

        final index = entry.key;
        final step = entry.value.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(
                width: 32,
                height: 32,

                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),

                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(step),
              ),
            ],
          ),
        );
      }),
    ],
  ),
),

SingleChildScrollView(
  padding: const EdgeInsets.all(16),

  child: Column(
    children: [

      _nutritionCard(
        "Kalori",
        "${calories.toStringAsFixed(0)} kcal",
        (calories / 2000).clamp(0.0, 1.0),
        Icons.local_fire_department,
        Colors.orange,
      ),

      _nutritionCard(
        "Protein",
        "${protein.toStringAsFixed(1)} g",
        (protein / 100).clamp(0.0, 1.0),
        Icons.fitness_center,
        Colors.blue,
      ),

      _nutritionCard(
        "Karbonhidrat",
        "${carbs.toStringAsFixed(1)} g",
        (carbs / 300).clamp(0.0, 1.0),
        Icons.bakery_dining,
        Colors.amber,
      ),

      _nutritionCard(
        "Yağ",
        "${fat.toStringAsFixed(1)} g",
        (fat / 70).clamp(0.0, 1.0),
        Icons.av_timer,
        Colors.red,
      ),
    ],
  ),
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }   


                    

Widget _infoCard(
IconData icon,
String title,
String value,
) {
return Container(
width: 100,
padding:
const EdgeInsets.all(12),


  decoration: BoxDecoration(
    color:
    Colors.orange.shade50,

    borderRadius:
    BorderRadius.circular(16),
  ),

  child: Column(
    children: [

      Icon(
        icon,
        color: Colors.orange,
      ),

      const SizedBox(
        height: 5,
      ),

      Text(title),

      Text(
        value,
        style: const TextStyle(
          fontWeight:
          FontWeight.bold,
        ),
      ),
    ],
  ),
);
  
}



Widget _nutritionCard(
  String title,
  String value,
  double progress,
  IconData icon,
  Color color,
) {
  return Container(
    margin: const EdgeInsets.only(
      bottom: 16,
    ),

    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(20),

      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
        ),
      ],
    ),

    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Row(
          children: [

            Icon(
              icon,
              color: color,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(10),

          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: color,
            backgroundColor:
                Colors.grey.shade300,
          ),
        ),
      ],
    ),
  );
}

}
