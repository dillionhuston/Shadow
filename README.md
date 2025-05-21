# ShadowBox

**Private Cloud Storage You Can Trust**

> **Note**: ShadowBox is a prototype. Don’t store sensitive files yet. See the `prototype` branch for the early version.

ShadowBox is a secure, privacy-focused cloud storage app built with **Dart** for the front-end and **Python** for the back-end. With AES-256 encryption, your files stay safe and private. We’re working toward a decentralized, user-controlled platform for file storage and sharing.

## What It Does

- **Encrypted Uploads**: Files are secured with AES-256 before upload.
- **Secure Sharing**: Share files via encrypted links you control.
- **User Accounts**: Private storage spaces with role-based access.
- **Web Interface**: Simple, Dart-based UI for file management.
- **Python Backend**: Runs on Flask and SQLAlchemy for reliable file and user handling.

## What’s Next

- **Group Sharing**: Share files with teams and set permissions.
- **Decentralized Storage**: Use IPFS or similar for distributed storage.
- **Mobile Apps**: Build iOS/Android apps with Flutter.
- **File Versioning**: Track and revert file changes.

## Setup

### Requirements

- **Dart**: For the front-end.
- **Python 3.8+**: For the back-end.
- **Flask & SQLAlchemy**: Backend libraries.
- **SQLite**: For testing.

### Steps

1. Clone the repo:
   ```bash
   git clone https://github.com/dillionhuston/Shadow.git
   cd ShadowBox
   ```

2. Front-end:
   ```bash
   cd frontend
   dart pub get
   dart run
   ```

3. Back-end:
   ```bash
   cd backend
   pip install -r requirements.txt
   flask run
   ```

## Join the Project

Want to help build ShadowBox? We need coders, designers, and testers to make this a reality. If you know Dart, Python, or UI design, jump in! You could:

- **Front-End**: Improve the Dart UI or start Flutter apps.
- **Back-End**: Optimize Python code or add decentralized storage.
- **Security**: Test encryption or fix bugs.
- **Features**: Build group sharing or versioning.

**How to Contribute**:
1. Fork the repo: https://github.com/dillionhuston/Shadow.git
2. Check issues and send pull requests to the `dev` branch.
3. Connect with us on [Discord/Community] (link coming soon).

## Why Get Involved?

- Help create a privacy-first cloud storage solution.
- Sharpen your Dart, Python, or decentralized tech skills.
- Add a solid project to your portfolio.
