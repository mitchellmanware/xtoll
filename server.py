################################################################################
# Import libraries
import json

import pandas
from flask import Flask, jsonify, render_template, request

################################################################################
# Initate flask app
app = Flask(__name__)

################################################################################
# Import XToll data
GEOJSON_FILENAME = "xtoll.geojson"
COMPLETE_GEOJSON = {}

with open(GEOJSON_FILENAME, "r") as f:
    COMPLETE_GEOJSON = json.load(f)

################################################################################
# Import state boundary data
STATE_GEOJSON_FILENAME = "states.geojson"
STATE_GEOJSON = {}

with open(STATE_GEOJSON_FILENAME, "r") as f:
    STATE_GEOJSON = json.load(f)

################################################################################
# Import variable metadata
VARIABLE_METADATA_FILENAME = "variables.csv"
VARIABLE_METADATA = []
df = pandas.read_csv(VARIABLE_METADATA_FILENAME)
VARIABLE_METADATA = df.to_dict("records")

################################################################################
# Pages
################################################################################


################################################################################
# Index
@app.route("/")
def index():
    return render_template("index.html")


################################################################################
# Map(s)
@app.route("/map")
def map_page_renderer():
    variable_name = request.args.get("variable_name", "gap_all")
    return render_template(
        "map.html",
        variable_name=variable_name,
    )


################################################################################
# Variables
@app.route("/variables")
def variables_page_renderer():
    headers = VARIABLE_METADATA[0].keys() if VARIABLE_METADATA else None
    return render_template(
        "variables.html",
        metadata=VARIABLE_METADATA,
        headers=headers,
    )


################################################################################
# XToll data
@app.route("/data")
def data_api():
    """API endpoint to serve the county data."""
    return jsonify(COMPLETE_GEOJSON)


################################################################################
# States data
@app.route("/states_data")
def states_data_api():
    """API endpoint to serve the state border data (New)."""
    return jsonify(STATE_GEOJSON)


################################################################################
# Deploy
if __name__ == "__main__":
    app.run(debug=True)
