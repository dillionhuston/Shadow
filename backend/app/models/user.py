from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from models.db import db
import uuid

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    encryption_key_hash = db.Column(db.String(128), nullable=False)  # Store only hash of key
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    @staticmethod
    def generate_hash(password)-> str:
        """Generate hash of password"""
        return generate_password_hash(password)

    @staticmethod
    def verify_hash(password, hash):
        """Verify password against hash"""
        return check_password_hash(hash, password)

    @staticmethod
    def hash_encryption_key(key):
        """
        Create a hash of the encryption key
        This doesn't store the raw key but can verify it later
        """
        return generate_password_hash(key)
        
    @staticmethod
    def verify_encryption_key(key, key_hash):
        """Verify encryption key against stored hash"""
        return check_password_hash(key_hash, key)