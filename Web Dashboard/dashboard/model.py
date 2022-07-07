from dashboard import app
import threading
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("./dashboard/tryal-key.json")
fr_app = firebase_admin.initialize_app(cred)
db = firestore.client()
user_data=  db.collection('Users')
exercise_data = db.collection('exercise')
workout_data= db.collection('workout')
recommend_data= db.collection('recommendation')


query1 = workout_data.order_by("time_started")
#CHANGE THE QUERY TO >=
query_wo_tday= workout_data.where(u'time_started',u'<=',datetime.now().replace(minute=00, hour=00, second=00,microsecond=0)) 
#query1 = workout_data.where(u'time_started',u'>=',datetime.now().replace(minute=00, hour=00, second=00,microsecond=0))
query2 = user_data.where(u'active',u'==',True)
join_q3 = exercise_data
#query3 = workout_data.where(u'time_started',u'>=',datetime.now().replace(minute=00, hour=00, second=00,microsecond=0))
#query4 = workout_data.where(u'time_started',u'>=',datetime.now().replace(minute=00, hour=00, second=00,microsecond=0))
query5 = recommend_data
query6 = user_data
#query1 = workout_data.where() sum(1 for x in generator)

#data1 = q_to_list(query1)
#data2 = len(q_to_list(query2))





