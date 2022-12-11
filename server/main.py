from flask import Flask, send_file, jsonify
app = Flask(__name__)

def transcribe(video_id):
    
    import os
    import subprocess
    import pandas as pd
    from pytube import YouTube
    from stable_whisper import load_model
    from functools import reduce
    
    # Download audio stream of YouTube video
    video = YouTube(f"https://www.youtube.com/watch?v={video_id}")

    video\
    .streams\
    .filter(only_audio=True)\
    .filter(file_extension='mp4')\
    .order_by('abr')\
    .last()\
    .download(output_path = f'{os.getcwd()}/mp4/{video_id}/', filename = f'{video_id}.mp4')
    
    # Convert MP4 to WAV
    subprocess.run([f"audioconvert convert mp4/{video_id}/ wav/ --output-format .wav"], shell = True)
    
    # Split Vocals / Instrumentals
    subprocess.run([f"demucs --two-stems=vocals 'wav/{video_id}.wav'"], shell = True)
    
    # Transcribe Lyrics
    transcription_model = load_model('medium')
    segments = transcription_model.transcribe(f"{os.getcwd()}/separated/htdemucs/{video_id}/vocals.wav")['segments']
    
    lyric_lines = [segment['text'] for segment in segments]
    word_ts = pd.DataFrame(
        reduce(lambda x,y: x + y, [segment['word_timestamps'] for segment in segments])
    ).drop('token', axis = 1)\
    .to_json(orient = 'records')
    instrumental_filepath = f"{os.getcwd()}/separated/htdemucs/{video_id}/no_vocals.wav"
    
    return {
        'lyric_lines': lyric_lines,
        'word_timestamps': word_ts,
        'instrumental_filepath': instrumental_filepath
    }

@app.route('/karaoke/<string:video_id>/')
def get_karaoke(video_id):
    try:
        output = transcribe(video_id)
        response = jsonify(output)
    finally:
        pass
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
