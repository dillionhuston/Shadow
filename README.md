# ShadowBox

![ShadowBox Demo](demo.gif)


**Secure, Self-Hosted File Storage**

ShadowBox is an easy-to-use, encrypted file storage system you can run on your own PC, Raspberry Pi, or server. Access files securely from any device on your local network or set up remote access. Files are encrypted with AES-256 before storage and only decrypted when you download them. You control your data with no third-party services.

## Key Features
- Sync files across devices with one account
- AES-256 encryption for all uploads
- Files decrypted only on download
- Secure file deletion (removed from database and device)
- Simple web interface (Dart-based, easy to customize)
- Lightweight Python Flask backend

## Tech Stack
- **Backend**: Python, Flask, SQLAlchemy
- **Frontend**: Dart (replaceable with any frontend)
- **Encryption**: AES-256
- **Database**: SQLite (swappable)

## Get Started

### Requirements
- Python 3.8+ (for backend)
- Dart (optional, for frontend)
- OR Docker (easiest setup)

### Option 1: Run Locally

1. **Clone the repo**
   ```bash
   git clone https://github.com/dillionhuston/Shadow.git
   cd Shadow
   ```

2. **Run the backend**
   ```bash
   cd backend
   pip install -r requirements.txt
   flask run
   ```

3. **Run the frontend**
   ```bash
   cd ../frontend
   dart pub get
   dart run
   ```

### Option 2: Run with Docker

1. **Clone the repo**
   ```bash
   git clone https://github.com/dillionhuston/Shadow.git
   cd Shadow
   ```

2. **Build and run**
   ```bash
   cd backend
   docker build -t shadowbox .
   docker run -p 5000:5000 shadowbox
   ```

## Future Plans
- Local encryption key management
- User accounts and file permissions
- File versioning and shared folders
- Support for decentralized storage (e.g., IPFS)

## Contributing
- Improve the web interface
- Optimize backend performance
- Add new features
- Test encryption and security

## Why ShadowBox?
- Full control over your files and server
- No third-party tracking or storage
- Runs on low-power devices like Raspberry Pi
- Great starting point for custom projects

## License
MIT—free to use, modify, and share
