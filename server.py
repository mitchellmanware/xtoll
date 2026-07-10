import os

import pandas as pd
from flask import Flask, jsonify, render_template, send_file, send_from_directory

app = Flask(__name__, template_folder=".", static_folder=".", static_url_path="")


# Route for the main dashboard page
@app.route("/")
def index():
    return render_template("index.html")


# Explicit route to serve the GeoJSON files with correct MIME type
@app.route("/xtoll.geojson")
def get_geojson():
    try:
        # Using explicit response to ensure UTF-8 encoding
        with open(os.path.join("data", "xtoll.geojson"), "r", encoding="utf-8") as f:
            content = f.read()
        return app.response_class(content, mimetype="application/json")
    except Exception as e:
        return f"Error reading xtoll.geojson: {str(e)}", 404


@app.route("/states.geojson")
def get_states():
    try:
        return send_from_directory(
            "data", "states.geojson", mimetype="application/json"
        )
    except Exception as e:
        return str(e), 404


@app.route("/us.geojson")
def get_us():
    try:
        return send_from_directory("data", "us.geojson", mimetype="application/json")
    except Exception as e:
        return str(e), 404


@app.route("/mortality_data")
def get_mortality_data():
    try:
        if os.path.exists("data/df_mortality.csv"):
            df = pd.read_csv("data/df_mortality.csv")
            # Replace NaN values with None, which jsonify converts to null
            df = df.where(pd.notnull(df), None)
            return jsonify(df.to_dict(orient="records"))
        else:
            return "File not found", 404
    except Exception as e:
        return str(e), 500


# Route to handle file downloads
@app.route("/download/<filename>")
def download_file(filename):
    try:
        # Security check: only allow specific files to be downloaded
        allowed_files = ["xtoll.geojson", "states.geojson", "df_mortality.csv"]
        if filename in allowed_files:
            return send_file(os.path.join("data", filename), as_attachment=True)
        else:
            return "File not authorized for download", 403
    except Exception as e:
        return f"Error downloading file: {str(e)}", 404


if __name__ == "__main__":
    print("Starting XToll Dashboard Server...")
    print("Access your dashboard at: http://127.0.0.1:5000")
    app.run(debug=True, port=5000)
