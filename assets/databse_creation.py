import csv
import sqlite3
import os
import ast  # <-- ADD THIS

# Paths - update as per your folder structure
ASSETS_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_FILE_PATH = os.path.join(ASSETS_DIR, 'Food Ingredients and Recipe Dataset with Image Name Mapping.csv')
IMAGE_BASE_DIR = os.path.join(ASSETS_DIR, 'recipes_images')
DB_DIR = os.path.join(ASSETS_DIR, 'db')
DB_FILE = os.path.join(DB_DIR, 'recipes.db')

def create_database(db_path):
    # Ensure db directory exists
    if not os.path.exists(DB_DIR):
        os.makedirs(DB_DIR)
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute('''
        CREATE TABLE IF NOT EXISTS recipes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            ingredients TEXT,
            instructions TEXT,
            image_path TEXT,
            cleaned_ingredients TEXT
        )
    ''')
    conn.commit()
    return conn

def insert_recipe(conn, title, ingredients, instructions, image_path, cleaned_ingredients):
    c = conn.cursor()
    c.execute('''
        INSERT INTO recipes (title, ingredients, instructions, image_path, cleaned_ingredients)
        VALUES (?, ?, ?, ?, ?)
    ''', (title, ingredients, instructions, image_path, cleaned_ingredients))
    conn.commit()

def process_csv_and_insert(csv_path, conn):
    with open(csv_path, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            title = row['Title'].strip()
            # Parse Ingredients as Python list, then join as string
            try:
                ingredients_list = ast.literal_eval(row['Ingredients'])
                if not isinstance(ingredients_list, list):
                    raise ValueError
                ingredients = ', '.join([i.strip() for i in ingredients_list])
            except Exception:
                ingredients = row['Ingredients'].strip()
            instructions = row['Instructions'].strip()
            image_name = row['Image_Name'].strip()
            cleaned_ingredients = row.get('Cleaned_Ingredients', '').strip()
            image_path = f'assets/recipes_images/{image_name}'
            insert_recipe(conn, title, ingredients, instructions, image_path, cleaned_ingredients)
            print(f"Inserted recipe: {title}")

def main():
    conn = create_database(DB_FILE)
    process_csv_and_insert(CSV_FILE_PATH, conn)
    conn.close()
    print("All recipes inserted successfully.")

if __name__ == '__main__':
    main()