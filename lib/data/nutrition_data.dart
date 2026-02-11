class FoodNutrients {
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const FoodNutrients({
    this.caloriesKcal = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
  });

  FoodNutrients copyWith({
    double? caloriesKcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) {
    return FoodNutrients(
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final FoodNutrients nutrients;

  // ✅ Extra info (offline, UI-friendly)
  final String benefits; // health / fitness benefit summary
  final String tips; // cooking/storage tips
  final List<String> commonDishes; // where commonly used
  final String warnings; // allergies, moderation notes

  const FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = '',
    this.nutrients = const FoodNutrients(),
    this.benefits = '',
    this.tips = '',
    this.commonDishes = const [],
    this.warnings = '',
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? description,
    FoodNutrients? nutrients,
    String? benefits,
    String? tips,
    List<String>? commonDishes,
    String? warnings,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      nutrients: nutrients ?? this.nutrients,
      benefits: benefits ?? this.benefits,
      tips: tips ?? this.tips,
      commonDishes: commonDishes ?? this.commonDishes,
      warnings: warnings ?? this.warnings,
    );
  }
}

class NutritionCategory {
  final String id;
  final String emoji;
  final String name;
  final List<FoodItem> items;
  final String imageUrl;

  const NutritionCategory({
    required this.id,
    required this.emoji,
    required this.name,
    required this.items,
    required this.imageUrl,
  });
}

const _placeholder = 'https://via.placeholder.com/300x200.png?text=Food';

const nutritionCategories = <NutritionCategory>[
  // =========================
  // Meat & Poultry
  // =========================
  NutritionCategory(
    id: 'meat',
    emoji: '🥩',
    name: 'Meat & Poultry',
    imageUrl: 'assets/nutrition/image/meats and poultry.png',
    items: <FoodItem>[
      FoodItem(
        id: 'beef',
        name: 'Beef',
        imageUrl: _placeholder,
        description:
            'Beef is a popular protein source enjoyed in a wide variety of dishes worldwide. Its rich flavor and versatility make it a staple in many cuisines, from grilled steaks to hearty stews.',
        benefits:
            'Beef provides high-quality protein, iron, and essential nutrients that support muscle growth, energy, and overall health. It also contains B vitamins important for metabolism.',
        tips:
            'Select lean cuts to reduce fat intake. For best results, cook beef thoroughly and allow it to rest before serving. Pair with vegetables for a balanced meal.',
        commonDishes: ['Steak', 'Burger', 'Beef Stew', 'Kebab'],
        warnings: 'High saturated fat in some cuts; limit processed forms.',
      ),
      FoodItem(
        id: 'lamb',
        name: 'Lamb',
        imageUrl: _placeholder,
        description:
            'Lamb is a flavorful red meat known for its unique taste and tenderness. It is commonly used in Mediterranean and Middle Eastern dishes, such as roasts and kebabs.',
        benefits:
            'Lamb offers high-quality protein, B vitamins, and minerals like zinc, which help support immune function and muscle health.',
        tips:
            'Marinate lamb with herbs and garlic to enhance flavor. Slow-cook or roast for tenderness, and trim excess fat before cooking.',
        commonDishes: ['Roast Lamb', 'Lamb Kebab', 'Lamb Stew'],
        warnings: 'Can be fatty; choose lean parts if cutting calories.',
      ),
      FoodItem(
        id: 'chicken',
        name: 'Chicken',
        imageUrl: _placeholder,
        description:
            'Chicken is a lean white meat that is extremely versatile, making it a favorite for grilling, baking, and stir-frying in countless recipes.',
        benefits:
            'Chicken provides lean protein that supports muscle repair, satiety, and overall health. It is low in fat when skinless.',
        tips:
            'Bake or grill chicken for a healthier meal. Always cook thoroughly to avoid foodborne illness, and use spices or marinades for extra flavor.',
        commonDishes: [
          'Grilled Chicken',
          'Chicken Soup',
          'Chicken Wrap',
          'Curry'
        ],
        warnings: 'Undercooked chicken may cause foodborne illness.',
      ),
      FoodItem(
        id: 'turkey',
        name: 'Turkey',
        imageUrl: _placeholder,
        description:
            'Turkey is a mild-tasting poultry often chosen for lean meals and holiday feasts. It is commonly roasted, grilled, or used in sandwiches.',
        benefits:
            'Turkey is a great source of lean protein, low in fat, and supports muscle maintenance and healthy eating habits.',
        tips:
            'Avoid overcooking turkey breast to keep it moist. Use herbs and spices to boost flavor, and try ground turkey for meal prep.',
        commonDishes: ['Roast Turkey', 'Turkey Sandwich', 'Turkey Meatballs'],
        warnings: 'Deli turkey can be high in sodium.',
      ),
      FoodItem(
        id: 'duck',
        name: 'Duck',
        imageUrl: _placeholder,
        description:
            'Duck is a rich and flavorful poultry with higher fat content than chicken or turkey. It is often served roasted or in gourmet dishes.',
        benefits:
            'Duck provides energy-dense nutrition and a unique taste, making it a special choice for occasional meals.',
        tips:
            'Cook duck slowly to render fat and achieve tenderness. Pair with fresh or acidic sides like orange or vinegar to balance flavors.',
        commonDishes: ['Roast Duck', 'Duck Confit', 'Asian Duck Stir-fry'],
        warnings: 'Higher fat/calories than chicken; portion control helps.',
      ),
      FoodItem(
        id: 'processed_meat',
        name: 'Processed meat',
        imageUrl: _placeholder,
        description:
            'Processed meats include sausages, salami, hot dogs, and deli cuts. They are convenient but should be eaten in moderation due to additives.',
        benefits:
            'These meats offer quick protein but are often high in sodium and preservatives. Limit intake for better health.',
        tips:
            'Choose low-sodium and reduced-fat options when possible. Combine with vegetables to make meals more balanced.',
        commonDishes: ['Sandwiches', 'Breakfast Plates', 'Pizza Toppings'],
        warnings: 'Often high in sodium/preservatives; limit intake.',
      ),
    ],
  ),

  // =========================
  // Fish & Seafood
  // =========================
  NutritionCategory(
    id: 'fish',
    emoji: '🐟',
    name: 'Fish & Seafood',
    imageUrl: 'assets/nutrition/image/Fish and Seafood.jpg',
    items: <FoodItem>[
      FoodItem(
        id: 'salmon',
        name: 'Salmon',
        imageUrl: _placeholder,
        description:
            'Salmon is a fatty fish known for its rich flavor and versatility. It is commonly enjoyed grilled, baked, or in salads, and is a staple in many healthy diets.',
        benefits:
            'Salmon provides high-quality protein and is an excellent source of omega-3 fatty acids, which support heart and brain health.',
        tips:
            'Bake or pan-sear salmon for best texture. Avoid overcooking to keep it moist and flavorful. Pair with fresh vegetables or grains.',
        commonDishes: ['Grilled Salmon', 'Salmon Bowl', 'Salmon Salad'],
        warnings: 'Some fish may contain mercury; vary fish choices.',
      ),
      FoodItem(
        id: 'tuna',
        name: 'Tuna',
        imageUrl: _placeholder,
        description:
            'Tuna is a high-protein fish available fresh or canned, making it a convenient choice for salads, sandwiches, and quick meals.',
        benefits:
            'Tuna offers lean protein and essential nutrients, supporting muscle health and energy. It is low in fat and calories.',
        tips:
            'Choose tuna packed in water for fewer calories. Add lemon or pepper for extra flavor, and enjoy in salads or pasta.',
        commonDishes: ['Tuna Salad', 'Sandwich', 'Pasta with Tuna'],
        warnings: 'Higher mercury in some tuna types; moderate intake.',
      ),
      FoodItem(
        id: 'cod',
        name: 'Cod',
        imageUrl: _placeholder,
        description:
            'Cod is a mild white fish that is low in fat and often used in baked or fried dishes. It is a popular choice for lighter meals.',
        benefits:
            'Cod provides lean protein and is easy to digest, making it suitable for weight management and healthy eating.',
        tips:
            'Bake cod with spices for flavor. Serve with vegetables and rice for a balanced meal. Avoid frying to keep calories low.',
        commonDishes: ['Baked Cod', 'Fish Tacos', 'Fish & Chips'],
        warnings: 'Frying increases calories; baking is better for diet.',
      ),
      FoodItem(
        id: 'shrimp',
        name: 'Shrimp',
        imageUrl: _placeholder,
        description:
            'Shrimp is a quick-cooking seafood with a mild, sweet flavor. It is commonly used in stir-fries, pastas, and salads.',
        benefits:
            'Shrimp is high in protein and low in calories, making it a great choice for light and nutritious meals.',
        tips:
            'Cook shrimp briefly until pink. Enhance flavor with garlic and lemon, and add to salads or rice dishes.',
        commonDishes: ['Shrimp Pasta', 'Stir-fry', 'Seafood Rice'],
        warnings: 'Shellfish allergy risk; also watch added butter/oil.',
      ),
      FoodItem(
        id: 'crab',
        name: 'Crab',
        imageUrl: _placeholder,
        description:
            'Crab is a delicate seafood with a slightly sweet taste, often enjoyed in salads, sushi, and soups.',
        benefits:
            'Crab provides lean protein and minerals such as zinc, supporting immune function and muscle health.',
        tips:
            'Use crab in salads or sushi rolls. Avoid heavy creamy sauces to keep calories lower.',
        commonDishes: ['Crab Salad', 'Sushi Rolls', 'Seafood Soup'],
        warnings: 'Shellfish allergy risk.',
      ),
      FoodItem(
        id: 'mussels',
        name: 'Mussels',
        imageUrl: _placeholder,
        description:
            'Mussels are soft shellfish often steamed with herbs and garlic. They are a flavorful addition to pastas and stews.',
        benefits:
            'Mussels offer good protein, vitamin B12, and minerals, supporting energy and overall health.',
        tips:
            'Steam mussels with garlic and herbs. Discard any that do not open after cooking to ensure safety.',
        commonDishes: ['Steamed Mussels', 'Pasta', 'Seafood Stew'],
        warnings: 'Shellfish allergy risk; ensure freshness.',
      ),
    ],
  ),

  // =========================
  // Dairy & Eggs
  // =========================
  NutritionCategory(
    id: 'dairy',
    emoji: '🥚',
    name: 'Dairy & Eggs',
    imageUrl: 'assets/nutrition/image/Diary and Eggs.jpg',
    items: <FoodItem>[
      FoodItem(
        id: 'milk',
        name: 'Milk',
        imageUrl: _placeholder,
        description:
            'Milk is a versatile dairy drink used in cooking, baking, and beverages. It is a staple in many diets for its nutritional value.',
        benefits:
            'Milk provides calcium and protein, supporting bone health, muscle recovery, and overall growth.',
        tips:
            'Choose low-fat milk to reduce calories. Use in smoothies, oats, or as a base for sauces.',
        commonDishes: ['Cereal', 'Smoothies', 'Coffee', 'Baking'],
        warnings: 'Lactose intolerance possible.',
      ),
      FoodItem(
        id: 'yogurt',
        name: 'Yogurt',
        imageUrl: _placeholder,
        description:
            'Yogurt is a creamy dairy product, often fermented, and enjoyed as a snack or breakfast.',
        benefits:
            'Yogurt offers protein and probiotics, which aid digestion and support gut health.',
        tips:
            'Choose plain yogurt for less sugar. Add fresh fruit or honey for natural sweetness.',
        commonDishes: ['Breakfast Bowl', 'Sauces', 'Smoothies'],
        warnings: 'Flavored yogurt can be high sugar.',
      ),
      FoodItem(
        id: 'cheese',
        name: 'Cheese',
        imageUrl: _placeholder,
        description:
            'Cheese is a flavorful dairy product available in many varieties, used in sandwiches, salads, and cooking.',
        benefits:
            'Cheese provides protein and calcium, adding taste and satiety to meals.',
        tips:
            'Use cheese in small portions to manage calories. Try lower-fat varieties if needed.',
        commonDishes: ['Sandwich', 'Pasta', 'Salad', 'Pizza'],
        warnings: 'Can be high in salt/saturated fat.',
      ),
      FoodItem(
        id: 'butter',
        name: 'Butter',
        imageUrl: _placeholder,
        description:
            'Butter is a fat-rich dairy product used to enhance flavor and texture in cooking and baking.',
        benefits:
            'Butter adds taste and richness to dishes, but should be used in moderation.',
        tips:
            'Measure butter portions to control calories. Substitute with olive oil for a healthier option.',
        commonDishes: ['Baking', 'Sauces', 'Toast'],
        warnings: 'High in saturated fat; easy to overuse.',
      ),
      FoodItem(
        id: 'cream',
        name: 'Cream',
        imageUrl: _placeholder,
        description:
            'Cream is a rich dairy product used in sauces, desserts, and soups for added texture and flavor.',
        benefits:
            'Cream adds richness and energy to meals, but is high in calories.',
        tips: 'Use cream in small amounts. Try light cream for fewer calories.',
        commonDishes: ['Creamy Pasta', 'Desserts', 'Soups'],
        warnings: 'High calorie; not ideal for aggressive cutting.',
      ),
      FoodItem(
        id: 'eggs',
        name: 'Eggs',
        imageUrl: _placeholder,
        description:
            'Eggs are a classic protein food enjoyed for breakfast and in cooking. They are versatile and nutritious.',
        benefits:
            'Eggs provide complete protein, supporting muscle growth and satiety.',
        tips:
            'Boil or scramble eggs for easy meals. Add vegetables for extra nutrition and volume.',
        commonDishes: ['Omelet', 'Boiled Eggs', 'Baking'],
        warnings: 'Allergy possible; watch added oils.',
      ),
    ],
  ),

  // =========================
  // Vegetables
  // =========================
  NutritionCategory(
    id: 'vegetables',
    emoji: '🥦',
    name: 'Vegetables',
    imageUrl: 'assets/nutrition/image/vegetables.png',
    items: <FoodItem>[
      FoodItem(
        id: 'spinach',
        name: 'Spinach',
        imageUrl: _placeholder,
        description:
            'Spinach is a leafy green vegetable with a mild taste, commonly used in salads, omelets, and soups.',
        benefits:
            'Spinach is rich in vitamins, minerals, and fiber, supporting overall health and digestion.',
        tips:
            'Add spinach to omelets or soups for extra nutrients. It wilts quickly when cooked.',
        commonDishes: ['Salad', 'Omelet', 'Sauté', 'Soup'],
        warnings: 'Very high intake may affect some kidney stone prone people.',
      ),
      FoodItem(
        id: 'broccoli',
        name: 'Broccoli',
        imageUrl: _placeholder,
        description:
            'Broccoli is a crunchy cruciferous vegetable enjoyed steamed, roasted, or in stir-fries.',
        benefits:
            'Broccoli provides fiber and vitamin C, helping with fullness and immune support.',
        tips:
            'Steam or roast broccoli lightly to preserve nutrients. Avoid overboiling.',
        commonDishes: ['Roasted Broccoli', 'Stir-fry', 'Soup'],
        warnings: 'May cause gas in sensitive stomachs.',
      ),
      FoodItem(
        id: 'carrot',
        name: 'Carrot',
        imageUrl: _placeholder,
        description:
            'Carrot is a sweet, crunchy root vegetable often eaten raw, roasted, or in salads.',
        benefits:
            'Carrots are high in beta-carotene and fiber, making them a healthy snack.',
        tips:
            'Eat carrots raw or roast them for a sweeter taste. Pair with yogurt dips for snacks.',
        commonDishes: ['Salad', 'Soup', 'Roasted Veg Mix'],
        warnings: 'Very large intake can discolor skin (harmless).',
      ),
      FoodItem(
        id: 'potato',
        name: 'Potato',
        imageUrl: _placeholder,
        description:
            'Potato is a starchy staple vegetable, versatile for boiling, baking, or mashing.',
        benefits:
            'Potatoes provide energy and are filling, especially when boiled or baked.',
        tips:
            'Boil or bake potatoes for a healthier option. Cooling after cooking increases resistant starch.',
        commonDishes: ['Mashed Potato', 'Baked Potato', 'Stew'],
        warnings: 'Fried forms are calorie dense.',
      ),
      FoodItem(
        id: 'tomato',
        name: 'Tomato',
        imageUrl: _placeholder,
        description:
            'Tomato is a juicy fruit often used as a vegetable in salads, sauces, and sandwiches.',
        benefits: 'Tomatoes are hydrating and add flavor and volume to meals.',
        tips:
            'Use fresh tomatoes in salads or cook into sauces for extra taste.',
        commonDishes: ['Salad', 'Pasta Sauce', 'Sandwich'],
        warnings: 'Acidic—may trigger reflux for some.',
      ),
      FoodItem(
        id: 'cucumber',
        name: 'Cucumber',
        imageUrl: _placeholder,
        description:
            'Cucumber is a watery, refreshing vegetable commonly eaten raw in salads and snacks.',
        benefits:
            'Cucumbers are hydrating and low in calories, making them a great snack.',
        tips:
            'Eat cucumbers raw for best taste. Add lemon or salt for extra flavor.',
        commonDishes: ['Salad', 'Snack Plate', 'Tzatziki'],
        warnings: 'None major; wash well.',
      ),
      FoodItem(
        id: 'bell_pepper',
        name: 'Bell Pepper',
        imageUrl: _placeholder,
        description:
            'Bell pepper is a colorful, crunchy vegetable enjoyed raw, sautéed, or in stir-fries.',
        benefits:
            'Bell peppers are rich in vitamin C and add flavor with few calories.',
        tips:
            'Eat bell peppers raw or sautéed. Mix different colors for variety.',
        commonDishes: ['Fajitas', 'Stir-fry', 'Salad'],
        warnings: 'Can cause mild stomach sensitivity in some.',
      ),
      FoodItem(
        id: 'onion',
        name: 'Onion',
        imageUrl: _placeholder,
        description:
            'Onion is an aromatic vegetable used as a base in many dishes, adding flavor to soups, stews, and sauces.',
        benefits:
            'Onions add flavor with minimal calories and contain beneficial compounds.',
        tips: 'Sauté onions slowly to caramelize. Store in a cool, dry place.',
        commonDishes: ['Soups', 'Stews', 'Sauces', 'Salads'],
        warnings: 'May irritate IBS-sensitive digestion.',
      ),
      FoodItem(
        id: 'garlic',
        name: 'Garlic',
        imageUrl: _placeholder,
        description:
            'Garlic is a strong aromatic seasoning used to enhance flavor in sauces, marinades, and stir-fries.',
        benefits:
            'Garlic boosts flavor and may help reduce the need for extra salt.',
        tips: 'Crush garlic and let it sit before cooking for stronger taste.',
        commonDishes: ['Sauces', 'Marinades', 'Stir-fry'],
        warnings: 'Can cause heartburn for some.',
      ),
    ],
  ),

  // =========================
  // Fruits
  // =========================
  NutritionCategory(
    id: 'fruits',
    emoji: '🍎',
    name: 'Fruits',
    imageUrl: 'assets/nutrition/image/fruits.png',
    items: <FoodItem>[
      FoodItem(
        id: 'apple',
        name: 'Apple',
        imageUrl: _placeholder,
        description:
            'Apple is a crunchy fruit with a sweet-tart flavor, commonly eaten fresh or in desserts.',
        benefits:
            'Apples provide fiber for fullness and are an easy, portable snack.',
        tips: 'Pair apples with yogurt or nuts for a balanced snack.',
        commonDishes: ['Snack', 'Fruit Salad', 'Apple Pie'],
        warnings: 'Juice form loses fiber; whole fruit is better.',
      ),
      FoodItem(
        id: 'banana',
        name: 'Banana',
        imageUrl: _placeholder,
        description:
            'Banana is a soft, sweet fruit enjoyed as a snack or in smoothies and baked goods.',
        benefits:
            'Bananas offer quick energy and potassium, supporting performance and hydration.',
        tips: 'Eat bananas before workouts or mix into oats and smoothies.',
        commonDishes: ['Smoothie', 'Oatmeal Topping', 'Banana Bread'],
        warnings: 'Portion control if tracking carbs strictly.',
      ),
      FoodItem(
        id: 'orange',
        name: 'Orange',
        imageUrl: _placeholder,
        description:
            'Orange is a juicy citrus fruit, refreshing and commonly eaten as a snack or in salads.',
        benefits:
            'Oranges are rich in vitamin C and make a low-calorie, hydrating snack.',
        tips: 'Eat oranges whole for fiber. Use zest to add flavor to dishes.',
        commonDishes: ['Snack', 'Juice', 'Fruit Salad'],
        warnings: 'Acidic—may bother reflux.',
      ),
      FoodItem(
        id: 'strawberry',
        name: 'Strawberry',
        imageUrl: _placeholder,
        description:
            'Strawberry is a sweet-tart berry enjoyed fresh, in desserts, or with yogurt.',
        benefits:
            'Strawberries are low in calories and satisfy dessert cravings.',
        tips: 'Add strawberries to yogurt or oats. Wash gently before eating.',
        commonDishes: ['Yogurt Bowl', 'Smoothie', 'Desserts'],
        warnings: 'Allergy possible in some people.',
      ),
      FoodItem(
        id: 'blueberry',
        name: 'Blueberry',
        imageUrl: _placeholder,
        description:
            'Blueberry is a small berry with mild sweetness, popular in breakfast bowls and smoothies.',
        benefits:
            'Blueberries are good for snacks and fit well in many breakfast dishes.',
        tips: 'Use frozen blueberries for smoothies or add to oats and yogurt.',
        commonDishes: ['Oats', 'Yogurt', 'Smoothies', 'Muffins'],
        warnings: 'Dried blueberries can be high sugar.',
      ),
      FoodItem(
        id: 'grape',
        name: 'Grape',
        imageUrl: _placeholder,
        description:
            'Grape is a sweet, bite-sized fruit enjoyed fresh or frozen as a snack.',
        benefits:
            'Grapes are a quick snack and easy to portion for healthy eating.',
        tips: 'Freeze grapes for a cool, dessert-like treat.',
        commonDishes: ['Snack', 'Fruit Salad'],
        warnings: 'Easy to overeat; watch portions if cutting.',
      ),
      FoodItem(
        id: 'pineapple',
        name: 'Pineapple',
        imageUrl: _placeholder,
        description:
            'Pineapple is a tropical fruit with a sweet-acidic flavor, enjoyed fresh or in desserts.',
        benefits:
            'Pineapple is refreshing and pairs well with protein-rich meals.',
        tips: 'Use pineapple in smoothies or grill slices for a tasty dessert.',
        commonDishes: ['Smoothie', 'Fruit Salad', 'Desserts'],
        warnings: 'Acidic; may irritate mouth if very ripe/large amounts.',
      ),
      FoodItem(
        id: 'mango',
        name: 'Mango',
        imageUrl: _placeholder,
        description:
            'Mango is a sweet tropical fruit with a soft texture, popular in smoothies and fruit bowls.',
        benefits:
            'Mango is a good source of carbohydrates and adds flavor to many dishes.',
        tips:
            'Use ripe mango for best taste. Cube and freeze for easy use in smoothies.',
        commonDishes: ['Smoothie', 'Fruit Salad', 'Desserts'],
        warnings: 'High sugar compared to some fruits; portion control.',
      ),
    ],
  ),

  // =========================
  // Grains & Cereals
  // =========================
  NutritionCategory(
    id: 'grains',
    emoji: '🌾',
    name: 'Grains & Cereals',
    imageUrl: 'assets/nutrition/image/grains and cerals.jpg',
    items: <FoodItem>[
      FoodItem(
        id: 'rice',
        name: 'Rice',
        imageUrl: _placeholder,
        description:
            'Rice is a staple carbohydrate enjoyed in many varieties and cuisines, often served with protein and vegetables.',
        benefits:
            'Rice provides energy for workouts and is easy to digest, making it a good base for meals.',
        tips:
            'Pair rice with lean protein and vegetables for a balanced meal. Choose whole grain rice for more fiber.',
        commonDishes: ['Rice Bowl', 'Stir-fry', 'Pilaf'],
        warnings: 'Watch portions when cutting; choose whole grains sometimes.',
      ),
      FoodItem(
        id: 'pasta',
        name: 'Pasta',
        imageUrl: _placeholder,
        description:
            'Pasta is a popular carbohydrate base for sauces, enjoyed in many forms and recipes.',
        benefits:
            'Pasta is good for carb-loading and provides quick energy for active lifestyles.',
        tips:
            'Use tomato-based sauces and add protein like chicken or tuna for a balanced dish.',
        commonDishes: ['Spaghetti', 'Pasta Salad', 'Creamy Pasta'],
        warnings: 'Creamy sauces add lots of calories.',
      ),
      FoodItem(
        id: 'bread',
        name: 'Bread',
        imageUrl: _placeholder,
        description:
            'Bread is a common staple for meals and snacks, available in many varieties.',
        benefits:
            'Bread provides convenient carbohydrates; whole-grain options add more fiber.',
        tips:
            'Choose whole-grain bread for more nutrition. Watch spreads like butter or mayo to manage calories.',
        commonDishes: ['Sandwich', 'Toast', 'Breakfast'],
        warnings: 'Refined bread may spike hunger; portion control.',
      ),
      FoodItem(
        id: 'oats',
        name: 'Oats',
        imageUrl: _placeholder,
        description:
            'Oats are a whole grain used for oatmeal, overnight oats, and baking.',
        benefits: 'Oats are high in fiber and help keep you full longer.',
        tips:
            'Add protein like yogurt or whey and fruit for a nutritious meal.',
        commonDishes: ['Oatmeal', 'Overnight Oats', 'Baking'],
        warnings: 'Flavored oat packs can be high sugar.',
      ),
      FoodItem(
        id: 'corn',
        name: 'Corn',
        imageUrl: _placeholder,
        description:
            'Corn is a sweet, starchy grain/vegetable enjoyed grilled, boiled, or in salads.',
        benefits:
            'Corn provides carbohydrates and adds taste and texture to meals.',
        tips: 'Grill or boil corn and add to salads or bowls for variety.',
        commonDishes: ['Corn Salad', 'Grilled Corn', 'Soup'],
        warnings: 'Butter-heavy corn increases calories.',
      ),
      FoodItem(
        id: 'quinoa',
        name: 'Quinoa',
        imageUrl: _placeholder,
        description:
            'Quinoa is a grain-like seed high in nutrients, often used in bowls and salads.',
        benefits:
            'Quinoa has more protein than many grains and is good for meal prep.',
        tips:
            'Rinse quinoa before cooking to reduce bitterness. Use in salads or bowls.',
        commonDishes: ['Quinoa Bowl', 'Salad', 'Meal Prep'],
        warnings: 'Calories still add up—measure portions.',
      ),
      FoodItem(
        id: 'buckwheat',
        name: 'Buckwheat',
        imageUrl: _placeholder,
        description:
            'Buckwheat is a gluten-free grain alternative, used for porridge and noodles.',
        benefits:
            'Buckwheat is a good carbohydrate base and is often well tolerated.',
        tips:
            'Use buckwheat for porridge or noodles and pair with vegetables for a balanced meal.',
        commonDishes: ['Buckwheat Porridge', 'Soba Noodles'],
        warnings: 'Allergy is rare but possible.',
      ),
    ],
  ),

  // =========================
  // Legumes
  // =========================
  NutritionCategory(
    id: 'legumes',
    emoji: '🫘',
    name: 'Legumes',
    imageUrl: 'assets/nutrition/image/legumes.jpg',
    items: <FoodItem>[
      FoodItem(
        id: 'lentils',
        name: 'Lentils',
        imageUrl: _placeholder,
        description:
            'Lentils are small legumes commonly used in soups, stews, and salads. They cook quickly and absorb flavors well.',
        benefits:
            'Lentils are high in fiber and plant protein, making them very filling and nutritious.',
        tips:
            'Rinse lentils well before cooking. Add spices or onion for extra flavor.',
        commonDishes: ['Lentil Soup', 'Stew', 'Salad'],
        warnings: 'May cause gas; increase slowly if new to legumes.',
      ),
      FoodItem(
        id: 'chickpeas',
        name: 'Chickpeas',
        imageUrl: _placeholder,
        description:
            'Chickpeas are firm legumes with a nutty taste, used in hummus, curries, and salads.',
        benefits:
            'Chickpeas provide plant protein and fiber, making them good for meal prep and healthy eating.',
        tips:
            'Use canned chickpeas for quick meals or roast for a crunchy snack.',
        commonDishes: ['Hummus', 'Curry', 'Salad'],
        warnings: 'May cause bloating in some.',
      ),
      FoodItem(
        id: 'beans',
        name: 'Beans',
        imageUrl: _placeholder,
        description:
            'Beans are hearty legumes used worldwide in dishes like chili, bowls, and soups.',
        benefits:
            'Beans are rich in fiber and support fullness and gut health.',
        tips:
            'Soak dried beans before cooking. Rinse canned beans to reduce sodium.',
        commonDishes: ['Chili', 'Bean Bowl', 'Soup'],
        warnings: 'High fiber—add gradually if sensitive stomach.',
      ),
      FoodItem(
        id: 'peas',
        name: 'Peas',
        imageUrl: _placeholder,
        description:
            'Peas are small green legumes with a mildly sweet flavor, often served as a side dish or in soups.',
        benefits:
            'Peas add fiber and protein to meals and are easy to prepare.',
        tips:
            'Frozen peas are convenient and nutritious. Add to rice mixes or soups.',
        commonDishes: ['Side Dish', 'Soup', 'Rice Mix'],
        warnings: 'Usually well tolerated; watch butter/cream additions.',
      ),
      FoodItem(
        id: 'kidney_beans',
        name: 'Kidney Beans',
        imageUrl: _placeholder,
        description:
            'Kidney beans are firm beans commonly used in stews, chili, and salads.',
        benefits:
            'Kidney beans are very filling and provide plant protein and fiber.',
        tips:
            'Serve kidney beans with rice or in stews. Rinse canned beans before use.',
        commonDishes: ['Chili', 'Salad', 'Stews'],
        warnings: 'Raw/undercooked dried kidney beans are toxic—cook properly.',
      ),
    ],
  ),

  // =========================
  // Nuts & Seeds
  // =========================
  NutritionCategory(
    id: 'nuts',
    emoji: '🥜',
    name: 'Nuts & Seeds',
    imageUrl: 'assets/nutrition/image/nuts and seeds.png',
    items: <FoodItem>[
      FoodItem(
        id: 'almonds',
        name: 'Almonds',
        imageUrl: _placeholder,
        description:
            'Almonds are crunchy nuts with a mild flavor, enjoyed as snacks or toppings for oats and salads.',
        benefits:
            'Almonds provide healthy fats and help with satiety when eaten in small portions.',
        tips:
            'Use almonds as a snack or topping. Measure portions to manage calories.',
        commonDishes: ['Snack', 'Oat Topping', 'Salad Topping'],
        warnings: 'High calories; allergy possible.',
      ),
      FoodItem(
        id: 'walnuts',
        name: 'Walnuts',
        imageUrl: _placeholder,
        description:
            'Walnuts are nuts with a rich taste, often added to salads, desserts, or eaten as a snack.',
        benefits:
            'Walnuts provide healthy fats and add great texture to meals.',
        tips: 'Store walnuts in the fridge to keep them fresh.',
        commonDishes: ['Salad', 'Desserts', 'Snack'],
        warnings: 'High calories; allergy possible.',
      ),
      FoodItem(
        id: 'peanuts',
        name: 'Peanuts',
        imageUrl: _placeholder,
        description:
            'Peanuts are nuts/legumes widely used in snacks, peanut butter, and sauces.',
        benefits:
            'Peanuts offer good fats and protein, useful for meeting calorie needs.',
        tips:
            'Choose unsalted peanuts for snacks. Peanut butter is a convenient option.',
        commonDishes: ['Snack', 'Peanut Butter', 'Sauces'],
        warnings: 'Common allergy; high calories.',
      ),
      FoodItem(
        id: 'cashews',
        name: 'Cashews',
        imageUrl: _placeholder,
        description:
            'Cashews are creamy, mild nuts enjoyed as snacks or in stir-fries and vegan sauces.',
        benefits: 'Cashews add healthy fats and are good in blended sauces.',
        tips: 'Use a small handful of cashews for snacks or cooking.',
        commonDishes: ['Snack', 'Stir-fry', 'Vegan Cream Sauce'],
        warnings: 'High calories; allergy possible.',
      ),
      FoodItem(
        id: 'hazelnuts',
        name: 'Hazelnuts',
        imageUrl: _placeholder,
        description:
            'Hazelnuts are nuts with a strong aroma, often used in desserts, spreads, and snacks.',
        benefits:
            'Hazelnuts provide healthy fats and are commonly used in sweet recipes.',
        tips: 'Toast hazelnuts for better flavor in recipes.',
        commonDishes: ['Desserts', 'Spreads', 'Snack'],
        warnings: 'Allergy possible; calorie dense.',
      ),
      FoodItem(
        id: 'chia_seeds',
        name: 'Chia Seeds',
        imageUrl: _placeholder,
        description:
            'Chia seeds are tiny seeds that absorb liquid, used in puddings, smoothies, and yogurt bowls.',
        benefits:
            'Chia seeds are rich in fiber and help with fullness and digestion.',
        tips: 'Soak chia seeds for pudding or add to yogurt and smoothies.',
        commonDishes: ['Chia Pudding', 'Smoothies', 'Yogurt Bowl'],
        warnings: 'Drink water; too much may cause bloating.',
      ),
      FoodItem(
        id: 'flax_seeds',
        name: 'Flax Seeds',
        imageUrl: _placeholder,
        description:
            'Flax seeds are small seeds best consumed ground, added to oats, smoothies, and baking.',
        benefits:
            'Flax seeds provide fiber and healthy fats, supporting digestion.',
        tips:
            'Use ground flax seeds for better absorption. Add to oats or smoothies.',
        commonDishes: ['Oatmeal', 'Smoothies', 'Baking'],
        warnings: 'Increase gradually if not used to high fiber.',
      ),
    ],
  ),

  // =========================
  // Fats & Oils
  // =========================
  NutritionCategory(
    id: 'fats',
    emoji: '🧈',
    name: 'Fats & Oils',
    imageUrl: 'assets/nutrition/image/fats and oils.png',
    items: <FoodItem>[
      FoodItem(
        id: 'olive_oil',
        name: 'Olive Oil',
        imageUrl: _placeholder,
        description:
            'Olive oil is a classic oil used in Mediterranean cooking, known for its health benefits and flavor.',
        benefits:
            'Olive oil provides heart-friendly fats and enhances the taste of salads and cooked dishes.',
        tips:
            'Use olive oil for salads and low to medium heat cooking. Measure portions to control calories.',
        commonDishes: ['Salad Dressing', 'Roasted Veg', 'Pasta'],
        warnings: 'Very calorie dense—measure (1 tbsp adds a lot).',
      ),
      FoodItem(
        id: 'sunflower_oil',
        name: 'Sunflower Oil',
        imageUrl: _placeholder,
        description:
            'Sunflower oil is a neutral cooking oil suitable for frying, baking, and general cooking.',
        benefits:
            'Sunflower oil is good for cooking and has a neutral flavor that does not overpower dishes.',
        tips:
            'Use sunflower oil for frying but avoid excessive reuse. Measure portions for calorie control.',
        commonDishes: ['Frying', 'Cooking', 'Baking'],
        warnings: 'Still calorie dense—measure portions.',
      ),
      FoodItem(
        id: 'butter',
        name: 'Butter',
        imageUrl: _placeholder,
        description:
            'Butter is a rich dairy fat used to enhance flavor in baking, sauces, and toast.',
        benefits:
            'Butter enhances taste and texture in recipes but is high in saturated fat.',
        tips:
            'Use butter in small amounts and combine with spices for extra flavor.',
        commonDishes: ['Toast', 'Baking', 'Sauces'],
        warnings: 'High saturated fat; easy to overeat calories.',
      ),
      FoodItem(
        id: 'margarine',
        name: 'Margarine',
        imageUrl: _placeholder,
        description:
            'Margarine is a butter alternative spread, convenient for toast and baking.',
        benefits:
            'Margarine is a convenient spread but varies in nutritional value by type.',
        tips: 'Choose trans-fat-free margarine and use in moderation.',
        commonDishes: ['Toast', 'Baking'],
        warnings: 'Some types may be highly processed; check labels.',
      ),
      FoodItem(
        id: 'avocado_oil',
        name: 'Avocado Oil',
        imageUrl: _placeholder,
        description:
            'Avocado oil is a mild oil with a high smoke point, suitable for grilling, roasting, and salads.',
        benefits:
            'Avocado oil is great for higher-heat cooking and has a neutral taste.',
        tips:
            'Use avocado oil for grilling, roasting, or salad dressings. Measure portions for calorie control.',
        commonDishes: ['Roasted Veg', 'Stir-fry', 'Salad Dressing'],
        warnings: 'Calorie dense—measure portions.',
      ),
    ],
  ),

  // =========================
  // Snacks & Sweets
  // =========================
  NutritionCategory(
    id: 'sweets',
    emoji: '🍫',
    name: 'Snacks & Sweets',
    imageUrl: 'assets/nutrition/image/snack and sweets.png',
    items: <FoodItem>[
      FoodItem(
        id: 'chocolate',
        name: 'Chocolate',
        imageUrl: _placeholder,
        description:
            'Chocolate is a sweet treat enjoyed in desserts, snacks, and baking. Dark chocolate is less sweet and often preferred for its richer flavor.',
        benefits:
            'Chocolate can satisfy cravings and fit into a balanced diet when eaten in small portions.',
        tips:
            'Choose darker chocolate for less sugar. Keep portions small to manage calories.',
        commonDishes: ['Desserts', 'Snack', 'Baking'],
        warnings: 'High calories/sugar; easy to overeat.',
      ),
      FoodItem(
        id: 'cookies',
        name: 'Cookies',
        imageUrl: _placeholder,
        description:
            'Cookies are baked sweet snacks enjoyed with tea, coffee, or as desserts.',
        benefits:
            'Cookies provide quick energy and are best enjoyed as an occasional treat.',
        tips: 'Pair cookies with tea or coffee and practice portion control.',
        commonDishes: ['Snack', 'Dessert'],
        warnings: 'High sugar and fat; not ideal daily.',
      ),
      FoodItem(
        id: 'cake',
        name: 'Cake',
        imageUrl: _placeholder,
        description:
            'Cake is a sweet dessert often served at celebrations and enjoyed as a treat.',
        benefits:
            'Cake brings enjoyment and can be part of a balanced diet when eaten occasionally.',
        tips: 'Choose a smaller slice and balance with lighter meals.',
        commonDishes: ['Birthday Cake', 'Dessert'],
        warnings: 'Calorie dense; high sugar.',
      ),
      FoodItem(
        id: 'ice_cream',
        name: 'Ice Cream',
        imageUrl: _placeholder,
        description:
            'Ice cream is a frozen sweet dessert enjoyed as a treat or in milkshakes.',
        benefits:
            'Ice cream refreshes and is best enjoyed occasionally due to its sugar and fat content.',
        tips: 'Choose smaller servings or lighter options to manage calories.',
        commonDishes: ['Dessert', 'Milkshakes'],
        warnings: 'High sugar/fat; lactose intolerance possible.',
      ),
      FoodItem(
        id: 'chips',
        name: 'Chips',
        imageUrl: _placeholder,
        description:
            'Chips are crunchy, salty snacks often eaten between meals or with dips.',
        benefits:
            'Chips are convenient but low in nutrition and best enjoyed in moderation.',
        tips:
            'Buy small packs and pair chips with yogurt or fruit for a more balanced snack.',
        commonDishes: ['Snack'],
        warnings: 'High salt and calories; easy to overeat.',
      ),
    ],
  ),

  // =========================
  // Beverages
  // =========================
  NutritionCategory(
    id: 'beverages',
    emoji: '🥤',
    name: 'Beverages',
    imageUrl: 'assets/nutrition/image/Beverages.png',
    items: <FoodItem>[
      FoodItem(
        id: 'water',
        name: 'Water',
        imageUrl: _placeholder,
        description:
            'Water is essential for hydration and is a zero-calorie drink needed for all bodily functions.',
        benefits:
            'Water supports physical performance, digestion, and recovery, making it vital for health.',
        tips:
            'Drink water throughout the day and increase intake during workouts or hot weather.',
        commonDishes: ['Hydration'],
        warnings: 'None; but don’t overdo extreme amounts quickly.',
      ),
      FoodItem(
        id: 'tea',
        name: 'Tea',
        imageUrl: _placeholder,
        description:
            'Tea is a hot or cold drink available in many varieties, enjoyed for its flavor and health benefits.',
        benefits:
            'Tea is low in calories and can help reduce cravings, especially when unsweetened.',
        tips:
            'Avoid adding too much sugar. Try lemon or cinnamon for extra flavor.',
        commonDishes: ['Hot Tea', 'Iced Tea'],
        warnings: 'Caffeine in some teas; watch late-night intake.',
      ),
      FoodItem(
        id: 'coffee',
        name: 'Coffee',
        imageUrl: _placeholder,
        description:
            'Coffee is a caffeinated drink enjoyed hot or cold, with calories depending on added ingredients.',
        benefits:
            'Coffee can boost focus and workout performance when consumed in moderation.',
        tips:
            'Keep coffee simple to avoid extra calories. Milk and syrups add significant calories.',
        commonDishes: ['Espresso', 'Latte', 'Iced Coffee'],
        warnings: 'Too much caffeine may cause anxiety/sleep issues.',
      ),
      FoodItem(
        id: 'juice',
        name: 'Juice',
        imageUrl: _placeholder,
        description:
            'Juice is a sweet fruit drink, often consumed at breakfast or as a quick energy source.',
        benefits:
            'Juice provides quick carbohydrates and is useful when energy is low.',
        tips:
            'Prefer whole fruit for more fiber. If drinking juice, keep portions small.',
        commonDishes: ['Breakfast Drink'],
        warnings: 'High sugar; spikes calories quickly.',
      ),
      FoodItem(
        id: 'soft_drinks',
        name: 'Soft Drinks',
        imageUrl: _placeholder,
        description:
            'Soft drinks include sugary beverages and diet sodas, enjoyed for taste and refreshment.',
        benefits:
            'Soft drinks provide taste and comfort but little nutritional value.',
        tips:
            'Choose zero-sugar versions if reducing calories. Enjoy in moderation.',
        commonDishes: ['Snack Drink'],
        warnings: 'Sugary sodas are high calorie; moderation recommended.',
      ),
      FoodItem(
        id: 'protein_shake',
        name: 'Protein Shake',
        imageUrl: _placeholder,
        description:
            'Protein shakes are convenient drinks for increasing protein intake, often used post-workout.',
        benefits:
            'Protein shakes help reach daily protein goals and support muscle recovery.',
        tips:
            'Mix protein powder with water or milk. Add banana or oats for extra energy if bulking.',
        commonDishes: ['Post-workout Shake', 'Meal Replacement (light)'],
        warnings: 'Some powders upset stomach; check added sugar.',
      ),
    ],
  ),
];
