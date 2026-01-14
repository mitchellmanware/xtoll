from flask import Flask, render_template, send_from_directory

app = Flask(__name__, template_folder=".", static_folder=".", static_url_path="")


# Route for the main dashboard page
@app.route("/")
def index():
    return render_template("index.html")


# Explicit route to serve the GeoJSON file with correct MIME type
@app.route("/xtoll2.geojson")
def get_geojson():
    try:
        return send_from_directory(".", "xtoll2.geojson", mimetype="application/json")
    except Exception as e:
        return str(e), 404


if __name__ == "__main__":
    print("Starting XToll Dashboard Server...")
    print("Access your dashboard at: http://127.0.0.1:5000")
    app.run(debug=True, port=5000)
