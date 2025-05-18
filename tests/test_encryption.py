import unittest
import os
import base64
import shutil
import secrets  # Required for generating large test data
from backend.app.services.encryption import EncryptionService
from backend.app.config import Config


class TestEncryptionBreaking(unittest.TestCase):
    def setUp(self):
        """Prepare test environment with consistent test values."""
        self.user_id = 'user123'
        self.correct_key = 'supersecret123'
        self.incorrect_key = 'wrongkey456'
        self.filename = 'testfile.txt'
        self.test_data = b'confidential content'
        self.b64_data = base64.b64encode(self.test_data).decode('utf-8')
        os.makedirs(Config.ENCRYPTED_FILE_PATH, exist_ok=True)

    def tearDown(self):
        """Clean up all encrypted files after each test."""
        shutil.rmtree(Config.ENCRYPTED_FILE_PATH, ignore_errors=True)

    # --- Positive Tests ---

    def test_encrypt_decrypt_success(self):
        """Encrypt then decrypt valid base64 input successfully."""
        encrypted_filename = EncryptionService.encrypt(
            self.b64_data, self.filename, self.user_id, self.correct_key
        )
        decrypted_b64 = EncryptionService.decrypt(
            encrypted_filename, self.user_id, self.correct_key
        )
        decrypted_data = base64.b64decode(decrypted_b64)
        self.assertEqual(decrypted_data, self.test_data)

    def test_encrypt_with_raw_bytes(self):
        """Encrypt using raw bytes instead of base64-encoded input."""
        encrypted_filename = EncryptionService.encrypt(
            self.test_data, self.filename, self.user_id, self.correct_key
        )
        decrypted_b64 = EncryptionService.decrypt(
            encrypted_filename, self.user_id, self.correct_key
        )
        decrypted_data = base64.b64decode(decrypted_b64)
        self.assertEqual(decrypted_data, self.test_data)

    def test_encrypt_decrypt_large_file(self):
        """Ensure encryption/decryption works correctly with large data (~10MB)."""
        large_data = secrets.token_bytes(10 * 1024 * 1024)  # 10MB
        b64_large_data = base64.b64encode(large_data).decode('utf-8')

        encrypted_filename = EncryptionService.encrypt(
            b64_large_data, "largefile.bin", self.user_id, self.correct_key
        )
        decrypted_b64 = EncryptionService.decrypt(
            encrypted_filename, self.user_id, self.correct_key
        )
        decrypted_data = base64.b64decode(decrypted_b64)
        self.assertEqual(decrypted_data, large_data)

    # --- Negative Tests ---

    def test_decryption_with_wrong_key_fails(self):
        """Decrypting with incorrect key should raise key mismatch error."""
        encrypted_filename = EncryptionService.encrypt(
            self.b64_data, self.filename, self.user_id, self.correct_key
        )
        with self.assertRaises(EncryptionService.EncryptionError) as context:
            EncryptionService.decrypt(
                encrypted_filename, self.user_id, self.incorrect_key
            )
        self.assertIn("Key mismatch detected", str(context.exception))

    def test_decryption_with_wrong_user_id_fails(self):
        """Decrypting with incorrect user_id (salt mismatch) should fail."""
        encrypted_filename = EncryptionService.encrypt(
            self.b64_data, self.filename, self.user_id, self.correct_key
        )
        wrong_user_id = 'different_user'
        with self.assertRaises(EncryptionService.EncryptionError) as context:
            EncryptionService.decrypt(
                encrypted_filename, wrong_user_id, self.correct_key
            )
        self.assertIn("Decryption failed", str(context.exception))

    def test_decrypt_fails_on_corrupted_file(self):
        """Manually corrupting encrypted file should raise decryption failure."""
        encrypted_filename = EncryptionService.encrypt(
            self.b64_data, self.filename, self.user_id, self.correct_key
        )
        file_path = os.path.join(Config.ENCRYPTED_FILE_PATH, encrypted_filename)
        with open(file_path, 'wb') as f:
            f.write(b'corrupted-data')

        with self.assertRaises(EncryptionService.EncryptionError) as context:
            EncryptionService.decrypt(
                encrypted_filename, self.user_id, self.correct_key
            )
        self.assertIn("Decryption failed", str(context.exception))


if __name__ == '__main__':
    unittest.main()
