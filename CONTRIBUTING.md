# Contributing to ShadowBox

Thanks for wanting to help build ShadowBox, a privacy-first cloud storage platform! We’re looking for coders, designers, and testers to make it better. This guide explains how to contribute to the `dev` branch.

## Getting Started

1. **Fork the Repo**: Grab your own copy at https://github.com/dillionhuston/Shadow.git.
2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/<your-username>/Shadow.git
   cd ShadowBox
   ```
3. **Switch to `dev` Branch**:
   ```bash
   git checkout dev
   ```
4. **Set Up the Project**: Follow the [README](README.md) for Dart and Python setup instructions.

## How to Contribute

1. **Find an Issue**: Check the [Issues](https://github.com/dillionhuston/Shadow/issues) tab for tasks. Look for labels like `good first issue` or `help wanted`.
2. **Claim an Issue**: Comment on the issue to let us know you’re working on it.
3. **Create a Branch**:
   ```bash
   git checkout -b feature/<your-issue-number>-<short-description>
   ```
   Example: `feature/42-add-sharing-ui`
4. **Make Changes**:
   - **Front-End**: Use Dart for the web UI. Check `frontend/` for code.
   - **Back-End**: Use Python (Flask) in `backend/`.
   - **Security**: Test encryption or fix bugs.
   - **Features**: Work on group sharing, decentralized storage, or mobile apps (Flutter).
5. **Test Your Code**: Run the app locally to ensure it works:
   ```bash
   cd frontend && dart run
   cd backend && flask run
   ```
6. **Commit Changes**:
   - Write clear messages: `Add user authentication UI (#42)`.
   - Follow code style (e.g., PEP 8 for Python).
   ```bash
   git add .
   git commit -m "Your message"
   ```
7. **Push to Your Fork**:
   ```bash
   git push origin feature/<your-branch>
   ```
8. **Open a Pull Request**:
   - Go to the repo and create a PR to the `dev` branch.
   - Describe your changes and link the issue (e.g., `Fixes #42`).
   - Wait for review. We’ll provide feedback or merge it!

## What We’re Working On

- **Front-End**: Improve Dart-based UI or start Flutter mobile apps.
- **Back-End**: Optimize Python/Flask or add decentralized storage (e.g., IPFS).
- **Security**: Strengthen AES-256 encryption or audit code.
- **Features**: Build group sharing, file versioning, or E2E encrypted chat.

## Guidelines

- **Keep It Simple**: Small, focused PRs are easier to review.
- **Test Thoroughly**: Ensure your changes don’t break existing features.
- **Be Respectful**: Follow our [Code of Conduct](CODE_OF_CONDUCT.md) (coming soon).
- **Ask Questions**: Reach out on [Discord/Community] (link TBD) if stuck.

## Prerequisites

- **Dart**: For front-end and Flutter.
- **Python 3.8+**: For backend (Flask, SQLAlchemy).
- **Git**: For version control.
- **SQLite**: For testing.

## Why Contribute?

- Help build a privacy-first cloud storage solution.
- Learn Dart, Python, or decentralized tech.
- Boost your portfolio with real-world contributions.

Questions? Comment on an issue or join our [Discord/Community] (https://discord.gg/4a79CNmC). Happy coding!
