import os
import logging
import io
from flask import Flask, jsonify, request, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, jwt_required, create_access_token, get_jwt_identity
from flask_cors import CORS
from config import Config
from models.user import User
from models.file import File
from models.db import db
from services.encryption import EncryptionService
from services.storage import FileStorageService


jwt = JWTManager()
logger = logging.getLogger(__name__)

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    
    db.init_app(app)
    jwt.init_app(app)
    CORS(app, resources={r"/*": {"origins": "*"}})  
    Config.init_app()


    @app.route('/signup', methods=['POST'])
    def signup():
        data = request.get_json()
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')

        if not all([username, email, password]):
            return jsonify({'error': 'All fields are required'}), 400

        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            return jsonify({'error': 'Email is already taken'}), 400

        try:
            user = User.add_user(username, email, password)
            return jsonify({'message': 'Registration successful', 'user_id': user.id}), 201
        except Exception as e:
            db.session.rollback()
            logger.error(f"Signup failed: {str(e)}")
            return jsonify({'error': f'Registration failed: {str(e)}'}), 500
        

    @app.route('/login', methods=['POST'])
    def login():
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')

        user = User.query.filter_by(username=username).first()
        if user and User.verify_hash(password, user.password):
            access_token = create_access_token(identity=user.id)
            return jsonify({
                'message': 'Login successful',
                'token': access_token,
                'user_id': user.id
            }), 200
        return jsonify({'error': 'Invalid username or password'}), 401
    

    @app.route('/logout', methods=['POST'])
    @jwt_required()
    def logout():
        return jsonify({'message': 'Logout successful'}), 200

    @app.route('/dashboard', methods=['GET'])
    @jwt_required()
    def dashboard():
        user_id = get_jwt_identity()
        files = File.query.filter_by(user_id=user_id).all()
        files_data = [{'id': f.id, 'filename': f.filename} for f in files]
        return jsonify({'files': files_data}), 200

    @app.route('/upload', methods=['POST'])
    @jwt_required()
    def upload_file():
        user_id = get_jwt_identity()
        if 'file' not in request.files:
            return jsonify({'error': 'No file part in the request'}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400

        try:
            EncryptionService.encrypt(file=file, filename=file.filename, user_id=user_id)
            return jsonify({'message': 'File uploaded and encrypted successfully'}), 200
        except Exception as e:
            logger.error(f"Error in file upload: {str(e)}")
            return jsonify({'error': f'Error uploading file: {str(e)}'}), 500

    @app.route('/download/<int:file_id>', methods=['GET'])
    @jwt_required()
    def download_file(file_id):
        user_id = get_jwt_identity()
        file = File.query.filter_by(id=file_id, user_id=user_id).first()
        if not file:
            return jsonify({'error': 'File not found or unauthorized'}), 404

        try:
            decrypted_data = EncryptionService.decrypt(file.filepath, user_id)
            original_filename = file.filename.rsplit('.enc', 1)[0]
            return send_file(
                io.BytesIO(decrypted_data),
                as_attachment=True,
                download_name=original_filename
            )
        except Exception as e:
            logger.error(f"Error in file download: {str(e)}")
            return jsonify({'error': f'Error downloading file: {str(e)}'}), 500

    # Create database tables
    with app.app_context():
        db.create_all()

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)