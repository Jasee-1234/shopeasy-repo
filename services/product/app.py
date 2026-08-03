import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import boto3
from boto3.dynamodb.conditions import Attr

app = Flask(__name__)

# Allow the frontend (S3 website or CloudFront - whichever you're using) to
# call this API. Set ALLOWED_ORIGIN to that exact URL in ecs.tf; "*" here is
# just a safe fallback default, not what should actually run in ECS.
CORS(app, resources={r"/*": {"origins": os.environ.get("ALLOWED_ORIGIN", "*")}})

# NOTE: this must match whatever key ecs.tf's environment block actually
# uses for this container. Pick ONE name project-wide - this file assumes
# DYNAMODB_TABLE since that's what order-service already uses.
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
TABLE_NAME = os.environ.get("DYNAMODB_TABLE", "shopeasy-main")

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(TABLE_NAME)

# NOTE: lowercase, matching what's used below. If any existing seed data
# was written with "PRODUCT" (uppercase), it will not show up until it's
# re-written or migrated to match this exact string.
ENTITY_TYPE = "product"


def item_to_product(item):
    """Convert a DynamoDB item into the JSON shape the frontend expects."""
    image = item.get("image")
    return {
        "id": item.get("id"),
        "productId": item.get("id"),
        "sku": item.get("sku", item.get("id")),
        "name": item.get("name"),
        "description": item.get("description", ""),
        "price": float(item.get("price", 0)),
        "currency": item.get("currency", "USD"),
        "unit": item.get("unit", "each"),
        "category": item.get("category", "default"),
        "stock": int(item["stock"]) if item.get("stock") is not None else None,
        # Built from a filename at READ time, not stored as a full URL at
        # write time - survives a bucket/domain/CloudFront change with zero
        # data migration.
        "imageUrl": item.get("imageUrl") or (f"images/{image}" if image else ""),
        "isActive": item.get("isActive", True),
    }


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "product-service"}), 200


@app.route("/products", methods=["GET"])
def list_products():
    try:
        response = table.scan(FilterExpression=Attr("entity_type").eq(ENTITY_TYPE))
        items = response.get("Items", [])

        while "LastEvaluatedKey" in response:
            response = table.scan(
                FilterExpression=Attr("entity_type").eq(ENTITY_TYPE),
                ExclusiveStartKey=response["LastEvaluatedKey"],
            )
            items.extend(response.get("Items", []))

        products = [
            item_to_product(item) for item in items
            if item.get("isActive", True) is not False
        ]
        return jsonify({"products": products}), 200
    except Exception as e:
        print("Error reading products from DynamoDB:", str(e))
        return jsonify({"error": "Failed to load products"}), 500


@app.route("/products/<product_id>", methods=["GET"])
def get_product(product_id):
    try:
        response = table.get_item(Key={"id": product_id})
        item = response.get("Item")
        if not item or item.get("entity_type") != ENTITY_TYPE:
            return jsonify({"error": "Product not found"}), 404
        return jsonify(item_to_product(item)), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/products", methods=["POST"])
def create_product():
    """
    Create/seed a product. Example body:
    {
      "productId": "prod-001", "sku": "SKU-10221", "name": "Garden Hose 20m",
      "price": 45.99, "unit": "each", "stock": 24, "image": "hose.jpg"
    }
    """
    data = request.get_json(silent=True) or {}
    product_id = data.get("productId") or data.get("id")

    if not product_id:
        return jsonify({"error": "productId is required"}), 400
    if not data.get("name"):
        return jsonify({"error": "name is required"}), 400
    if data.get("price") is None:
        return jsonify({"error": "price is required"}), 400

    item = {
        "id": product_id,
        "entity_type": ENTITY_TYPE,
        "sku": data.get("sku", product_id),
        "name": data["name"],
        "description": data.get("description", ""),
        "price": float(data["price"]),
        "currency": data.get("currency", "USD"),
        "unit": data.get("unit", "each"),
        "category": data.get("category", "default"),
        "stock": int(data.get("stock", 0)),
        "image": data.get("image", ""),
        "isActive": bool(data.get("isActive", True)),
    }

    table.put_item(Item=item)
    return jsonify({"product": item_to_product(item)}), 201


@app.route("/")
def root():
    return jsonify(service="product-service", message="ShopEasy product API"), 200


if __name__ == "__main__":
    # debug=False always - this container also runs in ECS, not just locally
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=False)
