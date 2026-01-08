import os
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from openai import OpenAI
from dotenv import load_dotenv

# Load .env
load_dotenv()

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
def instant():
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    message = """
You are on a website that has just been deployed to production for the first time!
Please reply with an enthusiastic announcement to welcome visitors to the site, explaining that it is live on production for the first time!
"""

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": message}],
    )

    reply = response.choices[0].message.content.replace("\n", "<br/>")

    return f"""
    <html>
        <head><title>Live in an Instant!</title></head>
        <body>
            <p>{reply}</p>
        </body>
    </html>
    """
