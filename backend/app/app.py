import os
import base64
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

# checks if server is alive 
@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json() or {}
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    if not all([username, email, password]):
        return jsonify({'error': 'Missing fields'}), 400
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
    user = User.query.get(user_id)

    if not user or not User.verify_hash(current_password, user.password):
        return jsonify({'error': 'Invalid password'}), 401
    
    user.password = User.generate_hash(new_password)
    db.session.commit()
    return jsonify({'message': 'Success'}), 200

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
        return jsonify({'error': 'No file selected'}), 

    file.seek(0, os.SEEK_END)
    if file.tell() > 10 * 1024 * 1024:
        return jsonify({'error': 'File too large'}), 


    file.seek(0)
    filename = secure_filename(file.filename)
    file_data = file.read()
    file_data_b64 = base64.b64encode(file_data).decode('utf-8')
    
    user = User.query.get(user_id)
    encrypted_filename = EncryptionService.encrypt(file_data_b64, filename, user_id, user.get_key())
    return jsonify({'message': f'File {encrypted_filename} uploaded'}), 201

with app.app_context():
    db.create_all()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)