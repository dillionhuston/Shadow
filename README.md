# ShadowBox

**Secure & Private Cloud Storage – Your Digital Fort Knox**

> ⚠️ **Prototype Warning**: ShadowBox is in early development. Avoid using it for sensitive or production data.

ShadowBox is a privacy-first, encrypted cloud storage solution built with **Dart** for the front-end and **Python** for the back-end. It’s designed with user security and privacy in mind, leveraging AES-256 encryption to ensure that your files remain secure. The goal is to provide a decentralized, user-controlled file-sharing platform that emphasizes privacy.

---

## 🔑 Core Features (MVP)

- **AES-256 Encrypted File Uploads**: Your files are encrypted before being uploaded, ensuring only you can access them.
- **User Authentication & File Ownership**: Every user has their own private storage space and can securely manage their files.
- **Secure File Sharing**: Files can be shared with others using encrypted links.
- **Role-Based Access Control**: Assign different access levels for different users.
- **Responsive Web Interface**: A sleek, user-friendly Dart-based front-end for managing your files.
- **Python Backend**: The back-end is powered by Python, providing secure file processing and user management.

---

## 🛠️ Installation

### Prerequisites

- **Dart**: Required for the front-end.
- **Python 3.8+**: For the back-end.
- **Flask**: For the back-end server.
- **SQLAlchemy**: For database management.
- **SQLite**: Used for development.

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/dillionhuston/ShadowBox.git
   cd ShadowBox
