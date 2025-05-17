from models.db import db
from datetime import datetime

class File(db.Model):
    __tablename__ = 'files'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.String, db.ForeignKey('user.id'), nullable=False)
    filename = db.Column(db.String(255), nullable=False)
    original_filename = db.Column(db.String(255), nullable=True)  
    filepath = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


    def __repr__(self):
        return f"<File {self.filename}>"

    def add_file(self, filename, filepath, user_id):
        file = File(filename=filename, filepath=filepath, user_id=user_id,)
        db.session.add(file)
        db.session.commit()
        return 
    