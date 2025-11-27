from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "RoutePulse service online"

if __name__ == "__main__":
    # Bind to 0.0.0.0 so container is reachable from outside
    app.run(host="0.0.0.0", port=12144)
