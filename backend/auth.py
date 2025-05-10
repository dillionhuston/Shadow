import hashlib 



class auth():
  def hash_password(password: str) -> str:
    print(f"Hashing password: {password}")
    password_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode('utf-8')
    
def verify_password(self, stored_hash, entered_password):
      return bcrypt.checkpw(entered_password.encode(), stored_hash.encode())