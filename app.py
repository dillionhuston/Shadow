
import os 
from flask import Flask, render_template, request, redirect, send_from_directory, url_for
from datetime import datetime
from werkzeug.utils import secure_filename
from backend.db import db_operations
from backend.crypto import cryptomanager
from backend.auth import auth 
from backend.storage import storage

app = Flask(__name__, template_folder='frontend/templates')
encrypted = 'backend/upload/encrypted'
app.config['UPLOAD_FOLDER'] = encrypted

########## FOLDERS ##########
allowed_extension = {'.doc', 'pdf', '.py', '.zip', '.7z', '.png'} #this is for an example

####### CLASS OBJECTS #########
backend = db_operations()
backend_auth = auth()
cryptomanager = cryptomanager()
storage = storage()

# for latr implementation 
def allowed_file(filename):
     return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed_extension

######### INDEX ROUTE ##############
@app.route('/')
def index():
    return render_template('index.html')


######### SIGN UP #############
@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        email = request.form.get('email')
        if username and password and email:
            print(f"password {password}")
            hashed_password = auth.hash_password(password)
            backend.adduser(username, hashed_password, email)  
            return redirect('/login') 
    return render_template('signup.html')

# ######## LOGIN ########
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        if username and password:
            user = backend.get_user(username)
            return user
        passw = backend_auth.verify_password(password)
        if user and passw:
                # session variable needed
                    print("User logged in")
    return render_template("login.html")

@app.route('/dashboard')
def dashboard():
    files = os.listdir(app.config['UPLOAD_FOLDER'])
    file_data = []
    for file in files:
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], file)
        if os.path.isfile(file_path):
            #get in kb
            file_size = round(os.path.getsize(file_path) / 1024, 2)
            last_modified = datetime.utcfromtimestamp(os.path.getmtime(file_path)).strftime('%Y-%m-%d %H:%M:%S')
            
            file_data.append({
                'name': file,
                'size': file_size,
                'last_modified': last_modified
            })
    return render_template('dashboard.html', files=file_data)


#UPLOAD 
@app.route('/upload', methods=['GET', 'POST'])
def upload(uploaded = False):
    if request.method == 'GET':
         return render_template('upload.html')
      
    if request.method == 'POST':
        if 'file' not in request.files:
            return 'No file attached', 400
        file = request.files['file']
        if file:
            storage.save_file(file)
            return render_template("dashboard.html")
            
      
@app.route('/download/')
def download_files():
     aes_key = request.form['aesKey']
     filename = request.form['filename']

     file_path = os.path.join(encrypted, filename)
     if not os.path.exists:
          return "File not found", 404
     cryptomanager.decrypt(file_path, aes_key)
     
     

     


   