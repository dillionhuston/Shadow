import os
import re
import io
import base64
import hashlib
from datetime import datetime
from flask import Flask, request, jsonify, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity, create_access_token
from services.encryption import EncryptionService
from models.user import User
from models.file import File
from models.db import db
from config import Config
from flask_cors import CORS
import mimetypes

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)
jwt = JWTManager(app)
CORS(app, resources={r"/*": {"origins": "*"}})

encryption_service = EncryptionService()

with app.app_context():
    db.create_all()
    os.makedirs(Config.ENCRYPTED_FILE_PATH, exist_ok=True)

@app.route('/signup', methods=['POST'])
def signup():
    payload = request.get_json() or {}
    username = payload.get('username')
    email = payload.get('email')
    password = payload.get('password')
    encryption_key = payload.get('encryption_key')  # Get the encryption key

    if not all([username, email, password, encryption_key]):
        return jsonify({'error': 'Missing required fields'}), 400

    if len(username) < 3:
        return jsonify({'error': 'Username must be at least 3 characters'}), 400

    if not re.match(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$', email):
        return jsonify({'error': 'Invalid email format'}), 400

    if len(password) < 8 or not re.match(r'^(?=.*[A-Za-z])(?=.*\d)', password):
        return jsonify({'error': 'Password must be 8+ characters with letters and numbers'}), 400
        
    if len(encryption_key) < 10:
        return jsonify({'error': 'Encryption key must be at least 10 characters'}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({'error': 'Username already exists'}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already exists'}), 400

    try:
        # Use the encryption key for encrypting login data
        encrypted_data = encryption_service.encrypt_login(username, email, password, encryption_key)
        user = User(
            username=username,  # Store plaintext username for login
            email=email,        # Store plaintext email for unique constraint
            password=User.generate_hash(password),  # Hash the password for authentication
            encryption_key_hash=User.hash_encryption_key(encryption_key)  # Hash the encryption key
        )
        db.session.add(user)
        db.session.commit()
        return jsonify({'message': 'User created successfully'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Signup failed: {str(e)}'}), 500

@app.route('/login', methods=['POST'])
def login():
    payload = request.get_json() or {}
    username = payload.get('username')
    password = payload.get('password')
    encryption_key = payload.get('encryption_key')  # Get the encryption key

    if not all([username, password, encryption_key]):
        return jsonify({'error': 'Missing username, password, or encryption key'}), 400

    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({'error': 'Invalid credentials'}), 401
        
    # First verify the password
    if not User.verify_hash(password, user.password):
        return jsonify({'error': 'Invalid credentials'}), 401
        
    # Then verify the encryption key
    if not User.verify_encryption_key(encryption_key, user.encryption_key_hash):
        return jsonify({'error': 'Invalid encryption key'}), 401
    
    # If both checks pass, create a token
    token = create_access_token(identity=str(user.id))
    return jsonify({
        'message': 'Success',
        'token': token,
        'user_id': str(user.id)
    }), 200

@app.route('/change-password', methods=['POST'])
@jwt_required()
def change_password():
    user_id = get_jwt_identity()
    payload = request.get_json() or {}
    current_pw = payload.get('currentPassword')
    new_pw = payload.get('newPassword')
    encryption_key = payload.get('encryption_key')

    if not all([current_pw, new_pw, encryption_key]):
        return jsonify({'error': 'Missing current password, new password, or encryption key'}), 400

    if not re.match(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$', new_pw):
        return jsonify({'error': 'New password must be at least 8 characters with letters and numbers'}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404
        
    # Verify both password and encryption key
    if not User.verify_hash(current_pw, user.password):
        return jsonify({'error': 'Invalid current password'}), 401
        
    if not User.verify_encryption_key(encryption_key, user.encryption_key_hash):
        return jsonify({'error': 'Invalid encryption key'}), 401

    # If both checks pass, update the password
    user.password = User.generate_hash(new_pw)
    db.session.commit()
    return jsonify({'message': 'Password changed'}), 200

@app.route('/change-encryption-key', methods=['POST'])
@jwt_required()
def change_encryption_key():
    user_id = get_jwt_identity()
    payload = request.get_json() or {}
    password = payload.get('password')
    current_key = payload.get('current_encryption_key')
    new_key = payload.get('new_encryption_key')

    if not all([password, current_key, new_key]):
        return jsonify({'error': 'Missing password, current key, or new key'}), 400

    if len(new_key) < 10:
        return jsonify({'error': 'New encryption key must be at least 10 characters'}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404
        
    # Verify both password and current encryption key
    if not User.verify_hash(password, user.password):
        return jsonify({'error': 'Invalid password'}), 401
        
    if not User.verify_encryption_key(current_key, user.encryption_key_hash):
        return jsonify({'error': 'Invalid current encryption key'}), 401

    # Update the encryption key hash
    user.encryption_key_hash = User.hash_encryption_key(new_key)
    db.session.commit()
    
    # You would also need to re-encrypt stored files with the new key
    # This would require fetching all files, decrypting with old key, and re-encrypting with new key
    # This is not implemented here for brevity
    
    return jsonify({'message': 'Encryption key updated'}), 200

@app.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    return jsonify({'message': 'Logged out successfully'}), 200

@app.route('/dashboard', methods=['GET'])
@jwt_required()
def dashboard():
    user_id = get_jwt_identity()
    files = File.query.filter_by(user_id=user_id).all()
    files_data = [
        {
            'id': f.id,
            'filename': f.filename,
            'created_at': f.created_at.isoformat()
        } for f in files
    ]
    return jsonify({'files': files_data}), 200

@app.route('/files', methods=['GET'])
@jwt_required()
def get_files():
    user_id = get_jwt_identity()
    files = File.query.filter_by(user_id=user_id).all()
    files_data = [
        {
            'id': f.id,
            'filename': f.filename,
            'created_at': f.created_at.isoformat()
        } for f in files
    ]
    return jsonify({'files': files_data}), 200

@app.route('/upload', methods=['POST'])
@jwt_required()
def upload_file():
    user_id = get_jwt_identity()
    if 'file' not in request.files or 'data' not in request.form or 'encryption_key' not in request.form:
        return jsonify({'error': 'Missing file, data, or encryption key'}), 400

    file = request.files['file']
    data = request.form['data']
    encryption_key = request.form['encryption_key']

    if not file.filename:
        return jsonify({'error': 'No file selected'}), 400

    if not data:
        return jsonify({'error': 'No data provided'}), 400
        
    if not encryption_key:
        return jsonify({'error': 'No encryption key provided'}), 400

    allowed_extensions = {'txt', 'pdf', 'doc', 'docx'}
    file_ext = file.filename.rsplit('.', 1)[-1].lower() if '.' in file.filename else ''
    if file_ext not in allowed_extensions:
        return jsonify({'error': 'Invalid file extension'}), 400
        
    # Verify the encryption key
    user = User.query.get(user_id)
    if not user or not User.verify_encryption_key(encryption_key, user.encryption_key_hash):
        return jsonify({'error': 'Invalid encryption key'}), 401

    try:
        # Now use the encryption key with user_id for file encryption
        encrypted_filename = encryption_service.encrypt(data, file.filename, user_id, encryption_key)
        
        new_file = File(
            user_id=user_id,
            filename=file.filename,
            filepath=os.path.join(Config.ENCRYPTED_FILE_PATH, encrypted_filename)
        )
        db.session.add(new_file)
        db.session.commit()

        return jsonify({
            'message': 'File uploaded successfully',
            'file_id': new_file.id,
            'filename': file.filename
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Upload failed: {str(e)}'}), 500

@app.route('/download/<file_id>', methods=['GET'])
@jwt_required()
def download_file(file_id):
    user_id = get_jwt_identity()
    encryption_key = request.headers.get('Encryption-Key')
    
    if not encryption_key:
        return jsonify({'error': 'No encryption key provided'}), 400
        
    file_record = File.query.filter_by(id=file_id, user_id=user_id).first()
    if not file_record:
        return jsonify({'error': 'File not found or unauthorized'}), 404
        
    # Verify the encryption key
    user = User.query.get(user_id)
    if not user or not User.verify_encryption_key(encryption_key, user.encryption_key_hash):
        return jsonify({'error': 'Invalid encryption key'}), 401

    try:
        # Extract filename from filepath
        encrypted_filename = os.path.basename(file_record.filepath)
        
        # Decrypt the file using user's encryption key
        decrypted_data = encryption_service.decrypt(encrypted_filename, user_id, encryption_key)
        file_data = base64.b64decode(decrypted_data)

        mime_type, _ = mimetypes.guess_type(file_record.filename)
        if not mime_type:
            mime_type = 'application/octet-stream'

        return send_file(
            io.BytesIO(file_data),
            mimetype=mime_type,
            as_attachment=True,
            download_name=file_record.filename
        )
    except Exception as e:
        return jsonify({'error': f'Download failed: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=5000)