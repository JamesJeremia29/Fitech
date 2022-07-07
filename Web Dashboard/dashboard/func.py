from collections import Counter

def count_list(query,condition):
    for doc in query:
        print()
    return 

def q_to_list(query,column='',nest=False):
    data_col = query.stream()
    if column!='':
        data = []
        if type(column) is list:
            for dta in data_col:
                dta_dict = dta.to_dict()
                temp = {}
                for col in column:
                    temp[col] = dta_dict[col]
                data.append(temp)
        else:
            if nest:
                data = [data.to_dict()[column] for data in data_col]
            else:
                for dta in data_col:
                    dta_dict = dta.to_dict()
                    row = {column:dta_dict[column]}
                    data.append(row)
            
        return data
    data = [data.to_dict() for data in data_col]
    return data


def to_graph_data(data,column,type='count',time_series=True):
    result = []
    history=''
    for d in range(len(data)):
        date = str(data[d]['time_started'])[:10]
        if date == history:
            temp['value'] += 1
        else:
            if d!=0:
                result.append(temp)
            temp={
                'date':date,
                'value':1
            }
        history=date
    result.append(temp)
    return result
    
def to_graph_data_2(data,column,type='count',time_series=True):
    result = {}
    temp = []
    count = {}
    x = []
    y = []
    for d in data:
        date = str(d['time_started'])[:10]
        if date in temp:
            count[date] += 1
        else:
            temp.append(date)
            count[date] = 1
    for key,value in count.items():
        x.append(key)
        y.append(value)
    return {'x':x,'y':y}
    
#query 4
def get_column_data(query,condition='', in_dict = False):
    temp = q_to_list(query)
    temp_li = []
    for dt in temp:
        temp_li.append(eval(f'dt["{condition}"]'))
    if in_dict:
        return get_unique_dict(temp_li)
    return get_unique(temp_li)

def get_unique(data):
    return list(set(data))

def get_unique_dict(data):
    return dict(Counter(data).most_common()[:5])

#query 6
def get_column_count(data, condition):
    return

# query 3
def get_dict_column_data(target,source):#condition=''):
    dt_t = unnest(q_to_list(target,'exercises',True))
    dt_s = q_to_list(source,['id','exercise_name'])
    data={}
    for t in dt_t:
        for x in dt_s:
            if x['id'] == t['exercise_id']:
                if x['exercise_name'] in data:
                    data[x['exercise_name']] += 1   #int(t['reps'])   FOR REPS
                else:
                    data[x['exercise_name']] = 1    #int(t['reps'])    FOR REPS
    return data


def unnest(arr):
    res = []
    for row in range(len(arr)):
        for dt in arr[row]:
            res.append(dt)
    return res

    



#query_watch = query1.on_snapshot(on_snapshot)
#query_watch2 = query2.on_snapshot(on_snapshot_2)
#query_watch3 = user_data.on_snapshot(on_snapshot)
#query_watch4 = recommend_data.on_snapshot(on_snapshot)

