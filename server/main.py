from flask import Flask, send_file, jsonify
app = Flask(__name__)
from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler, EulerDiscreteScheduler
import torch
import os
import subprocess
import pandas as pd
from pytube import YouTube
from stable_whisper import load_model
from functools import reduce
from shutil import rmtree
import pickle

image_idxs = {}

if not os.path.exists("wav"):
    os.mkdir("wav")

if not os.path.exists("mp4"):
    os.mkdir("mp4")

if not os.path.exists("lyrics"):
    os.mkdir("lyrics")


def transcribe(video_id):
    
    if not os.path.exists(f"mp4/{video_id}.mp4"):
        # Download audio stream of YouTube video
        video = YouTube(f"https://www.youtube.com/watch?v={video_id}")

        video\
        .streams\
        .filter(only_audio=True)\
        .filter(file_extension='mp4')\
        .order_by('abr')\
        .last()\
        .download(output_path = f'{os.getcwd()}/mp4/{video_id}/', filename = f'{video_id}.mp4')
    
    if not os.path.exists(f"wav/{video_id}.wav"):
        # Convert MP4 to WAV
        subprocess.run([f"audioconvert convert mp4/{video_id}/ wav/ --output-format .wav"], shell = True)
        
        # Split Vocals / Instrumentals
        subprocess.run([f"demucs --two-stems=vocals 'wav/{video_id}.wav'"], shell = True)
    
    # Transcribe Lyrics
    cache_path = f"lyrics/{video_id}.pkl"
    if os.path.exists(f"lyrics/{video_id}.pkl"):
        with open(cache_path, 'rb') as f:
            lyric_lines, word_ts = pickle.load(f)
    else:
        transcription_model = load_model('medium')
        segments = transcription_model.transcribe(f"{os.getcwd()}/separated/htdemucs/{video_id}/vocals.wav")['segments']
        lyric_lines = [segment['text'] for segment in segments]
        word_ts = pd.DataFrame(
            reduce(lambda x,y: x + y, [segment['word_timestamps'] for segment in segments])
        ).drop('token', axis = 1)\
        .to_json(orient = 'records')

        with open(cache_path, 'wb+') as f:
            pickle.dump((lyric_lines, word_ts), f)

    image_idxs[video_id] = []
    if os.path.exists("images"):
        rmtree("images")

    # Create images
    model_id = "stabilityai/stable-diffusion-2-1"

    pipe = StableDiffusionPipeline.from_pretrained(model_id, torch_dtype=torch.float16)
    pipe.scheduler = DPMSolverMultistepScheduler.from_config(pipe.scheduler.config)
    pipe = pipe.to("cuda")

    prompts = lyric_lines
    images = []

    combo_prompts = []
    prev_prompt = ""
    for i, prompt in enumerate(prompts):
        prev_prompt += prompt + " "
        if i % 2 == 1 or i == len(prompts) - 1:
            combo_prompts.append(prev_prompt)
            prev_prompt = ""

    batch_size = 8
    for i in range((len(combo_prompts) + batch_size - 1)//batch_size):
        prompt_batch = [p for p in combo_prompts[batch_size * i: batch_size * (i+1)]]
        images.extend(pipe(
            prompt_batch, negative_prompt=["words posters sign"] * len(prompt_batch),
            num_inference_steps=1, height=504, width=344).images)
    # Save images
    os.makedirs(f"images/{video_id}")
    for i, image in enumerate(images):
        path = f"images/{video_id}/{i}.png"
        image.save(path)
        image_idxs[video_id].append(path)

    return {
        'lyric_lines': lyric_lines,
        'word_timestamps': word_ts,
        'video_id': video_id,
        'image_urls': [f"http://34.95.221.65:5000/{path[:-4]}" for path in image_idxs[video_id]]
    }

@app.route('/images/<string:video_id>/<string:index>/')
def get_image(video_id, index):
    try:
        response = send_file(image_idxs[video_id][int(index)])
    finally:
        pass
    return response

@app.route('/karaoke/<string:video_id>/')
def get_karaoke(video_id):
    try:
        output = transcribe(video_id)
        response = jsonify(output)
    finally:
        pass
    return response

@app.route('/audio_files/<string:video_id>/')
def get_instrumental_file(video_id):
    try:
        import os
        instrumental_filepath = f"{os.getcwd()}/separated/htdemucs/{video_id}/no_vocals.wav"
        response = send_file(
            instrumental_filepath,
            mimetype = 'audio/wav'
        )
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
    app.run(host='0.0.0.0', port=5000, debug=True)
