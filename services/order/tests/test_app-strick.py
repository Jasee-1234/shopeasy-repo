"""
Basic tests for order-service. Uses a fake in-memory DynamoDB (moto) so
these tests never touch real AWS - fast, free, and safe to run anywhere,
including inside CodeBuild before an image gets pushed.

Run locally with:
  pip install -r requirements.txt pytest moto --break-system-packages
  pytest tests/ -v
"""
import sys
import os
import boto3
import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

try:
    from moto import mock_aws
    HAS_MOTO = True
except ImportError:
    HAS_MOTO = False


@pytest.mark.skipif(not HAS_MOTO, reason="moto not installed - run: pip install moto")
@mock_aws
def test_create_order_writes_to_dynamodb():
    # Create the fake table first, matching what Terraform's real table looks like
    ddb = boto3.client("dynamodb", region_name="us-east-1")
    ddb.create_table(
        TableName="shopeasy-transactions",
        KeySchema=[{"AttributeName": "transaction_id", "KeyType": "HASH"}],
        AttributeDefinitions=[{"AttributeName": "transaction_id", "AttributeType": "S"}],
        BillingMode="PAY_PER_REQUEST",
    )

    os.environ["DYNAMODB_TABLE"] = "shopeasy-transactions"
    from app import app

    app.config["TESTING"] = True
    client = app.test_client()

    res = client.post("/orders", json={"product_id": 1, "quantity": 2})
    assert res.status_code == 201
    body = res.get_json()["order"]
    assert body["product_id"] == "1"
    assert body["quantity"] == "2"
    assert "transaction_id" in body


def test_health_endpoint_returns_ok():
    from app import app
    app.config["TESTING"] = True
    res = app.test_client().get("/health")
    assert res.status_code == 200
    assert res.get_json()["status"] == "ok"
