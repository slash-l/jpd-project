#! /usr/bin/env python3
from transformers import pipeline

from huggingface_hub import snapshot_download
snapshot_download(
    # repo_id="google-bert/bert-base-chinese", revision="c30a6ed22ab4564dc1e3b2ecbf6e766b0611a33f", 
    repo_id="google-bert/bert-base-chinese", revision="main",
    allow_patterns="model.safetensors",
    etag_timeout=1500000000
)

pipe = pipeline("fill-mask", model="google-bert/bert-base-chinese")
print(pipe("北京是[MASK]国的首都。")) 

