from cryptography.fernet import Fernet
import os 

class cryptomanager:
    def __init__(self):
        self.data_path = 'files.db'
        self.key_path = 'backend/data/key.txt'
        self.key = self.load_or_generate_key()
        self.fernet = Fernet(self.key)

    def load_or_generate_key(self):
        try:
         with open(self.key_path, 'rb') as key_file:
          key = key_file.read().strip() 
          if len(key) != 44:  
           raise ValueError("Invalid key length. Generating a new key.")
         print(f'Loaded key: {key}')
        except (FileNotFoundError, ValueError):
            key = Fernet.generate_key()
            with open(self.key_path, 'wb') as key_file:
                key_file.write(key)
            print(f'Generated and saved new key: {key}')
        return key
    
    #takes filepath as input 
    def get_unencrypted_data(self, filepath):
        with open(filepath, 'rb') as f:
            self.unencrypted = f.read()
            print(f'Unencrypted data loaded from {filepath}')
            return self.unencrypted
        
        
     # filepath where to save files   
    def encrypt(self, filepath, output_folder):
        self.encrypted_data = self.fernet.encrypt(self.unencrypted)
        filename = os.path.basename(filepath)
        encrypted_path = os.path.join(output_folder, filename)

        with open(encrypted_path, 'wb') as encrypted_file:
            encrypted_file.write(self.encrypted_data)
            print(f'Encrypted data saved as {filepath}.enc')
            return


    def decrypt(self, filepath, key):
        with open(key, 'r'):
           key = key.read().strip()
           self.fernet = Fernet(key)
           decrypted_data = self.fernet.decrypt(open(filepath, 'rb').read())
        print(f"encrypted data = {decrypted_data}")
        return decrypted_data