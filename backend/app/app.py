import os
import base64
import re
from flask import Flask, jsonify, request, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, jwt_required, create_access_token, get_jwt_identity
from flask_cors import CORS
from werkzeug.utils import secure_filename
from io import BytesIO

from backend.app.config import Config
from models.user import User
from models.file import File
from models.db import db
from services.encryption import EncryptionService

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)
jwt = JWTManager(app)
CORS(app, resources={r"/*": {"origins": "*"}})

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200

@app.route('/signup', methods=['POST'])
def signup():
    payload = request.get_json() or {}
    username = payload.get('username')
    email = payload.get('email')
    password = payload.get('password')

    if not all([username, email, password]):
        return jsonify({'error': 'Missing fields'}), 400

    if not re.match(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$', password):
        return jsonify({'error': 'Password must be at least 8 characters with letters and numbers'}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already registered'}), 400

    user = User.add_user(username, email, password)
    db.session.commit()
    return jsonify({'message': 'Success', 'user_id': str(user.id)}), 201

@app.route('/login', methods=['POST'])
def login():
    payload = request.get_json() or {}
    username = payload.get('username')
    password = payload.get('password')

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
    payload = request.get_json() or {}
    current_pw = payload.get('currentPassword')
    new_pw = payload.get('newPassword')

    if not all([current_pw, new_pw]):
        return jsonify({'error': 'Missing current or new password'}), 400

    if not re.match(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$', new_pw):
        return jsonify({'error': 'New password must be at least 8 characters with letters and numbers'}), 400

    user = User.query.get(user_id)
    if not user or not User.verify_hash(current_pw, user.password):
        return jsonify({'error': 'Invalid current password'}), 401

    user.password = User.generate_hash(new_pw)
    db.session.commit()
    return jsonify({'message': 'Password changed'}), 200

@app.route('/dashboard', methods=['GET'])
@jwt_required()
def dashboard():
    try:
        user_id = get_jwt_identity()
        files = File.query.filter_by(user_id=user_id).all()
        return jsonify({
            'files': [{
                'id': f.id,
                'filename': f.original_filename or f.filename,
                'created_at': f.created_at.isoformat()
            } for f in files]
        }), 200
    except Exception as e:
        print(f"[dashboard] Error: {e}")
        return jsonify({'error': 'Failed to fetch files'}), 500

@app.route('/upload', methods=['POST'])
@jwt_required()
def upload_file():
    user_id = get_jwt_identity()
    file = request.files.get('file')

    if not file or file.filename == '':
        return jsonify({'error': 'No file provided'}), 400

    file.seek(0, os.SEEK_END)
    if file.tell() > 10 * 1024 * 1024:
        return jsonify({'error': 'File too large'}), 400
    file.seek(0)

    filename = secure_filename(file.filename)
    file_data = file.read()
    encoded_data = base64.b64encode(file_data).decode('utf-8')

    user = User.query.get(user_id)
    try:
        print(f"[upload] User: {user_id}, File: {filename}")
        encrypted_filename = EncryptionService.encrypt(encoded_data, filename, user_id, user.get_key())
        encrypted_path = os.path.join(Config.ENCRYPTED_FILE_PATH, encrypted_filename)

        new_file = File(
            user_id=user_id,
            filename=encrypted_filename,
            filepath=encrypted_path,
            original_filename=filename
        )

        db.session.add(new_file)
        db.session.commit()

        print(f"[upload] Saved: {new_file.id} as {encrypted_filename}")
        return jsonify({'message': f'{filename} uploaded'}), 201

    except EncryptionService.EncryptionError as e:
        print(f"[upload] Encryption error: {e}")
        return jsonify({'error': str(e)}), 500

    except Exception as e:
        print(f"[upload] General error: {e}")
        db.session.rollback()
        return jsonify({'error': 'Upload failed'}), 500

@app.route('/files', methods=['GET'])
@jwt_required()
def list_files():
    try:
        user_id = get_jwt_identity()
        files_info = []

        for name in os.listdir(Config.ENCRYPTED_FILE_PATH):
            path = os.path.join(Config.ENCRYPTED_FILE_PATH, name)
            if os.path.isfile(path):
                entry = File.query.filter_by(user_id=user_id, filename=name).first()
                if entry:
                    files_info.append({
                        'filename': entry.original_filename or entry.filename,
                        'size': os.path.getsize(path),
                        'created_at': entry.created_at.isoformat() if entry.created_at else None
                    })

        return jsonify({'files': files_info}), 200

    except Exception as e:
        print(f"[files] Error: {e}")
        return jsonify({'error': 'Failed to list files'}), 500

@app.route('/download/<file_id>', methods=['GET'])
@jwt_required()
def download_file(file_id):
    try:
        user_id = get_jwt_identity()
        file_entry = File.query.filter_by(id=file_id, user_id=user_id).first()

        if not file_entry:
            return jsonify({'error': 'File not found or unauthorized'}), 404

        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404

        path = file_entry.filepath.replace('/', os.sep)
        if not os.path.exists(path):
            return jsonify({'error': 'File not found on server'}), 404

        print(f"[download] Decrypting {file_entry.filename} for user {user_id}")
        decrypted_b64 = EncryptionService.decrypt(file_entry.filename, user_id, user.get_key())
        decrypted_data = base64.b64decode(decrypted_b64)

        filename = file_entry.original_filename or file_entry.filename
        ext = filename.rsplit('.', 1)[-1].lower() if '.' in filename else 'txt'
        mimetypes = {
            'txt': 'text/plain',
            'pdf': 'application/pdf',
            'doc': 'application/msword',
            'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        }

        return send_file(
            BytesIO(decrypted_data),
            download_name=filename,
            mimetype=mimetypes.get(ext, 'application/octet-stream'),
            as_attachment=True
        )

    except Exception as e:
        print(f"[download] Error: {e}")
        return jsonify({'error': 'Download failed'}), 500

with app.app_context():
    db.create_all()

if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=5000)
