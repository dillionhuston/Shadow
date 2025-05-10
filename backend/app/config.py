import os

class Config:
    SECRET_KEY = os.urandom(24)
    SQLALCHEMY_DATABASE_URI = 'sqlite:///site.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    ENCRYPTED_FILE_PATH = os.path.join(os.getcwd(), 'backend/app/encrypted_files')
    JWT_SECRET_KEY = os.urandom(24)

    @staticmethod
    def init_app():
        os.makedirs(Config.ENCRYPTED_FILE_PATH, exist_ok=True)