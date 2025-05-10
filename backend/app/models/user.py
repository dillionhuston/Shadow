
from werkzeug.security import generate_password_hash, check_password_hash
from models.db import db
from services.encryption import EncryptionService

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)
    key = db.Column(db.LargeBinary, nullable=False)
    salt = db.Column(db.LargeBinary, nullable=False)

    files = db.relationship('File', backref='user', lazy=True)

    @classmethod
    def add_user(cls, username, email, password):
        key, salt = EncryptionService.generate_key(password)
        hashed_password = generate_password_hash(password, method='pbkdf2:sha256')
        user = cls(
            username=username,
            email=email,
            password=hashed_password,
            key=key,
            salt=salt
        )
        db.session.add(user)
        db.session.commit()
        return user

    @classmethod
    def verify_hash(cls, password, hashed_password):
        return check_password_hash(hashed_password, password)

    def get_key(self):
        return self.key