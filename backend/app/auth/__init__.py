from flask import Blueprint

auth_bp = Blueprint('auth', __name__)

from . import routes  # This will register the auth routes
