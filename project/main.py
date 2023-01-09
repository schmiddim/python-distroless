


from flask import Flask
import json
import requests as r
app = Flask(__name__)
import socket
import os

@app.route('/', methods=['GET'])
def landing_page():

    r.get("http://www.google.de")
    return json.dumps({'success': True}), 200, {'ContentType': 'application/json'}



if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
