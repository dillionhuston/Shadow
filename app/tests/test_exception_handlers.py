import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from app.exceptions.exceptions import (
    ServiceError,
    UserAlreadyExistsError,
    AuthenticationError,
    IncorrectPasswordError,
    FileError,
    EncryptionServiceError,
    DatabaseError,
    DashboardError,
)
from app.core.exception_handlers import service_exception_handler, unhandled_exception_handler

# Build a minimal test app that mirrors main.py's excpetion handler setup
# This avoids needing a database or any other infrastructure
def build_test_app() -> FastAPI:
    test_app = FastAPI()
    test_app.add_exception_handler(ServiceError, service_exception_handler)
    test_app.add_exception_handler(Exception, unhandled_exception_handler)

    @test_app.get("/raise-service-error")
    def raise_service_error():
        raise ServiceError()

    @test_app.get("/raise-user-exists")
    def raise_user_exists():
        raise UserAlreadyExistsError()

    @test_app.get("/raise-auth-error")
    def raise_auth_error():
        raise AuthenticationError()

    @test_app.get("/raise-incorrect-password")
    def raise_incorrect_password():
        raise IncorrectPasswordError()

    @test_app.get("/raise-file-error")
    def raise_file_error():
        raise FileError()

    @test_app.get("/raise-encryption-error")
    def raise_encryption_error():
        raise EncryptionServiceError()

    @test_app.get("/raise-database-error")
    def raise_database_error():
        raise DatabaseError()

    @test_app.get("/raise-dashboard-error")
    def raise_dashboard_error():
        raise DashboardError()

    @test_app.get("/raise-unhandled")
    def raise_unhandled():
        raise RuntimeError("Something unexpected happened")

    @test_app.get("/raise-custom-detail")
    def raise_custom_detail():
        raise ServiceError(detail="Custom error message", status_code=422)

    return test_app

@pytest.fixture
def client():
    return TestClient(build_test_app(), raise_server_exceptions=False)

# ServiceError base class

class TestServiceError:
    def test_returns_500_status_code(self, client):

    def test_rturns_json_detail_key(self, client):

    def test_returns_default_detail_message(self, client):

    def test_custom_detail_and_status_code(self, client):