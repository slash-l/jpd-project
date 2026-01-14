#! /usr/bin/env python3

from huggingface_hub import HfApi
api = HfApi()
api.upload_folder(
    folder_path="./trained-model", 
    repo_id="slash-bert-base-cased", # defines the name under which model will be saved in the local repo. (models--${model_name})
    revision="1", # represents git revision under which files are stored (main by default) (snapshots/${revision}/...files)
    repo_type="model"
)


