const notesEl = document.getElementById("notes");
const form = document.getElementById("noteForm");
const statusEl = document.getElementById("status");
const refreshBtn = document.getElementById("refreshBtn");

async function loadNotes() {
  notesEl.innerHTML = "<p>Loading...</p>";

  try {
    const response = await fetch("/api/notes");
    if (!response.ok) throw new Error("API request failed");

    const notes = await response.json();

    if (!notes.length) {
      notesEl.innerHTML = "<p>No notes yet. Create the first one.</p>";
      return;
    }

    notesEl.innerHTML = notes.map(note => `
      <article class="note">
        <h3>${escapeHtml(note.title)}</h3>
        <p>${escapeHtml(note.content)}</p>
        <button class="delete" onclick="deleteNote(${note.id})">Delete</button>
      </article>
    `).join("");
  } catch (error) {
    notesEl.innerHTML = `<p>Could not load notes: ${escapeHtml(error.message)}</p>`;
  }
}

async function deleteNote(id) {
  const response = await fetch(`/api/notes/${id}`, { method: "DELETE" });
  if (!response.ok) {
    alert("Delete failed");
    return;
  }
  loadNotes();
}

form.addEventListener("submit", async (event) => {
  event.preventDefault();
  statusEl.textContent = "Saving...";

  const payload = {
    title: document.getElementById("title").value,
    content: document.getElementById("content").value
  };

  try {
    const response = await fetch("/api/notes", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    const data = await response.json();

    if (!response.ok) throw new Error(data.error || "Save failed");

    form.reset();
    statusEl.textContent = "Saved successfully.";
    loadNotes();
  } catch (error) {
    statusEl.textContent = error.message;
  }
});

refreshBtn.addEventListener("click", loadNotes);

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

loadNotes();
