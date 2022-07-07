import pickle
import numpy as np
import pandas as pd
from sklearn import neighbors

MODEL_PATH = 'dashboard/models/recommender_v3.bin'
DATA_PATH = 'dashboard/data/users_pref.csv'

df = pd.read_csv(DATA_PATH)
from sklearn.neighbors import NearestNeighbors

def training_data(df):

    knn = NearestNeighbors(metric='correlation', algorithm='brute',n_neighbors=4)

    knn.fit(df.values)

    return knn

knn = training_data(df)

with open(MODEL_PATH,'wb') as md:
    model = pickle.dump(knn, md)
    print('done')