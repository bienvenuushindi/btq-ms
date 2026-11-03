# Curated retail products commonly stocked by neighborhood shops in the DRC.
# Each base SKU is expanded into five real pack sizes in seeds.rb, for exactly
# 500 distinct products while keeping names and categories useful in the UI.
CATALOG_PRODUCTS = {
  'Rice, grains & flour' => [
    'Mwewa Long Grain Rice', 'Riz Tilda Basmati', 'Riz Parfumé Uncle Ben’s', 'Riz Super Bella', 'Riz Jaune Local',
    'Maize Meal Likasi', 'Farine de Maïs Mbuji-Mayi', 'Semoule de Maïs Prima', 'Wheat Flour Capitaine', 'Farine de Blé Pâtissière',
    'Haricots Rouges du Kivu', 'Haricots Jaunes du Katanga', 'Haricots Blancs', 'Pois Cassés', 'Lentilles Vertes',
    'Soja Jaune', 'Arachides Décortiquées', 'Millet Grain', 'Sorgho Rouge', 'Fonio Grain',
    'Pâtes Spaghetti Panzani', 'Macaroni Panzani', 'Penne Rigate Barilla', 'Vermicelles de Riz', 'Nouilles Instantanées Indomie Chicken',
    'Semoule de Blé Dur', 'Farine de Manioc', 'Fufu de Manioc', 'Fufu de Maïs', 'Tapioca Perles',
    'Avoine Quaker', 'Céréales Corn Flakes Kellogg’s', 'Couscous Moyen Dari', 'Boulgour de Blé', 'Orge Perlée',
    'Riz Brisé Local', 'Riz Cargo', 'Riz Thaï Jasmin', 'Farine de Riz', 'Farine de Soja',
    'Haricots Noirs', 'Pois Chiches', 'Lentilles Corail', 'Maïs Jaune Sec', 'Maïs Blanc Sec',
    'Pâtes Coquillettes', 'Pâtes Fusilli', 'Pâtes Lasagne', 'Nouilles Instantanées Indomie Vegetable', 'Farine de Manioc Fécule'
  ],
  'Cooking essentials' => [
    'Huile de Palme Huilor', 'Huile de Tournesol Avo', 'Huile Végétale Golden', 'Huile d’Arachide', 'Huile de Maïs Mazola',
    'Sucre Cristallisé Sucre Congo', 'Sucre en Morceaux', 'Sel de Cuisine iodé', 'Sel Marin Fin', 'Vinaigre Blanc Star',
    'Vinaigre de Cidre', 'Sauce Tomate Pomo', 'Tomato Paste Gino', 'Purée de Tomates Mutti', 'Mayonnaise American Garden',
    'Ketchup Heinz', 'Moutarde Amora', 'Sauce Piquante Pili Pili', 'Sauce Soja Kikkoman', 'Sauce Worcestershire',
    'Cube Bouillon Maggi Poulet', 'Cube Bouillon Maggi Bœuf', 'Cube Bouillon Jumbo', 'Cube Bouillon Poisson', 'Poivre Noir Moulu',
    'Piment Rouge Moulu', 'Paprika Doux', 'Curry en Poudre', 'Gingembre Moulu', 'Ail en Poudre',
    'Cannelle en Poudre', 'Muscade Moulue', 'Laurier Séché', 'Herbes de Provence', 'Coriandre en Grains',
    'Café Instantané Nescafé Classic', 'Café Moulu Virunga', 'Thé Noir Lipton Yellow Label', 'Thé Vert Elephant', 'Chocolat en Poudre Van Houten',
    'Levure Boulangère Saf-Instant', 'Levure Chimique Ancel', 'Sucre Vanillé Ancel', 'Poudre à Flan Impérial', 'Lait de Coco Aroy-D',
    'Crème de Coco', 'Miel Naturel du Kivu', 'Confiture de Fraise Bonne Maman', 'Confiture d’Abricot', 'Beurre de Cacahuète Skippy'
  ],
  'Canned & preserved foods' => [
    'Sardines à l’Huile Titus', 'Sardines à la Tomate', 'Thon en Morceaux Rio Mare', 'Thon Entier Petit Navire', 'Maquereau à la Sauce Tomate',
    'Corned Beef Exeter', 'Bœuf en Conserve Hereford', 'Poulet en Conserve', 'Pâté de Foie Tulip', 'Jambon en Conserve',
    'Haricots Rouges en Sauce Heinz', 'Haricots Blancs en Sauce', 'Pois en Conserve Green Giant', 'Maïs Doux en Grains', 'Petits Pois Carottes',
    'Tomates Pelées Mutti', 'Champignons Émincés', 'Cœurs de Palmier', 'Olives Vertes Dénoyautées', 'Olives Noires en Saumure',
    'Ananas en Tranches Del Monte', 'Pêches au Sirop', 'Cocktail de Fruits', 'Mangue au Sirop', 'Lait Concentré Sucré Nido',
    'Lait Évaporé Peak', 'Lait en Poudre Nido FortiGrow', 'Crème Dessert Vanille', 'Soupe Tomate Knorr', 'Soupe Poulet Knorr',
    'Ravioli en Sauce Tomate', 'Spaghetti en Sauce Heinz', 'Ragoût de Bœuf en Conserve', 'Petit Pois en Conserve', 'Carottes en Rondelles',
    'Betteraves en Tranches', 'Concombre Cornichons Kühne', 'Cornichons Aigres-Doux', 'Piments Verts en Saumure', 'Aubergines Grillées en Bocal',
    'Sauce Bolognaise Barilla', 'Pesto Vert Barilla', 'Pesto Rouge Barilla', 'Bouillon de Poisson en Brique', 'Lait de Coco en Conserve',
    'Compote de Pommes', 'Confiture d’Orange', 'Marmelade de Citron', 'Poires au Sirop', 'Pois Chiches en Conserve'
  ],
  'Beverages' => [
    'Coca-Cola Original', 'Coca-Cola Zero Sugar', 'Fanta Orange', 'Fanta Citron', 'Sprite Lemon-Lime',
    'Schweppes Tonic Water', 'Schweppes Ginger Ale', 'Vitalo Malt Drink', 'Maltina Classic', 'Vitamalt Original',
    'Primus Lager', 'Skol Lager', 'Heineken Lager', 'Beaufort Lager', 'Tembo Bière Brune',
    'Castel Beer', 'Turbo King Stout', 'Booster Energy Drink', 'Red Bull Energy Drink', 'XXL Energy Drink',
    'Eau Minérale Simba', 'Eau Minérale Dasani', 'Eau Minérale La Vie', 'Eau Gazeuse Perrier', 'Jus d’Orange Ceres',
    'Jus de Pomme Ceres', 'Jus de Mangue Ceres', 'Jus Tropical Minute Maid', 'Jus d’Ananas Rani', 'Jus de Goyave Rani',
    'Jus de Bissap Naturel', 'Jus de Gingembre Naturel', 'Lait UHT Lactel Entier', 'Lait UHT Candia Demi-Écrémé', 'Lait Chocolaté Candia',
    'Yaourt à Boire Yogo', 'Sirop de Grenadine Teisseire', 'Sirop de Menthe Teisseire', 'Thé Glacé Lipton Pêche', 'Thé Glacé Lipton Citron',
    'Café Ready-to-Drink Nescafé', 'Boisson Isotonique Powerade', 'Boisson au Gingembre Tangawisi', 'Limonade Schweppes Agrum', 'Eau de Coco Vita Coco',
    'Poudre de Jus Tang Orange', 'Poudre de Jus Tang Tropical', 'Lait en Poudre Peak', 'Boisson Avoine Oatly', 'Boisson Soja Alpro'
  ],
  'Dairy, eggs & chilled' => [
    'Lait Frais Entier', 'Lait Frais Demi-Écrémé', 'Lait UHT Sans Lactose Lactel', 'Yaourt Nature Yoplait', 'Yaourt Fraise Yoplait',
    'Yaourt Vanille Yoplait', 'Yaourt Grec Nature', 'Yaourt à Boire Fraise', 'Fromage Gouda Président', 'Fromage Edam Président',
    'Fromage Cheddar Président', 'Mozzarella Galbani', 'Fromage Feta Dodoni', 'Fromage Fondu Kiri', 'Fromage en Tranches Hochland',
    'Beurre Président Doux', 'Margarine Blue Band', 'Crème Fraîche Elle & Vire', 'Crème à Cuisson Président', 'Œufs Frais Plateau',
    'Œufs de Caille Frais', 'Lait Fermenté Mabisi', 'Lait Caillé Nature', 'Petit Suisse Danone', 'Dessert Lacté Danette Chocolat',
    'Dessert Lacté Danette Vanille', 'Crème Dessert Caramel', 'Flan au Lait Vanille', 'Poudre de Lait Régilait', 'Lait en Poudre Peak Full Cream',
    'Lait en Poudre Nido FortiGrow', 'Lait en Poudre Bonnet Rouge', 'Lait Concentré Non Sucré Gloria', 'Lait Concentré Sucré Nestlé', 'Fromage Parmesan Râpé Galbani',
    'Fromage Emmental Râpé Président', 'Fromage Gouda en Bloc', 'Ricotta Galbani', 'Mascarpone Galbani', 'Yaourt Nature Sans Sucre',
    'Yaourt Mangue Yoplait', 'Yaourt Pêche Yoplait', 'Boisson Lactée Choco Milo', 'Kéfir Nature', 'Lait de Chèvre Frais',
    'Crème Chantilly Elle & Vire', 'Glace Vanille Carte d’Or', 'Glace Chocolat Carte d’Or', 'Glace Fraise Magnum', 'Sorbet Mangue Carte d’Or'
  ],
  'Snacks & confectionery' => [
    'Biscuits Prince Chocolat', 'Biscuits Petit Beurre LU', 'Biscuits Oreo Original', 'Biscuits Oreo Vanille', 'Biscuits Digestive McVitie’s',
    'Biscuits Marie LU', 'Gaufrettes Loacker Vanille', 'Gaufrettes Loacker Chocolat', 'Crackers Tuc Original', 'Crackers Tuc Fromage',
    'Chips Pringles Original', 'Chips Pringles Paprika', 'Chips Lay’s Nature', 'Chips Lay’s Poulet', 'Chips Simba Salt & Vinegar',
    'Popcorn Sucré Act II', 'Popcorn Salé Act II', 'Arachides Grillées Salées', 'Noix de Cajou Grillées', 'Banane Plantain Chips',
    'Chocolat Dairy Milk Cadbury', 'Chocolat Nestlé Dessert Noir', 'Chocolat Milka Lait', 'Barre Snickers', 'Barre Mars',
    'Barre Bounty', 'Barre Twix', 'Bonbons Mentos Menthe', 'Bonbons Mentos Fruit', 'Bonbons Halls Menthol',
    'Bonbons Chupa Chups', 'Chewing-gum Orbit Menthe', 'Chewing-gum Trident Fraise', 'Caramel Toffee Werther’s', 'Bonbons Haribo Goldbears',
    'Biscuits Mikado Chocolat', 'Biscuits Belvita Petit Déjeuner', 'Madeleines St Michel', 'Cakes Brossard Marbré', 'Gâteau Génoise Chocolat',
    'Barre Céréalière Kellogg’s', 'Barre Granola Nature Valley', 'Cacahuètes enrobées', 'Mélange Fruits Secs', 'Raisins Secs Sun-Maid',
    'Dattes Deglet Nour', 'Chips de Manioc', 'Bâtonnets Salés Bretzel', 'Biscuits Salés Ritz', 'Gaufrettes Croustina'
  ],
  'Personal care' => [
    'Savon de Toilette Dove Original', 'Savon de Toilette Lux Rose', 'Savon Palmolive Naturals', 'Savon Medimix Ayurvedic', 'Gel Douche Nivea Creme Soft',
    'Gel Douche Dove Deeply Nourishing', 'Shampooing Head & Shoulders Classic Clean', 'Shampooing Sunsilk Black Shine', 'Shampooing L’Oréal Total Repair', 'Après-Shampooing Dove Nourishing',
    'Dentifrice Colgate Triple Action', 'Dentifrice Closeup Red Hot', 'Dentifrice Sensodyne Repair & Protect', 'Brosse à Dents Colgate Medium', 'Brosse à Dents Oral-B Soft',
    'Déodorant Nivea Men Fresh', 'Déodorant Dove Original', 'Déodorant Rexona MotionSense', 'Lotion Corporelle Nivea Soft', 'Lait Corporel Vaseline Cocoa Glow',
    'Crème Vaseline Petroleum Jelly', 'Crème Mains Neutrogena', 'Beurre de Karité Naturel', 'Huile de Coco Parachute', 'Huile Capillaire Dark & Lovely',
    'Crème Défrisante Dark & Lovely', 'Crème Capillaire Cantu Shea Butter', 'Gel Coiffant Eco Styler', 'Lait Capillaire ORS Olive Oil', 'Pommade Capillaire Blue Magic',
    'Rasoir Gillette Blue II', 'Lames Gillette Mach3', 'Mousse à Raser Gillette', 'Crème Dépilatoire Veet', 'Coton Hydrophile Johnson’s',
    'Coton-tiges Johnson’s', 'Serviettes Hygiéniques Always Ultra', 'Serviettes Hygiéniques Kotex', 'Protège-slips Always Daily', 'Tampons Tampax Compak',
    'Papier Toilette Kleenex', 'Mouchoirs Kleenex Balsam', 'Lingettes Démaquillantes Nivea', 'Eau de Cologne Mennen', 'Parfum Zara Femme',
    'Eau de Toilette Adidas Dynamic Pulse', 'Crème Solaire Nivea SPF 50', 'Baume à Lèvres Labello', 'Fil Dentaire Oral-B', 'Rince-Bouche Listerine Cool Mint'
  ],
  'Household cleaning' => [
    'Lessive en Poudre Omo Active', 'Lessive en Poudre Ariel Original', 'Lessive en Poudre Skip', 'Lessive Liquide Omo', 'Lessive Liquide Ariel Color',
    'Savon de Lessive Mufuta', 'Savon de Lessive La Croix', 'Eau de Javel Jik', 'Eau de Javel La Croix', 'Liquide Vaisselle Sunlight',
    'Liquide Vaisselle Palmolive', 'Nettoyant Sol Mr. Proper Citron', 'Nettoyant Sol Ajax Floral', 'Désinfectant Dettol Multi-Usage', 'Désinfectant Sanytol',
    'Nettoyant Vitres Mr. Muscle', 'Nettoyant Salle de Bain Cif', 'Crème à Récurer Jif', 'Poudre à Récurer Vim', 'Déboucheur Canalisation Destop',
    'Désodorisant Air Wick Lavande', 'Désodorisant Glade Jasmin', 'Répulsif Moustiques Doom', 'Insecticide Baygon', 'Insecticide Raid Multi-Insectes',
    'Anti-Moustiques Spirales Mortein', 'Produit WC Harpic Power Plus', 'Bloc WC Bref', 'Nettoyant Four Mr. Muscle', 'Nettoyant Cuisine Cif',
    'Éponge Scotch-Brite', 'Tampon à Récurer Scotch-Brite', 'Chiffon Microfibre Vileda', 'Balai Intérieur Vileda', 'Serpillière Vileda',
    'Sacs Poubelle Handy Bag', 'Film Alimentaire Glad', 'Papier Aluminium Reynolds', 'Papier Cuisson Reynolds', 'Essuie-Tout Kleenex',
    'Allumettes Lion Safety Matches', 'Bougies Blanches Household', 'Pile AA Duracell', 'Pile AAA Duracell', 'Ampoule LED Philips 9W',
    'Ampoule LED Philips 12W', 'Savon Noir Multi-Usage', 'Détartrant Calgon', 'Adoucissant Lenor Fraîcheur', 'Désinfectant Surfaces Dettol'
  ],
  'Baby care' => [
    'Couches Pampers New Baby', 'Couches Pampers Active Baby', 'Couches Huggies Dry Comfort', 'Couches Molfix Premium', 'Couches Canbebe Baby Pants',
    'Lingettes Pampers Sensitive', 'Lingettes Huggies Pure', 'Crème de Change Bepanthen', 'Crème pour le Change Sudocrem', 'Poudre Bébé Johnson’s',
    'Huile Bébé Johnson’s', 'Lotion Bébé Johnson’s', 'Savon Bébé Johnson’s', 'Shampooing Bébé Johnson’s', 'Bain Moussant Bébé Johnson’s',
    'Lait Infantile NAN Optipro 1', 'Lait Infantile NAN Optipro 2', 'Lait Infantile NAN Optipro 3', 'Lait Infantile Nido 1+', 'Lait Infantile Aptamil 1',
    'Céréales Bébé Cerelac Riz', 'Céréales Bébé Cerelac Blé', 'Bouillie Bébé Nutribom', 'Purée Bébé Blédina Pomme', 'Purée Bébé Blédina Banane',
    'Compote Bébé Nestlé Pomme', 'Biscuits Bébé Blédina', 'Biberon Avent Natural', 'Biberon Chicco Well-Being', 'Tétine Avent Natural Response',
    'Tétine Chicco Physio', 'Sucette Avent Ultra Air', 'Sucette MAM Original', 'Goupillon Biberon Chicco', 'Stérilisateur Biberon Avent',
    'Assiette Bébé Nuk', 'Cuillère Bébé Munchkin', 'Gobelet Anti-Fuite Avent', 'Thermomètre Bébé Chicco', 'Mouche-Bébé Chicco',
    'Coton Bébé Johnson’s', 'Coton-tiges Bébé Johnson’s', 'Lessive Bébé Le Chat', 'Adoucissant Bébé Soupline', 'Shampooing Bébé Mustela',
    'Crème Hydratante Bébé Mustela', 'Eau Nettoyante Bébé Mustela', 'Sac à Couches Jetable', 'Bavoirs Bébé Plastifiés', 'Culottes d’Apprentissage Pampers'
  ],
  'Fresh produce' => [
    'Banane Cavendish', 'Banane Plantain', 'Pomme Golden Delicious', 'Pomme Granny Smith', 'Orange Valencia',
    'Mandarine Clementine', 'Citron Jaune', 'Citron Vert', 'Mangue Kent', 'Papaye Solo',
    'Ananas Cayenne', 'Avocat Hass', 'Pastèque Rouge', 'Melon Charentais', 'Raisin Blanc Thompson',
    'Raisin Noir Red Globe', 'Fraise Fraîche', 'Fruit de la Passion', 'Noix de Coco Fraîche', 'Gingembre Frais',
    'Tomate Roma', 'Tomate Cerise', 'Oignon Rouge', 'Oignon Jaune', 'Ail Blanc',
    'Pomme de Terre Agria', 'Patate Douce Orange', 'Manioc Frais', 'Igname Blanche', 'Taro Colocase',
    'Carotte Nantaise', 'Chou Blanc', 'Chou Rouge', 'Laitue Romaine', 'Épinards Frais',
    'Amarante Pondu', 'Feuilles de Manioc Pondu', 'Aubergine Africaine', 'Aubergine Violette', 'Poivron Vert',
    'Poivron Rouge', 'Piment Pili Pili Frais', 'Concombre Hollandais', 'Courgette Verte', 'Haricots Verts',
    'Okra Gombo Frais', 'Champignons de Paris', 'Céleri Branche', 'Coriandre Fraîche', 'Persil Plat'
  ]
}.freeze

PACK_SIZES = {
  'Rice, grains & flour' => ['250 g', '500 g', '1 kg', '5 kg', '25 kg'],
  'Cooking essentials' => ['100 g/ml', '250 g/ml', '500 g/ml', '1 kg/L', '5 kg/L'],
  'Canned & preserved foods' => ['155 g', '400 g', '800 g', '2.5 kg', '5 kg'],
  'Beverages' => ['250 ml', '330 ml', '500 ml', '1 L', '2 L'],
  'Dairy, eggs & chilled' => ['125 g/ml', '200 g/ml', '400 g/ml', '800 g/ml', '1 kg/L'],
  'Snacks & confectionery' => ['25 g', '50 g', '100 g', '200 g', '500 g'],
  'Personal care' => ['50 ml/g', '100 ml/g', '250 ml/g', '500 ml/g', '1 L/kg'],
  'Household cleaning' => ['250 ml/g', '500 ml/g', '1 L/kg', '2 L/kg', '5 L/kg'],
  'Baby care' => ['Small pack', 'Medium pack', 'Large pack', 'Value pack', 'Family pack'],
  'Fresh produce' => ['500 g', '1 kg', '2 kg', '5 kg', '10 kg']
}.freeze
