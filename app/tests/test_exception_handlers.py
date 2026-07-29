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
