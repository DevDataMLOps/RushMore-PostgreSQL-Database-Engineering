"""RushMore Pizzeria synthetic-data loader. Requires deployed Phase 02 schema.

Usage: python populate.py --dry-run
       python populate.py --load
       python populate.py --load --reset-synthetic

Reset deletes ALL rows from the six application tables. Only use on disposable data.
"""
import argparse
import os
import random
import time
from datetime import datetime
from decimal import Decimal

from dotenv import load_dotenv
from faker import Faker
import psycopg2
from psycopg2.extras import execute_values

load_dotenv()
SEED = 20261106
STORE_COUNT, CUSTOMER_COUNT, INGREDIENT_COUNT, MENU_COUNT = 5, 6000, 50, 30
ORDER_COUNT, ITEM_COUNT = 30000, 90000
BATCH = 2000

MENU_NAMES = [
    'Margherita Pizza', 'Pepperoni Pizza', 'BBQ Chicken Pizza', 'Veggie Supreme Pizza',
    'Hawaiian Pizza', 'Four Cheese Pizza', 'Meat Lovers Pizza', 'Mushroom Pizza',
    'Buffalo Chicken Pizza', 'Spinach Feta Pizza', 'Garlic Bread', 'Cheesy Bread',
    'Breadsticks', 'Chicken Wings', 'Caesar Salad', 'Garden Salad', 'Greek Salad',
    'Mozzarella Sticks', 'French Fries', 'Potato Wedges', 'Cola', 'Lemonade',
    'Sparkling Water', 'Orange Juice', 'Iced Tea', 'Bottled Water',
    'Chocolate Brownie', 'Cheesecake', 'Tiramisu', 'Cookie'
]
INGREDIENT_NAMES = [
    'Pizza Dough', 'Tomato Sauce', 'Mozzarella Cheese', 'Pepperoni', 'Basil',
    'Olive Oil', 'Chicken Breast', 'BBQ Sauce', 'Red Onion', 'Green Pepper',
    'Mushrooms', 'Pineapple', 'Ham', 'Cheddar Cheese', 'Parmesan Cheese',
    'Feta Cheese', 'Spinach', 'Black Olives', 'Jalapenos', 'Sausage',
    'Ground Beef', 'Bacon', 'Garlic', 'Butter', 'Oregano', 'Chili Flakes',
    'Romaine Lettuce', 'Cucumber', 'Tomatoes', 'Croutons', 'Ranch Dressing',
    'Caesar Dressing', 'Potatoes', 'Flour', 'Yeast', 'Sugar', 'Salt', 'Milk',
    'Eggs', 'Cocoa Powder', 'Cream Cheese', 'Coffee Beans', 'Lemon', 'Orange',
    'Mint', 'Honey', 'Paprika', 'Black Pepper', 'Corn', 'Sunflower Oil'
]

def connection():
    keys = ['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD']
    missing = [key for key in keys if not os.getenv(key)]
    if missing:
        raise RuntimeError('Missing environment variables: ' + ', '.join(missing))
    return psycopg2.connect(
        host=os.environ['DB_HOST'], dbname=os.environ['DB_NAME'],
        user=os.environ['DB_USER'], password=os.environ['DB_PASSWORD'],
        port=int(os.getenv('DB_PORT', '5432')), sslmode='require',
        connect_timeout=20, application_name='rushmore_phase03_loader',
    )

def insert(cur, table, columns, rows):
    # RETURNING only generated identifiers to avoid unnecessary network traffic.
    key = {'stores':'store_id','customers':'customer_id','ingredients':'ingredient_id',
           'menu_items':'item_id','orders':'order_id','order_items':'order_item_id'}[table]
    sql = f'INSERT INTO {table} ({", ".join(columns)}) VALUES %s RETURNING {key}'
    ids = []
    for offset in range(0, len(rows), BATCH):
        ids.extend(x[0] for x in execute_values(cur, sql, rows[offset:offset+BATCH], page_size=BATCH, fetch=True))
    return ids

def ensure_empty(cur):
    cur.execute('SELECT ' + ', '.join(f'(SELECT count(*) FROM {t})' for t in
                ['stores','customers','ingredients','menu_items','orders','order_items']))
    counts = cur.fetchone()
    if any(counts):
        raise RuntimeError(f'Target tables contain existing rows: {counts}. '
                           'Use --reset-synthetic ONLY if all existing rows are disposable.')

def generate_and_load(cur):
    fake = Faker('en_CA'); Faker.seed(SEED); rng = random.Random(SEED)
    store_rows = [(fake.street_address(), city, f'416555{i:04d}', fake.date_time_between(start_date='-8y', end_date='-1y'))
                  for i, city in enumerate(['Toronto','Ottawa','Mississauga','Brampton','Hamilton'], 1)]
    store_ids = insert(cur, 'stores', ['address','city','phone_number','opened_at'], store_rows)
    print(f'Loaded stores: {len(store_ids)}', flush=True)

    customer_rows = []
    for i in range(1, CUSTOMER_COUNT + 1):
        first, last = fake.first_name(), fake.last_name()
        customer_rows.append((first, last, f'rushmore.customer.{i:06d}@example.com',
                              f'647{1000000+i:07d}', fake.date_time_between(start_date='-3y', end_date='now')))
    customer_ids = insert(cur, 'customers', ['first_name','last_name','email','phone_number','created_at'], customer_rows)
    print(f'Loaded customers: {len(customer_ids)}', flush=True)

    ingredient_rows = [(name, Decimal(str(rng.randint(100, 5000))) / 10, rng.choice(['kg','liters','units']))
                       for name in INGREDIENT_NAMES]
    ingredient_ids = insert(cur, 'ingredients', ['name','stock_quantity','unit'], ingredient_rows)
    print(f'Loaded ingredients: {len(ingredient_ids)}', flush=True)

    menu_rows, prices = [], []
    for i, name in enumerate(MENU_NAMES):
        category = 'Pizza' if i < 10 else 'Side' if i < 20 else 'Drink' if i < 26 else 'Dessert'
        size = rng.choice(['Small','Medium','Large']) if category == 'Pizza' else 'N/A'
        menu_rows.append((name, category, size))
        prices.append(Decimal(str(rng.randint(450, 2899))) / 100)
    menu_ids = insert(cur, 'menu_items', ['name','category','size'], menu_rows)
    print(f'Loaded menu items: {len(menu_ids)}', flush=True)

    # Exactly 90,000 order-item rows: three distinct menu items per order.
    # Build orders and items together, then insert all orders before child records.
    orders, selections = [], []
    for i in range(ORDER_COUNT):
        indices = rng.sample(range(MENU_COUNT), 3)
        quantities = [rng.randint(1, 3) for _ in indices]
        total = sum((prices[j] * qty for j, qty in zip(indices, quantities)), Decimal('0.00'))
        orders.append((rng.choice(customer_ids), rng.choice(store_ids),
                       fake.date_time_this_year(), total))
        selections.append((indices, quantities))
    order_ids = insert(cur, 'orders', ['customer_id','store_id','order_timestamp','total_amount'], orders)
    print(f'Loaded orders: {len(order_ids)}', flush=True)

    items = []
    for order_id, (indices, quantities) in zip(order_ids, selections):
        items.extend((order_id, menu_ids[j], qty, prices[j]) for j, qty in zip(indices, quantities))
    item_ids = insert(cur, 'order_items', ['order_id','item_id','quantity','unit_price'], items)
    print(f'Loaded order items: {len(item_ids)}', flush=True)
    assert (len(store_ids),len(customer_ids),len(ingredient_ids),len(menu_ids),len(order_ids),len(item_ids)) == (5,6000,50,30,30000,90000)


def main():
    p = argparse.ArgumentParser()
    group = p.add_mutually_exclusive_group(required=True)
    group.add_argument('--dry-run', action='store_true', help='Print intended row counts; no database connection')
    group.add_argument('--load', action='store_true', help='Insert rows into Azure PostgreSQL')
    p.add_argument('--reset-synthetic', action='store_true', help='TRUNCATE all application tables before loading; destructive')
    args = p.parse_args()
    if args.dry_run:
        print('Planned rows: stores=5, customers=6000, ingredients=50, menu_items=30, orders=30000, order_items=90000; total=126085')
        return
    started = time.monotonic()
    with connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT current_database(), current_user')
            db, user = cur.fetchone()
            if db != 'rushmore_db':
                raise RuntimeError(f'Refusing to load unexpected database: {db}')
            print(f'Connected to {db} as {user}', flush=True)
            if args.reset_synthetic:
                confirm = input('This deletes ALL existing RushMore table rows. Type DELETE RUSHMORE DATA to continue: ')
                if confirm != 'DELETE RUSHMORE DATA':
                    raise RuntimeError('Reset cancelled')
                cur.execute('TRUNCATE TABLE order_items, orders, menu_items, ingredients, customers, stores RESTART IDENTITY CASCADE')
            ensure_empty(cur)
            generate_and_load(cur)
            print('Committing transaction...', flush=True)
    print(f'COMMITTED successfully in {time.monotonic()-started:.1f} seconds', flush=True)

if __name__ == '__main__':
    main()
