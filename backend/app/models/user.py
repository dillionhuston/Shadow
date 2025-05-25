from models.db import db
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import uuid
import os

class User(db.Model):
    __tablename__ = 'user' 
    id = db.Column(db.String(36), primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)
    key = db.Column(db.String(32), nullable=False)  
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    @staticmethod
    def add_user(username, email, password):
        user = User(
            id=str(uuid.uuid4()),
            username=username,
            email=email,
            password=User.generate_hash(password),
            key=os.urandom(32).hex()[:32]  
        )
        db.session.add(user)
        return user
    

    

    @staticmethod
    def generate_hash(password):
        return generate_password_hash(password)

    @staticmethod
    def verify_hash(password, hash):
        return check_password_hash(hash, password)

    def get_key(self):
        return self.key