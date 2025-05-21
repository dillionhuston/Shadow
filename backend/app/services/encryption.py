# services/encryption.py

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import hashlib
import base64
import os

class EncryptionService:
   
    def _normalize_key(self, key: str) -> bytes:
        return hashlib.sha256(key.encode("utf-8")).digest()  

    
    def encrypt_login(self, username, email, password, key):
        normalized_key = self._normalize_key(key)
        aesgcm = AESGCM(normalized_key)
        nonce = os.urandom(12)
        plaintext = f'{username}:{email}:{password}'.encode()
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)
        return base64.b64encode(nonce + ciphertext).decode()

    def encrypt(self, data, filename, user_id, key):
        normalized_key = self._normalize_key(key)
        aesgcm = AESGCM(normalized_key)
        nonce = os.urandom(12)
        ciphertext = aesgcm.encrypt(nonce, data.encode(), None)
        encrypted_file = base64.b64encode(nonce + ciphertext).decode()
        filename_hash = hashlib.sha256((filename + str(user_id)).encode()).hexdigest()
        with open(f'encrypted/{filename_hash}.enc', 'w') as f:
            f.write(encrypted_file)
        return f'{filename_hash}.enc'

    def decrypt(self, encrypted_filename, user_id, key):
        normalized_key = self._normalize_key(key)
        aesgcm = AESGCM(normalized_key)
        with open(f'encrypted/{encrypted_filename}', 'r') as f:
            filedata = base64.b64decode(f.read())
        nonce, ciphertext = filedata[:12], filedata[12:]
        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
        return base64.b64encode(plaintext).decode()
