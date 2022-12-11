from flask import Flask
app = Flask(__name__)

@app.route('/karaoke/<string:url>/')
def get_karaoke(url):
    return url

app.run()
