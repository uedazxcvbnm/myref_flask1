from flask import Flask, jsonify,request
import requests
import pandas as pd
import json
from pandas import json_normalize

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import time
import sqlite3

from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import os

app = Flask(__name__)

@app.route('/')
def home():
  return "Tutor Joes Api"

#https://rayt-log.com/%E3%80%90firebase%E3%80%91python%E3%81%A7cloud-firestore%E3%81%AB%E5%80%A4%E3%82%92%E8%BF%BD%E5%8A%A0%E3%83%BB%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95%EF%BC%81/
#Firebaseのrefriを取得

'''
#cred = credentials.Certificate("C:/firebase_myref/myref1-3-firebase-adminsdk-8eoqo-f254d2b63e.json")
cred = credentials.Certificate("C:/firebase_myref/myref1-4-firebase-adminsdk-mrtn2-23471e5158.json")

firebase_admin.initialize_app(cred)
fire = firestore.client()

refri = fire.collection('refri')
docs = refri.stream()
'''



basedir=os.path.abspath(os.path.dirname(__file__))
#print(basedir)
app.config['SQLALCHEMY_DATABASE_URI']='sqlite:///'+os.path.join(basedir,'recipe_db.sqlite')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True

db= SQLAlchemy(app)
ma = Marshmallow(app)

# User Table Model 
class Recipe(db.Model):
  id=db.Column(db.Integer,primary_key=True)
  image = db.Column(db.String(100))
  url = db.Column(db.String(100))
 
  def __init__(self,image,url) :
    #self.id=id
    self.image=image
    self.url=url
 
class RecipeSchema(ma.Schema):
  class Meta:
    fields = ('id', 'image', 'url')
recipe_schema = RecipeSchema()
recipe_schema=RecipeSchema(many=True)

db.create_all()

basedir=os.path.abspath(os.path.dirname(__file__))
#print(basedir)
app.config['SQLALCHEMY_DATABASE_URI']='sqlite:///'+os.path.join(basedir,'food_db.sqlite')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
 
class foodList(db.Model):
  id=db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(100))
 
  def __init__(self,name) :
    self.name=name
 
class foodListSchema(ma.Schema):
  class Meta:
    fields = ('id', 'name')
 
food_schema = foodListSchema()
food2_schema=foodListSchema(many=True)


db.create_all()


@app.route('/recipe',methods=['POST'])
def add_food():
    #テーブルのカラムを全て消す
    db.session.query(foodList).delete()
    db.session.commit()
    db.session.query(Recipe).delete()
    db.session.commit()
    db.create_all()

    name=request.json['name']
    new_food=foodList(name)
    db.session.add(new_food)
    db.session.commit()
    return food_schema.jsonify(new_food)

@app.route('/recipe',methods=['GET'])
def getAllRecipe():
    #https://nokin-taro.com/rakuten-recipe-api/
    #https://qiita.com/konitech913/items/7ffa7907a6c03c8909fc
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




    #データフレームを複数作成する
    df_recipe2 = pd.DataFrame(columns=['foodImageUrl', 'recipeUrl'])
    df_recipe3 = pd.DataFrame(columns=['image', 'url'])

    all_food=foodList.query.all()
    docs=food2_schema.dump(all_food)

    #recipe_test1.json
    for doc in docs:
        doc=doc['name']
        #print(doc)
        #docから'name'だけを引っ張りたい
        df_keyword = df.query('categoryName.str.contains(@doc)', engine='python')
        df_keyword2 = df_keyword['categoryName']
        df_keyword2.to_json('recipe_test1.json')

        json_open = open('recipe_test1.json', 'r')
        json_load = json.load(json_open)


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
    #２つをまとめてjsonに格納する
    for recipe_image,recipeURL in zip(json_load2['foodImageUrl'].values(),json_load2['recipeUrl'].values()):
        
        #doc_ref = db.collection(u'recipe').document()
        #doc_ref.set({u'image':recipe2,u'URL':recipeURL})
        #df_recipe3= df_recipe3.append({'id':str(id),'image':recipe_image,'url':recipeURL}, ignore_index=True)
        #print(type(df_recipe2))

        '''
        df_recipe3.to_json('recipe_test2.json')
        json_open = open('recipe_test2.json', 'r')
        json_load3 = json.load(json_open)
        '''
        

        new_user=Recipe(recipe_image,recipeURL)
        #new_user=Recipe(recipe_image,recipeURL)
        db.session.add(new_user)
        db.session.commit()
    #取得の部分だけインデントを変更→レシピのランキングが４位まで表示された
    all_recipes=Recipe.query.all()
    print(type(all_recipes))
    result_2=recipe_schema.dump(all_recipes)
    return jsonify(result_2)
    
if __name__ == '__main__':
    app.run(debug=True,port=5000)