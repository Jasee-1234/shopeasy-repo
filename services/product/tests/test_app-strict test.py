"""
Basic tests for product-service. Run locally with:
  pip install -r requirements.txt pytest --break-system-packages
  pytest tests/ -v

These also run automatically in the CodeBuild buildspec.yml before the
Docker image gets built - so a broken app never even reaches ECR.
"""
import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from app import app


def client():
    app.config["TESTING"] = True
    return app.test_client()


def test_health_endpoint_returns_ok():
    c = client()
    res = c.get("/health")
    assert res.status_code == 200
    assert res.get_json()["status"] == "ok"


def test_products_endpoint_returns_a_list():
    c = client()
    res = c.get("/products")
    assert res.status_code == 200
    body = res.get_json()
    assert "products" in body
    assert isinstance(body["products"], list)
    assert len(body["products"]) > 0


def test_each_product_has_required_fields():
    c = client()
    res = c.get("/products")
    for product in res.get_json()["products"]:
        assert "id" in product
        assert "name" in product
        assert "price" in product
        assert isinstance(product["price"], (int, float))


def test_root_endpoint_identifies_the_service():
    c = client()
    res = c.get("/")
    assert res.status_code == 200
    assert res.get_json()["service"] == "product-service"
