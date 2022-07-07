import pickle
import numpy as np
import pandas as pd

MODEL_PATH = 'dashboard/models/recommender_v3.bin'
DATA_PATH = 'dashboard/data/users_pref.csv'
PREDICT_PATH = 'dashboard/data/user_data_pred.csv'

with open(MODEL_PATH,'rb') as md:
    knn = pickle.load(md)


df = pd.read_csv(DATA_PATH)
df_test = pd.read_csv(PREDICT_PATH)

def test_data_split(df):
    X = df.drop(['prediction'],axis=1).values
    y = df['prediction'].values
    return X,y

def predict_one(data):
    data = np.array(data)
    _, indices = knn.kneighbors(data)
    ranks = []
    for i,is_zero in enumerate(data[0]==0):
        if is_zero:
            temp = np.array([])
            for j in indices[0]:
                temp = np.append(temp,df.loc[j][i])
            rank = [df.columns[i],temp.mean()]
            ranks.append(rank)
    return sorted(ranks,key=lambda x: x[1], reverse=True)[0][0]

if __name__ == '__main__':
    X_train , _ = test_data_split(df_test)
    print(predict_one(X_train[0].reshape(1,-1)))