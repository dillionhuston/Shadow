import os
import base64
import re
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, jwt_required, create_access_token, get_jwt_identity
from flask_cors import CORS
from werkzeug.utils import secure_filename
from config import Config
from models.user import User
from models.file import File
from models.db import db
from services.encryption import EncryptionService

app = Flask(__name__)
app.config.from_object(Config)
db.init_app(app)
jwt = JWTManager(app)
CORS(app, resources={r"/*": {"origins": "*"}})


@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json() or {}
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    #some checks to avoid user any issues with backend 
    if not all([username, email, password]):
        return jsonify({'error': 'Missing fields'}), 400
    
    if not re.match(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$', password):
        return jsonify({'error': 'Password must be at least 8 characters with letters and numbers'}), 400
    
    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email taken'}), 400
    
    user = User.add_user(username, email, password)
    db.session.commit()
    return jsonify({'message': 'Success', 'user_id': str(user.id)}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    username = data.get('username')
    password = data.get('password')
    user = User.query.filter_by(username=username).first()

    if user and User.verify_hash(password, user.password):
        token = create_access_token(identity=str(user.id))
        return jsonify({'message': 'Success', 'token': token, 'user_id': str(user.id)}), 200
    
    return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    return jsonify({'message': 'Success'}), 200

@app.route('/change-password', methods=['POST'])
@jwt_required()
def change_password():
    user_id = get_jwt_identity()
    data = request.get_json() or {}
    current_password = data.get('currentPassword')
    new_password = data.get('newPassword')

    if not all([current_password, new_password]):
        return jsonify({'error': 'Missing current or new password'}), 400
    
    if not re.match(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$', new_password):
        return jsonify({'error': 'New password must be at least 8 characters with letters and numbers'}), 400
    user = User.query.get(user_id)

    if not user or not User.verify_hash(current_password, user.password):
        return jsonify({'error': 'Invalid current password'}), 401
    
    user.password = User.generate_hash(new_password)
    db.session.commit()
    return jsonify({'message': 'Password changed successfully'}), 200



@app.route('/dashboard', methods=['GET'])
@jwt_required()
def dashboard():
    user_id = get_jwt_identity()
    files = File.query.filter_by(user_id=user_id).all()
    files_data = [{'id': f.id, 'filename': f.filename, 'created_at': f.created_at.isoformat()} for f in files]

    return jsonify({'files': files_data}), 200

@app.route('/upload', methods=['POST'])
@jwt_required()
def upload_file():
    user_id = get_jwt_identity()
    if 'file' not in request.files:
        return jsonify({'error': 'No file'}), 400
    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    file.seek(0, os.SEEK_END)

    if file.tell() > 10 * 1024 * 1024:
        return jsonify({'error': 'File too large'}), 400
    file.seek(0)

    filename = secure_filename(file.filename)
    file_data = file.read()
    file_data_b64 = base64.b64encode(file_data).decode('utf-8')
    user = User.query.get(user_id)
    try:
        encrypted_filename = EncryptionService.encrypt(file_data_b64, filename, user_id, user.get_key())
        filepath = os.path.join(Config.ENCRYPTED_FILE_PATH, encrypted_filename)
        new_file = File(
            user_id=user_id,
            filename=encrypted_filename,
            filepath=filepath
        )
        db.session.add(new_file)
        db.session.commit()
        return jsonify({'message': f'File {filename} uploaded successfully'}), 201
    
    except EncryptionService.EncryptionError as e:
        return jsonify({'error': str(e)}), 500
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Upload failed: {str(e)}'}), 500

@app.route('/files', methods=['GET'])
@jwt_required()
def view_files():
    try:
        user_id = get_jwt_identity()
        files = []
        for filename in os.listdir(Config.ENCRYPTED_FILE_PATH):
            file_path = os.path.join(Config.ENCRYPTED_FILE_PATH, filename)
            if os.path.isfile(file_path):
                file_entry = File.query.filter_by(user_id=user_id, filename=filename).first()
                if file_entry:
                    files.append({
                        'filename': filename,
                        'size': os.path.getsize(file_path),
                        'created_at': file_entry.created_at.isoformat() if file_entry.created_at else None
                    })
        return jsonify({'files': files}), 200
    
    except Exception as e:
        return jsonify({'error': f'Failed to list files: {str(e)}'}), 500

with app.app_context():
    db.create_all()

if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=5000)