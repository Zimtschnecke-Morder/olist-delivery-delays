"""Скачивает таблицы датасета Olist в папку data/ (~125 МБ)."""
from pathlib import Path
from urllib.request import urlretrieve

BASE = 'https://raw.githubusercontent.com/olist/work-at-olist-data/master/datasets/'
FILES = ['orders', 'order_items', 'order_reviews', 'order_payments',
         'customers', 'sellers', 'products', 'geolocation']

out = Path(__file__).parent / 'data'
out.mkdir(exist_ok=True)
for name in FILES:
    fname = f'olist_{name}_dataset.csv'
    if not (out / fname).exists():
        print('скачиваю', fname)
        urlretrieve(BASE + fname, out / fname)
print('готово')
