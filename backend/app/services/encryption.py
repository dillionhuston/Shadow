import os
import base64
from Crypto.Cipher import AES
from werkzeug.utils import secure_filename
from services.storage import FileStorageService
from models.file import File
from config import Config
import logging

logger = logging.getLogger(__name__)
file_service = FileStorageService()

class EncryptionService:
    class EncryptionError(Exception):
        """Custom exception for encryption errors."""
        pass

    @staticmethod
    def encrypt(file: str, filename: str, user_id: int, user_key: bytes) -> str:
        """Encrypt a base64-encoded file and save it."""
        try:
            if len(user_key) not in Config.VALID_KEY_LENGTHS:
                raise EncryptionService.EncryptionError("Invalid encryption key length")

            data = base64.b64decode(file)
            cipher = AES.new(user_key, AES.MODE_GCM)
            nonce = cipher.nonce
            ciphertext, tag = cipher.encrypt_and_digest(data)
            encrypted_data = nonce + tag + ciphertext

            safe_name = secure_filename(filename) + '.enc'
            EncryptionService.save_file(encrypted_data, safe_name, user_id)
            logger.info(f"File encrypted for user {user_id}: {safe_name}")
            return safe_name
        
        except Exception as e:
            
            logger.error(f"Encryption failed for user {user_id}: {str(e)}")
            raise EncryptionService.EncryptionError(f"Encryption failed: {str(e)}")

    @staticmethod
    def save_file(data: bytes, filename: str, user_id: int):
        """Save encrypted file to storage and database."""
        try:
            file_path = os.path.join(Config.ENCRYPTED_FILE_PATH, filename)
            file_service.save_file(data, filename)
            File().add_file(filename=filename, filepath=file_path, user_id=user_id)
            logger.info(f"File saved for user {user_id}: {filename}")

        except Exception as e:

            logger.error(f"File save failed for user {user_id}: {str(e)}")
            raise EncryptionService.EncryptionError(f"File save failed: {str(e)}")

    @staticmethod
    def decrypt(filepath: str, user_id: int, user_key: bytes) -> bytes:
        """Decrypt a file using user's key."""
        try:
            file_data = file_service.retrieve_file(filepath)
            nonce = file_data[:16]
            tag = file_data[16:32]
            ciphertext = file_data[32:]

            cipher = AES.new(user_key, AES.MODE_GCM, nonce=nonce)
            decrypted_data = cipher.decrypt_and_verify(ciphertext, tag)
            logger.info(f"File decrypted for user {user_id}: {filepath}")
            return decrypted_data
        

        except Exception as e:
            logger.error(f"Decryption failed for user {user_id}: {str(e)}")
            raise EncryptionService.EncryptionError(f"Decryption failed: {str(e)}")