from models.db import db

class File(db.Model):
    __tablename__ = 'files'

    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(128), nullable=False)
    filepath = db.Column(db.String(256), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

    def add_file(self, filename, filepath, user_id):
        file = File(filename=filename, filepath=filepath, user_id=user_id)
        db.session.add(file)
        db.session.commit()
        return file