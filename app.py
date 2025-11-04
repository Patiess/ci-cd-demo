from flask import Flask
app = Flask(__name__)

@app.get("/")
def hello():
    return "Ez az automatikus CI/CD folyamat v2.0!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
