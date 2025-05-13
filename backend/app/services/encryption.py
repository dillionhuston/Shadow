import os
import base64
from Crypto.Cipher import AES
from werkzeug.utils import secure_filename
from services.storage import FileStorageService
from models.file import File
from config import Config

file_service = FileStorageService()

class EncryptionService:
    class EncryptionError(Exception):
        pass

    @staticmethod
    def encrypt(file: str, filename: str, user_id: int) -> str:
        from app.models.user import User

        key = User.get_key(user_id)
        if len(key) not in (16, 24, 32):
            raise EncryptionService.EncryptionError("Invalid encryption key")

        data = base64.b64decode(file)
        cipher = AES.new(key, AES.MODE_GCM)
        nonce = cipher.nonce
        ciphertext, tag = cipher.encrypt_and_digest(data)
        encrypted_data = nonce + tag + ciphertext

        safe_name = secure_filename(filename) + '.enc'
        EncryptionService.save_file(encrypted_data, safe_name, user_id)
        return safe_name

    @staticmethod
    def save_file(data: bytes, filename: str, user_id: int):
        file_path = os.path.join(Config.ENCRYPTED_FILE_PATH, filename)
        file_service.save_file(data, filename)
        File().add_file(filename=filename, filepath=file_path, user_id=user_id)

    @staticmethod
    def decrypt(filepath: str, user_id: int) -> bytes:
        from app.models.user import User
        key = User.get_key(user_id)
        file_data = file_service.retrieve_file(filepath)
        nonce = file_data[:16]
        tag = file_data[16:32]
        ciphertext = file_data[32:]
        cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
        return cipher.decrypt_and_verify(ciphertext, tag)