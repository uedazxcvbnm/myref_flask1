#https://nokin-taro.com/rakuten-recipe-api/
#https://qiita.com/konitech913/items/7ffa7907a6c03c8909fc
import requests
import pandas as pd
import json
from pandas import json_normalize

#https://virtualsanpo.blogspot.com/2020/06/pythonfirebase-cloud-firestorejson.html

#urlの作成
base_url = 'https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?' #レシピランキングAPIのベースとなるURL
 
item_parameters = {
            'applicationId': '1057310997502838737', #アプリID
            'format': 'json',
            'formatVersion': 2,
}

r = requests.get(base_url, params=item_parameters)
json_data = r.json()
#print(json_data)

# mediumカテゴリの親カテゴリの辞書
parent_dict = {}

df = pd.DataFrame(columns=['category1','category2','category3','categoryId','categoryName'])

# 大カテゴリ
for category in json_data['result']['large']:
    df = df.append({'category1':category['categoryId'],'category2':"",'category3':"",'categoryId':category['categoryId'],'categoryName':category['categoryName']}, ignore_index=True)
    

# 中カテゴリ
for category in json_data['result']['medium']:
    df = df.append({'category1':category['parentCategoryId'],'category2':category['categoryId'],'category3':"",'categoryId':str(category['parentCategoryId'])+"-"+str(category['categoryId']),'categoryName':category['categoryName']}, ignore_index=True)
    parent_dict[str(category['categoryId'])] = category['parentCategoryId']
    

# 小カテゴリ
for category in json_data['result']['small']:
    df = df.append({'category1':parent_dict[category['parentCategoryId']],'category2':category['parentCategoryId'],'category3':category['categoryId'],'categoryId':parent_dict[category['parentCategoryId']]+"-"+str(category['parentCategoryId'])+"-"+str(category['categoryId']),'categoryName':category['categoryName']}, ignore_index=True)



#https://rayt-log.com/%E3%80%90firebase%E3%80%91python%E3%81%A7cloud-firestore%E3%81%AB%E5%80%A4%E3%82%92%E8%BF%BD%E5%8A%A0%E3%83%BB%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95%EF%BC%81/
#Firebaseのrefriを取得
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import time
import sqlite3

cred = credentials.Certificate("C:/firebase_myref/myref1-3-firebase-adminsdk-8eoqo-f254d2b63e.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

dbname = "C:/Users/ueda5/AppData/Local/Google/AndroidStudio2021.3/device-explorer/Pixel_5_API_30 [emulator-5554]/data/data/com.example.app_grid13/databases/assets/myref3.db"
conn = sqlite3.connect(dbname)
docs = conn.cursor()

# dbをpandasで読み出す。
#docs= pd.read_sql('SELECT * FROM material', conn)
docs.execute('SELECT name FROM refri')

#print(type(docs))

#recipe_test2.json
#データフレームを複数作成する
df_recipe2 = pd.DataFrame(columns=['foodImageUrl', 'recipeUrl'])
#df_recipe3= pd.DataFrame(columns=['recipeTitle','recipeMaterial'])

#recipe_test1.json
for doc in docs:
    #print(type(doc))
    str = ''.join(doc)
    str.replace(",","")
    #print(str)
    #doc=doc['name']
    #print(doc)
    #docから'name'だけを引っ張りたい
    df_keyword = df.query('categoryName.str.contains(@str)', engine='python')
    #print(df_keyword)
    #print('a')
    df_keyword2 = df_keyword['categoryName']
    df_keyword2.to_json('recipe_test1.json')
    #df_keyword.to_csv('recipe.csv')
    #print(df_keyword)
    #print("True")
    
    #firebase
    '''
    json_open = open('recipe_test1.json', 'r')
    json_load = json.load(json_open)

    for recipe in json_load.values():
        print(type(recipe))
        #doc_ref = db.collection(u'recipe').document()
        #print(type(doc_ref))
        #doc_ref.set({u'categoryName':recipe})
    '''

    for index, row in df_keyword.iterrows():
        time.sleep(3)
        url = 'https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426?applicationId=1057310997502838737&categoryId='+row['categoryId']
        res = requests.get(url)


        #firebase_recipe_ranking
        json_data = json.loads(res.text)
        recipes = json_data['result']

    #df_recipe2
    for recipe in recipes:
        df_recipe2 = df_recipe2.append({'foodImageUrl':recipe['foodImageUrl'], 'recipeUrl':recipe['recipeUrl']}, ignore_index=True)
        #print(type(df_recipe))
        df_recipe2.to_json('recipe_test2.json')

        json_open2 = open('recipe_test2.json', 'r')
        json_load2 = json.load(json_open2)

    #df_recipe3
    '''
    for recipe in recipes:
        df_recipe3 = df_recipe3.append({'recipeTitle':recipe['recipeTitle'],'recipeMaterial':recipe['recipeMaterial']}, ignore_index=True)
        #print(type(df_recipe))
        df_recipe3.to_json('recipe_test3.json')

        json_open3 = open('recipe_test3.json', 'r')
        json_load3 = json.load(json_open3)       
    '''       


for recipe2,recipeURL in zip(json_load2['foodImageUrl'].values(),json_load2['recipeUrl'].values()):
    doc_ref = db.collection(u'recipe').document()
    doc_ref.set({u'image':recipe2,u'URL':recipeURL})
    
    '''
    con2 = sqlite3.connect('assets/myref3.db')
    cur2 = con2.cursor()
    cur2.execute("CREATE TABLE IF NOT EXISTS Recipe(id integer,image text,url text)")
    cur2.executemany( "INSERT INTO person(image,url) VALUES (recipe2,recipeURL)")
    '''

    #doc_ref = db.collection(u'recipe').document()
    #doc_ref.set({u'image':recipe2,u'URL':recipeURL})

        #print(recipe2)
        #doc_ref = db.collection(u'recipe').document()
        #print(type(doc_ref))
        #doc_ref.set({u'URL':recipeURL})

        




        #res.to_json('recipe_test2.json')
'''
json_open2 = open('recipe_test2.json', 'r')
json_load2 = json.load(json_open2)

for recipe2 in json_load2.values():
    #print(type(recipe))
    doc_ref2 = db.collection(u'recipe').document()
    #print(type(doc_ref2))
    doc_ref2.set({u'recipeName':recipe2})
'''


'''
for doc in docs:
    doc=doc.to_dict()
    doc=doc['name']
    #print(doc)
    #docから'name'だけを引っ張りたい
    df_keyword = df.query('categoryName.str.contains(@doc)', engine='python')
    df_keyword = df_keyword['categoryName']
    df_keyword.to_json('recipe_test2.json')
    #df_keyword.to_csv('recipe.csv')
    #print(df_keyword)
    #print("True")

    json_open = open('recipe_test2.json', 'r')
    json_load = json.load(json_open)

    for recipe in json_load.values():
        #print(type(recipe))
        doc_ref = db.collection(u'recipe').document()
        print(type(doc_ref))
        doc_ref.set({u'categoryName':recipe})
'''

#json_data = json.loads(res.text)

#pprint(json_data)
    
    #dict_doc=doc.to_dict()
#print(doc)

#df.query()。()内で変数を使う場合は、変数の前に@をつける。例：@doc
#https://happy-analysis.com/python/python-topic-var-in-query.html

#df_keyword = df.query('categoryName.str.contains(food_contained)', engine='python')


#if doc.to_dict() in df:



    #print(df)


#データフレームをjsonに出力

#, index=False,  encoding='utf_8_sig'



#消したらだめ


