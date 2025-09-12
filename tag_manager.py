import sqlite3
import pandas as pd
import os
import re
from collections import defaultdict
import numpy as np

# Paths
DB_PATH = "assets/db/recipes.db"
CSV_PATH = "assets/Food Ingredients and Recipe Dataset with Image Name Mapping.csv"

def preprocess_text(title, ingredients):
    """Clean and combine title and ingredients for better classification"""
    title = str(title).lower().strip() if pd.notna(title) else ""
    ingredients = str(ingredients).lower().strip() if pd.notna(ingredients) else ""
    
    # Remove special characters and extra spaces
    title = re.sub(r'[^\w\s]', ' ', title)
    ingredients = re.sub(r'[^\w\s]', ' ', ingredients)
    
    # Combine and remove extra whitespace
    combined_text = f"{title} {ingredients}".strip()
    combined_text = re.sub(r'\s+', ' ', combined_text)
    
    return combined_text

def classify_recipe_rule_based(text):
    """Fast rule-based classification using keyword matching"""
    text = text.lower()
    
    # Define keyword mappings for different categories
    keywords = {
        # Meal types
        "breakfast": ["breakfast", "morning", "cereal", "pancake", "waffle", "toast", "omelette", "omelet", 
                     "eggs", "bacon", "sausage", "hash", "granola", "oatmeal", "porridge", "muffin"],
        "lunch": ["lunch", "sandwich", "wrap", "salad", "soup", "burger", "pizza slice"],
        "dinner": ["dinner", "main course", "steak", "roast", "pasta", "rice dish", "casserole", 
                  "curry", "stir fry", "grilled", "baked", "braised"],
        "snack": ["snack", "chips", "crackers", "nuts", "trail mix", "popcorn", "pretzel", "bite"],
        "dessert": ["dessert", "cake", "cookie", "pie", "ice cream", "chocolate", "sweet", "candy",
                   "pudding", "tart", "brownie", "cheesecake", "tiramisu", "mousse"],
        "drink": ["drink", "beverage", "smoothie", "juice", "cocktail", "coffee", "tea", "shake", 
                 "lemonade", "soda", "water"],
        
        # Cuisines
        "indian": ["indian", "curry", "tandoor", "masala", "biryani", "dal", "naan", "chapati", 
                  "turmeric", "cumin", "coriander", "garam masala", "tikka"],
        "italian": ["italian", "pasta", "pizza", "risotto", "lasagna", "spaghetti", "penne", 
                   "marinara", "parmesan", "mozzarella", "basil", "oregano", "focaccia"],
        "chinese": ["chinese", "stir fry", "wok", "soy sauce", "ginger", "garlic", "rice", 
                   "noodles", "dumpling", "fried rice", "sweet and sour"],
        "mexican": ["mexican", "taco", "burrito", "quesadilla", "salsa", "guacamole", "cilantro", 
                   "lime", "jalapeno", "chili", "tortilla", "enchilada"],
        "mediterranean": ["mediterranean", "olive oil", "olives", "feta", "hummus", "pita", 
                         "tzatziki", "lemon", "herbs", "tomatoes"],
        "american": ["american", "bbq", "burger", "hot dog", "fries", "mac and cheese", 
                    "fried chicken", "apple pie", "coleslaw"],
        "french": ["french", "butter", "cream", "wine", "herbs", "baguette", "croissant", 
                  "brie", "camembert", "ratatouille"],
        "thai": ["thai", "coconut", "lemongrass", "thai basil", "fish sauce", "curry paste", 
                "pad thai", "tom yum", "galangal"],
        "japanese": ["japanese", "soy", "miso", "sake", "sushi", "ramen", "udon", "tempura", 
                    "wasabi", "ginger", "seaweed"],
        
        # Styles
        "quick meal": ["quick", "easy", "fast", "minute", "instant", "ready", "simple", "no cook"],
        "comfort food": ["comfort", "hearty", "creamy", "rich", "warm", "cozy", "homestyle", 
                        "traditional", "classic"],
        "healthy": ["healthy", "light", "fresh", "lean", "low fat", "nutritious", "vitamin", 
                   "fiber", "antioxidant", "organic"],
        "spicy": ["spicy", "hot", "chili", "pepper", "jalapeno", "habanero", "cayenne", "paprika", 
                 "tabasco", "sriracha"],
        "sweet": ["sweet", "sugar", "honey", "maple", "vanilla", "cinnamon", "fruit", "berry", 
                 "chocolate", "caramel"],
        "vegetarian": ["vegetarian", "veggie", "vegetables", "beans", "lentils", "tofu", 
                      "quinoa", "spinach", "mushroom"],
        "fusion": ["fusion", "modern", "contemporary", "twist", "inspired", "style"]
    }
    
    # Score each category
    category_scores = defaultdict(int)
    
    for category, category_keywords in keywords.items():
        for keyword in category_keywords:
            if keyword in text:
                # Give higher scores for exact matches and longer keywords
                score = len(keyword.split())
                category_scores[category] += score
    
    # Get top categories
    if not category_scores:
        return ["general"]
    
    # Sort by score and return top categories
    sorted_categories = sorted(category_scores.items(), key=lambda x: x[1], reverse=True)
    
    # Return top 1-3 categories based on scores
    selected = []
    max_score = sorted_categories[0][1]
    
    for category, score in sorted_categories:
        if len(selected) >= 4:  # Max 4 tags
            break
        if score >= max_score * 0.5:  # Include categories with at least 50% of max score
            selected.append(category)
    
    return selected if selected else ["general"]

def batch_update_database(conn, updates):
    """Batch update database for better performance"""
    cursor = conn.cursor()
    cursor.executemany("UPDATE recipes SET tags = ? WHERE id = ?", updates)
    conn.commit()

def main():
    print("Starting optimized recipe classification...")
    
    # Check if files exist
    if not os.path.exists(CSV_PATH):
        print(f"CSV file not found: {CSV_PATH}")
        return
    
    if not os.path.exists(DB_PATH):
        print(f"Database file not found: {DB_PATH}")
        return
    
    try:
        # Load CSV
        print("Loading CSV data...")
        df = pd.read_csv(CSV_PATH)
        print(f"Loaded {len(df)} recipes from CSV")
        
        # Check CSV structure
        print(f"CSV columns: {list(df.columns)}")
        if 'Title' not in df.columns or 'Ingredients' not in df.columns:
            print("Warning: Expected 'Title' and 'Ingredients' columns not found")
            print("Available columns:", list(df.columns))
            return
        
        # Connect to database
        print("Connecting to database...")
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Check database structure
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = cursor.fetchall()
        print(f"Database tables: {[table[0] for table in tables]}")
        
        # Check if recipes table exists
        cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='recipes';")
        if cursor.fetchone()[0] == 0:
            print("Recipes table not found in database")
            return
        
        # Get current recipe count
        cursor.execute("SELECT COUNT(*) FROM recipes;")
        recipe_count = cursor.fetchone()[0]
        print(f"Database contains {recipe_count} recipes")
        
        # Add tags column if it doesn't exist
        cursor.execute("PRAGMA table_info(recipes);")
        columns = [col[1] for col in cursor.fetchall()]
        
        if "tags" not in columns:
            print("Adding tags column to database...")
            cursor.execute("ALTER TABLE recipes ADD COLUMN tags TEXT;")
            conn.commit()
        
        # Get existing recipe IDs from database
        cursor.execute("SELECT id FROM recipes ORDER BY id;")
        db_ids = [row[0] for row in cursor.fetchall()]
        
        # Prepare batch updates
        updates = []
        processed = 0
        successful_tags = 0
        batch_size = 100
        
        print(f"Starting fast rule-based classification of {min(len(df), len(db_ids))} recipes...")
        
        for idx, row in df.iterrows():
            if idx >= len(db_ids):
                break
                
            recipe_id = db_ids[idx]
            
            try:
                # Get and preprocess recipe data
                title = row.get('Title', '')
                ingredients = row.get('Ingredients', '')
                
                # Skip if both title and ingredients are empty
                if pd.isna(title) and pd.isna(ingredients):
                    processed += 1
                    continue
                
                # Preprocess text
                text = preprocess_text(title, ingredients)
                
                if len(text.strip()) < 3:
                    processed += 1
                    continue
                
                # Fast rule-based classification
                tags = classify_recipe_rule_based(text)
                
                # Add to batch updates
                tag_string = ", ".join(tags)
                updates.append((tag_string, recipe_id))
                
                successful_tags += 1
                processed += 1
                
                # Progress update and batch commit
                if processed % batch_size == 0:
                    print(f"Processed {processed} recipes... (Successfully tagged: {successful_tags})")
                    # Batch update database
                    batch_update_database(conn, updates)
                    updates = []
                    
                    # Show example
                    print(f"  Example - Recipe {recipe_id}: '{str(title)[:50]}...' -> {tags}")
                
            except Exception as e:
                print(f"Error processing recipe {recipe_id}: {e}")
                processed += 1
                continue
        
        # Final batch update for remaining records
        if updates:
            batch_update_database(conn, updates)
        
        print(f"\nClassification complete!")
        print(f"Total processed: {processed}")
        print(f"Successfully tagged: {successful_tags}")
        
        # Show some examples of the results
        print("\nSample results:")
        cursor.execute("SELECT id, tags FROM recipes WHERE tags IS NOT NULL AND tags != '' LIMIT 10;")
        examples = cursor.fetchall()
        
        for recipe_id, tags in examples:
            cursor.execute("SELECT title FROM recipes WHERE id = ?", (recipe_id,))
            title_result = cursor.fetchone()
            title = title_result[0] if title_result else "Unknown"
            print(f"  Recipe {recipe_id}: '{title[:40]}...' -> {tags}")
        
        # Show tag distribution
        print("\nTag distribution:")
        cursor.execute("SELECT tags, COUNT(*) as count FROM recipes WHERE tags IS NOT NULL GROUP BY tags ORDER BY count DESC LIMIT 10;")
        tag_stats = cursor.fetchall()
        for tags, count in tag_stats:
            print(f"  '{tags}': {count} recipes")
        
    except Exception as e:
        print(f"Error: {e}")
    
    finally:
        try:
            conn.close()
            print("\nDatabase connection closed")
        except:
            pass

if __name__ == "__main__":
    main()