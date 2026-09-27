import os
from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

db = SQLAlchemy()

app = Flask(__name__)

db_user = os.getenv("DB_USER", "appuser")
db_password = os.getenv("DB_PASSWORD", "apppassword")
db_host = os.getenv("DB_HOST", "db")
db_port = os.getenv("DB_PORT", "5432")
db_name = os.getenv("DB_NAME", "cloudnotes")

app.config["SQLALCHEMY_DATABASE_URI"] = (
    f"postgresql+psycopg2://{db_user}:{db_password}"
    f"@{db_host}:{db_port}/{db_name}"
)
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db.init_app(app)


class Note(db.Model):
    __tablename__ = "notes"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(150), nullable=False)
    content = db.Column(db.Text, nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "content": self.content,
        }


with app.app_context():
    try:
        db.create_all()
    except Exception as exc:
        # Container can start before RDS is ready/reachable.
        # The ALB health endpoint remains available; DB operations
        # will report errors until connectivity is restored.
        print(f"Database initialization warning: {exc}", flush=True)


@app.get("/api/health")
def health():
    try:
        db.session.execute(text("SELECT 1"))
        return jsonify({"status": "healthy", "database": "connected"}), 200
    except Exception as exc:
        return jsonify({"status": "unhealthy", "database": "unavailable", "error": str(exc)}), 503


@app.get("/api/notes")
def get_notes():
    notes = Note.query.order_by(Note.id.desc()).all()
    return jsonify([n.to_dict() for n in notes])


@app.post("/api/notes")
def create_note():
    data = request.get_json(silent=True) or {}
    title = str(data.get("title", "")).strip()
    content = str(data.get("content", "")).strip()

    if not title or not content:
        return jsonify({"error": "title and content are required"}), 400

    note = Note(title=title, content=content)
    db.session.add(note)
    db.session.commit()

    return jsonify(note.to_dict()), 201


@app.delete("/api/notes/<int:note_id>")
def delete_note(note_id):
    note = db.session.get(Note, note_id)
    if not note:
        return jsonify({"error": "note not found"}), 404

    db.session.delete(note)
    db.session.commit()
    return jsonify({"message": "deleted"})


@app.get("/")
def root():
    return jsonify({
        "service": "cloud-notes-backend",
        "message": "API is running",
        "health": "/api/health"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
