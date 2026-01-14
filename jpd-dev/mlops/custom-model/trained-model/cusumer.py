#! /usr/bin/env python3
from transformers import pipeline

from huggingface_hub import snapshot_download
snapshot_download(
    repo_id="slash-bert-base-cased", revision="1", etag_timeout=1500000000
)

# fill-mask：将返回一个FillMaskPipeline
unmasker = pipeline('fill-mask', model='slash-bert-base-cased', revision="1")
print(unmasker("The goal of life is [MASK]."))

