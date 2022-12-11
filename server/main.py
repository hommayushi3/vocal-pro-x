from flask import Flask, send_file
app = Flask(__name__)

@app.route('/karaoke/<string:url>/')
def get_karaoke(url):
    try:
        with open("a.txt", "w+") as f:
            f.write("hello")
        response = send_file('a.txt')
        response.headers['lyrics'] = "a"
    finally:
        import os
        os.remove("a.txt")
    return response

if __name__ == '__main__':
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app. This
    # can be configured by adding an `entrypoint` to app.yaml.
    # Flask's development server will automatically serve static files in
    # the "static" directory. See:
    # http://flask.pocoo.org/docs/1.0/quickstart/#static-files. Once deployed,
    # App Engine itself will serve those files as configured in app.yaml.
    app.run(host='127.0.0.1', port=8080, debug=True)
