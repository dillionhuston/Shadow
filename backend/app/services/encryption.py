from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
import base64
import os
import uuid
from config import Config

class EncryptionService:
    class EncryptionError(Exception):
        pass

    @staticmethod
    def encrypt(data, filename, user_id, key):
        try:
            if isinstance(data, str):
                data_bytes = base64.b64decode(data) 
            else:
                data_bytes = data

            if not isinstance(key, bytes):
                key = key.encode('utf-8')[:32].ljust(32, b'\0') # pad 32

            cipher = AES.new(key, AES.MODE_EAX)
            nonce = cipher.nonce
            ciphertext, tag = cipher.encrypt_and_digest(data_bytes)
            encrypted_filename = f"{uuid.uuid4()}_{filename}.enc"
            file_path = os.path.join(Config.ENCRYPTED_FILE_PATH, encrypted_filename)

            os.makedirs(Config.ENCRYPTED_FILE_PATH, exist_ok=True)

            with open(file_path, 'wb') as f:
                f.write(nonce + tag + ciphertext)
            return encrypted_filename
        
        except Exception as e:
            raise EncryptionService.EncryptionError(f"Encryption failed: {str(e)}")

    @staticmethod
    def decrypt(encrypted_filename, user_id, key):
        """
        Decrypt file from encrypted_files/.
        """
        try:
            file_path = os.path.join(Config.ENCRYPTED_FILE_PATH, encrypted_filename)

            if not isinstance(key, bytes):
                key = key.encode('utf-8')[:32].ljust(32, b'\0')

            with open(file_path, 'rb') as f:
                encrypted_data = f.read()

            nonce = encrypted_data[:16]
            tag = encrypted_data[16:32]
            ciphertext = encrypted_data[32:]

            cipher = AES.new(key, AES.MODE_EAX, nonce=nonce)
            data = cipher.decrypt_and_verify(ciphertext, tag)
            return data
        except Exception as e:
            raise EncryptionService.EncryptionError(f"Decryption failed: {str(e)}")