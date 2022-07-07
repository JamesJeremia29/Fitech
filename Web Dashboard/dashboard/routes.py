from flask import render_template,jsonify,request
from flask_cors import cross_origin
from dashboard import app
from dashboard.model import query1,query_wo_tday,query2,query5,query6, join_q3      
from dashboard.func import q_to_list,get_column_data,get_dict_column_data,unnest,to_graph_data,to_graph_data_2
from dashboard.ml_deploy import predict_one

@app.route('/')
def dashboard_page():
    global data2
    data1 = 'api1'
    data2 = len(q_to_list(query2))                                  
    data3 = get_dict_column_data(query_wo_tday,join_q3)
    data4 = len(get_column_data(query_wo_tday,'user_id'))           
    data5 = 'api2'
    data6 = get_column_data(query6,'country',in_dict=True)         
    data = [data1,data2,data3,data4,data5,data6]
    return render_template('index.html', data=data)

@app.route('/api/data1')
@cross_origin()
def data_for_graph():
    data1 = q_to_list(query1,column='time_started')
    data1 = to_graph_data(data1,column='')
    return jsonify(data1)

@app.route('/api/data2')
@cross_origin()
def data_for_graph_2():
    data5 = q_to_list(query5)
    return jsonify(data5)

@app.route('/api/recommend/<UID>',methods =['POST','GET'])
@cross_origin()
def recommend_exercise(UID=''):
    if UID == 'E20guSW4FGYCBQoFdSzPlozxuy43':
        data = [[0, 0, 1, 0, 1, 3, 0, 7, 1]]
    elif UID == 'HkGmuljACTVuhwVq9envC3ksJag2':
        data = [[0, 1, 5, 6, 0, 1, 3, 0, 0]]
    else:
        return jsonify()
    rec = predict_one(data)
    recommend_json = {'recommended':rec}
    return jsonify(recommend_json)