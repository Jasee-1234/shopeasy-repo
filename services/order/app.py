import os
import uuid
from datetime import datetime, timezone
from flask import Flask, request, jsonify
from flask_cors import CORS
import boto3

app = Flask(__name__)

# Allow the frontend (CloudFront / localhost) to call this API
CORS(app, resources={r"/*": {"origins": os.environ.get("ALLOWED_ORIGIN", "*")}})

TABLE_NAME = os.getenv("TABLE_NAME", "shopeasy-dev-main")
REGION = os.getenv("AWS_REGION", "us-east-1")

dynamodb = boto3.resource("dynamodb", region_name=REGION)
table = dynamodb.Table(TABLE_NAME)


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


@app.route("/orders", methods=["POST"])
def create_order():
    try:
        data = request.get_json(silent=True) or {}

        product_id = data.get("product_id")
        quantity = data.get("quantity")

        # Basic validation
        if not product_id or quantity is None:
            return jsonify({"error": "product_id and quantity are required"}), 400

        transaction_id = str(uuid.uuid4())
        created_at = datetime.now(timezone.utc).isoformat()

        # Save order to DynamoDB (matches your table design)
        table.put_item(
            Item={
                "id": transaction_id,           # primary key
                "entity_type": "order",         # for the GSI
                "product_id": str(product_id),
                "quantity": int(quantity),
                "status": "confirmed",
                "created_at": created_at
            }
        )

        # Response shape that app.js expects
        return jsonify({
            "order": {
                "transaction_id": transaction_id,
                "product_id": str(product_id),
                "quantity": int(quantity),
                "status": "confirmed",
                "created_at": created_at
            }
        }), 201

    except Exception as e:
        print("Error saving order:", str(e))
        return jsonify({"error": "Failed to create order"}), 500


@app.route("/")
def root():
    return jsonify(service="order-service", message="ShopEasy order API"), 200


if __name__ == "__main__":
    port = int(os.getenv("PORT", 8080))
    app.run(host="0.0.0.0", port=port)