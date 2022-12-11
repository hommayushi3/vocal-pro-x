#!/bin/bash
git clone https://github.com/hommayushi3/vocal-pro-x.git
cd vocal-pro-x
conda create -n music python=3.8
conda activate music
conda deactivate
conda deactivate
conda activate music
pip install -r requirements.txt
pip install gunicorn torchaudio==0.12.0 torch==1.12.1 triton==2.0.0.dev20221120
pkill gunicorn
cd server
gunicorn --bind 0.0.0.0:5000 main:app --timeout 600
