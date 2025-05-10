import sqlite3
import os
from io import BytesIO
from flask import Flask, render_template, request, send_file
from werkzeug.utils import secure_filename
from backend.crypto import cryptomanager

cryptomanager = cryptomanager()
unencrypted_folder = r'backend/upload/unencrypted'
encrypted_folder = r'backend/upload/encrypted'
file_metadata = r'/backend/data/data.db'

class storage:

    def __init__(self):
        """self.conn = sqlite3.connect(file_metadata, check_same_thread=False)
        self.c = self.conn.cursor()
        self.create_table()"""

    """def create_table(self):
        self.c.execute('''
            CREATE TABLE IF NOT EXISTS files (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                filename TEXT NOT NULL,
                data BLOB NOT NULL
            )
        ''')
        self.conn.commit()""" # reuse later. 
    

    def save_file(self, file):
        if not file:
            raise ValueError("No file provided")
        print("SAVING")
        filename = secure_filename(file.filename)  
        file_path = os.path.join(unencrypted_folder, filename)
        os.makedirs(unencrypted_folder, exist_ok=True)

        file.save(file_path)  
        print(f"File saved successfully: {file_path}")

        #insert file path for input
        cryptomanager.get_unencrypted_data(file_path)
        cryptomanager.encrypt(file_path, output_folder=encrypted_folder)
        
        