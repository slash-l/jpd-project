#! /usr/bin/env python3

from openai import OpenAI

client = OpenAI(
  api_key="cmVmdGtuOjAxOjE3OTgwMzc3MTU6MVNmQWdwSjNlZjB5TnpFbHhReUpyMkJBUDhz",
  base_url="https://models.soleng.qwak.ai/v1"
)

response = client.chat.completions.create(
  model="openai-model/gpt-5-nano",
  messages=[
    {"role": "system", "content": "You are a helpful assistant."},
    {
      "role": "user",
      "content": "Explain to me how AI works in one sentence"
    }
  ]
)

print(response.choices[0].message)
