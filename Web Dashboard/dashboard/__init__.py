from flask import Flask 
from flask_cors import CORS, cross_origin

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'
app.config['secret_key']= '539dd33ccf3748f2aec5c04db8acd3eb'

from dashboard import routes,model