import sqlite3

class db_operations:
    def __init__(self):
        self.conn = sqlite3.connect('users.db', check_same_thread=False)
        self.c = self.conn.cursor()
        self.create_table()

    def create_table(self):
        self.c.execute('''
            CREATE TABLE IF NOT EXISTS accounts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL UNIQUE,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL
            )
        ''')
        self.conn.commit()

    def adduser(self, username, hashed_password, email):
        try:
            self.c.execute(
                'INSERT INTO accounts (username, email, password) VALUES (?, ?, ?)', 
                (username, email, hashed_password))                               
            self.conn.commit()
            print("User added successfully!")
        except sqlite3.IntegrityError:
            print("Error: Username or email already exists!")

    def get_user(self, username):
        self.c.execute("SELECT * FROM accounts WHERE username = ?", (username,))
        user = self.c.fetchone()
        if user:
            return {
                'id': user[0],
                'username': user[1],
                'email': user[2],
                'password': user[3]
            }
        return None 
    



    def __del__(self):
        self.conn.close()
