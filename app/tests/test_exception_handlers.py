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

    @test_app.get("/raise-user-exists")

    @test_app.get("/raise-auth-error")

    @test_app.get("/raise-incorrect-password")

    @test_app.get("/raise-file-error")

    @test_app.get("/raise-encryption-error")

    @test_app.get("/raise-database-error")

    @test_app.get("/raise-dashboard-error")

    @test_app.get("/raise-unhandled")

    @test_app.get("/raise-custom-detail")

    return test_app