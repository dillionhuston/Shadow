import os
import logging
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from hashlib import pbkdf2_hmac
from werkzeug.utils import secure_filename
from services.storage import FileStorageService
from models.file import File
from config import Config

logger = logging.getLogger(__name__)
file_service = FileStorageService()

class EncryptionService:
    @staticmethod
    def generate_key(password: str) -> tuple[bytes, bytes]:
        salt = get_random_bytes(16)
        iterations = 100_000
        key = pbkdf2_hmac('sha256', password.encode(), salt, iterations, dklen=32)
        logger.debug("Key generated with PBKDF2.")
        return key, salt

    @staticmethod
    def encrypt(file, filename: str, user_id: int):
        from app.models.user import User
        user = User.query.get(user_id)
        key = user.get_key()

        if len(key) not in (16, 24, 32):
            logger.error(f"Invalid key length for user {user_id}: {len(key)} bytes")
            raise ValueError("Invalid encryption key length.")

        try:
            data = file.read()
            cipher = AES.new(key, AES.MODE_GCM)
            nonce = cipher.nonce
            ciphertext, tag = cipher.encrypt_and_digest(data)
            encrypted_data = nonce + tag + ciphertext

            safe_name = secure_filename(filename) + '.enc'
            EncryptionService.save_file(encrypted_data, safe_name, user_id)
            logger.info(f"File encrypted: {safe_name}")
        except Exception as e:
            logger.error(f"Encryption failed for {filename}: {e}")
            raise

    @staticmethod
    def save_file(data: bytes, filename: str, user_id: int):
        file_path = os.path.join(Config.ENCRYPTED_FILE_PATH, filename)
        try:
            file_service.save_file(data, filename)
            File().add_file(filename=filename, filepath=file_path, user_id=user_id)
            logger.info(f"Saved encrypted file: {filename} at {file_path}")
        except Exception as e:
            logger.error(f"Failed to save file {filename}: {e}")
            raise

    @staticmethod
    def decrypt(filepath: str, user_id: int) -> bytes:
        from app.models.user import User
        user = User.query.get(user_id)
        key = user.get_key()

        try:
            file_data = file_service.retrieve_file(filepath)
            nonce = file_data[:16]
            tag = file_data[16:32]
            ciphertext = file_data[32:]

            cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
            plaindata = cipher.decrypt_and_verify(ciphertext, tag)
            logger.info(f"Decryption completed for {filepath}")
            return plaindata
        except Exception as e:
            logger.error(f"Decryption failed for {filepath}: {e}")
            raise