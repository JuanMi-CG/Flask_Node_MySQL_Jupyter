from flask import Flask
from flask_jwt_extended import JWTManager
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()
migrate = Migrate()

def create_app():
    app = Flask(__name__)
    
    # Development configuration
    app.config['DEBUG'] = True
    app.config['ENV'] = 'development'
    app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://user:userpassword@db:3306/mydatabase"
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['JWT_SECRET_KEY'] = 'super-secret-key'
    
    db.init_app(app)
    migrate.init_app(app, db)
    JWTManager(app)
    
    from .routes import main_bp
    from .auth import auth_bp  # Import auth blueprint from the auth package
    
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    
    return app
