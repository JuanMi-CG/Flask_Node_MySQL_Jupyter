from flask import Blueprint, jsonify

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    return "Hello from Flask!"

@main_bp.route('/health')
def health():
    return jsonify(status="healthy"), 200
