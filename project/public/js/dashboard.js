// Check auth on load
document.addEventListener('DOMContentLoaded', () => {
    checkAuth();
    loadStudents(); // Load default tab data

    // Setup Tab Switching
    window.showTab = function (tabId) {
        // Hide all tabs
        document.querySelectorAll('.tab-content').forEach(tab => {
            tab.classList.remove('active');
        });
        // Deactivate all nav links
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });

        // Show selected tab
        document.getElementById(tabId).classList.add('active');

        // Activate nav link
        const buttons = document.querySelectorAll('.nav-link');
        buttons.forEach(btn => {
            if (btn.getAttribute('onclick').includes(tabId)) {
                btn.classList.add('active');
            }
        });

        // Load data if needed
        if (tabId === 'crud-tab') loadStudents();
        if (tabId === 'movies-tab') loadMovies();
        if (tabId === 'quiz-tab') loadQuiz();
        if (tabId === 'storage-tab') loadStorage();
    };
});

async function checkAuth() {
    // Simple check if session cookie exists
}

function logout() {
    fetch('/api/logout', { method: 'POST' })
        .then(() => window.location.href = '/');
}

// ===== CALCULATOR LOGIC =====
let calcExpression = '';
const calcDisplay = document.getElementById('calc-display');

function calcInput(val) {
    if (calcDisplay.innerText === '0' && val !== '.') {
        calcExpression = val;
    } else {
        calcExpression += val;
    }
    calcDisplay.innerText = calcExpression;
}

function calcClear() {
    calcExpression = '';
    calcDisplay.innerText = '0';
}

function calcBackspace() {
    calcExpression = calcExpression.slice(0, -1);
    calcDisplay.innerText = calcExpression || '0';
}

function calcResult() {
    try {
        const result = eval(calcExpression);
        calcDisplay.innerText = result;
        calcExpression = String(result);
    } catch (e) {
        calcDisplay.innerText = 'Error';
        calcExpression = '';
    }
}

window.calcInput = calcInput;
window.calcClear = calcClear;
window.calcBackspace = calcBackspace;
window.calcResult = calcResult;

// ===== STUDENTS CRUD =====
async function loadStudents() {
    const res = await fetch('/api/students');
    const data = await res.json();
    const tbody = document.querySelector('#studentsTable tbody');
    tbody.innerHTML = '';

    if (data.error) return alert('Error loading data');

    data.forEach((mhs, index) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${index + 1}</td>
            <td>${mhs.nama}</td>
            <td>${mhs.nim}</td>
            <td>${mhs.kelas}</td>
            <td>${mhs.nilai}</td>
            <td>${mhs.bidang}</td>
            <td>${mhs.gender}</td>
            <td>
                <button class="btn-sm btn-edit" onclick='editStudents(${JSON.stringify(mhs)})'>Edit</button>
                <button class="btn-sm btn-delete" onclick="deleteStudents(${mhs.id})">Hapus</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function openAddForm() {
    document.getElementById('form-title').innerText = 'Tambah Students';
    document.getElementById('studentsForm').reset();
    document.getElementById('studentsId').value = '';
    document.getElementById('formModal').style.display = 'flex';
}

function editStudents(mhs) {
    document.getElementById('form-title').innerText = 'Edit Students';
    document.getElementById('studentsId').value = mhs.id;
    document.getElementById('nama').value = mhs.nama;
    document.getElementById('nim').value = mhs.nim;
    document.getElementById('kelas').value = mhs.kelas;
    document.getElementById('nilai').value = mhs.nilai;
    document.getElementById('bidang').value = mhs.bidang;
    document.getElementById('gender').value = mhs.gender;
    document.getElementById('nilaiDisplay').innerText = `(${mhs.nilai})`;
    document.getElementById('formModal').style.display = 'flex';
}

function closeForm() {
    document.getElementById('formModal').style.display = 'none';
}

document.getElementById('studentsForm').onsubmit = async (e) => {
    e.preventDefault();
    const id = document.getElementById('studentsId').value;
    const data = {
        nama: document.getElementById('nama').value,
        nim: document.getElementById('nim').value,
        kelas: document.getElementById('kelas').value,
        nilai: document.getElementById('nilai').value,
        bidang: document.getElementById('bidang').value,
        gender: document.getElementById('gender').value,
    };

    const url = id ? `/api/students/${id}` : '/api/students';
    const method = id ? 'PUT' : 'POST';

    const res = await fetch(url, {
        method: method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });

    const result = await res.json();
    if (result.success) {
        closeForm();
        loadStudents();
    } else {
        alert(result.error);
    }
};

function deleteStudents(id) {
    showConfirm('Yakin ingin menghapus data ini?', async () => {
        const res = await fetch(`/api/students/${id}`, { method: 'DELETE' });
        const result = await res.json();
        if (result.success) {
            loadStudents();
        } else {
            alert(result.error);
        }
    });
}

// ===== MOVIES CRUD =====
async function loadMovies() {
    const res = await fetch('/api/movies');
    const data = await res.json();
    const grid = document.getElementById('moviesGrid');
    grid.innerHTML = '';

    if (data.error) return alert('Error loading movies');

    data.forEach(movie => {
        const card = document.createElement('div');
        card.className = 'movie-card';
        card.innerHTML = `
            <img src="${movie.image_link || 'https://via.placeholder.com/300x450'}" alt="${movie.judul}">
            <div class="movie-info">
                <h3>${movie.judul}</h3>
                <p>${movie.genre} | ${movie.durasi}</p>
                <div class="movie-actions">
                    <button class="btn-sm btn-edit" onclick='editMovie(${JSON.stringify(movie).replace(/'/g, "&#39;")})'>Edit</button>
                    <button class="btn-sm btn-delete" onclick="deleteMovie(${movie.id})">Hapus</button>
                </div>
            </div>
        `;
        grid.appendChild(card);
    });
}

function openMoviesForm() {
    document.getElementById('moviesModalTitle').innerText = 'Tambah Film';
    document.getElementById('moviesForm').reset();
    document.getElementById('movieId').value = '';
    document.getElementById('existingImageLink').value = '';
    document.getElementById('currentPosterPreview').innerHTML = '';
    document.getElementById('moviesModal').style.display = 'flex';
}

function editMovie(movie) {
    document.getElementById('moviesModalTitle').innerText = 'Edit Film';
    document.getElementById('movieId').value = movie.id;
    document.getElementById('movieJudul').value = movie.judul;
    document.getElementById('movieRilis').value = movie.rilis;
    document.getElementById('movieDurasi').value = movie.durasi;
    document.getElementById('movieGenre').value = movie.genre;
    document.getElementById('existingImageLink').value = movie.image_link;

    if (movie.image_link) {
        document.getElementById('currentPosterPreview').innerHTML = `<img src="${movie.image_link}" width="50">`;
    } else {
        document.getElementById('currentPosterPreview').innerHTML = '';
    }

    document.getElementById('moviesModal').style.display = 'flex';
}

function closeMoviesForm() {
    document.getElementById('moviesModal').style.display = 'none';
}

document.getElementById('moviesForm').onsubmit = async (e) => {
    e.preventDefault();
    const id = document.getElementById('movieId').value;
    const formData = new FormData();

    formData.append('judul', document.getElementById('movieJudul').value);
    formData.append('rilis', document.getElementById('movieRilis').value);
    formData.append('durasi', document.getElementById('movieDurasi').value);
    formData.append('genre', document.getElementById('movieGenre').value);
    formData.append('existing_image_link', document.getElementById('existingImageLink').value);

    const fileInput = document.getElementById('movieImage');
    if (fileInput.files[0]) {
        formData.append('image', fileInput.files[0]);
    }

    const url = id ? `/api/movies/${id}` : '/api/movies';
    const method = id ? 'PUT' : 'POST';

    const res = await fetch(url, {
        method: method,
        body: formData
    });

    const result = await res.json();
    if (result.success) {
        closeMoviesForm();
        loadMovies();
    } else {
        alert(result.error);
    }
};

function deleteMovie(id) {
    showConfirm('Yakin ingin menghapus film ini?', async () => {
        const res = await fetch(`/api/movies/${id}`, { method: 'DELETE' });
        const result = await res.json();
        if (result.success) {
            loadMovies();
        } else {
            alert(result.error);
        }
    });
}

// ===== QUIZ CRUD =====
async function loadQuiz() {
    const res = await fetch('/api/quiz');
    const data = await res.json();
    const list = document.getElementById('quizList');
    list.innerHTML = '';

    if (data.error) return alert('Error loading quiz');

    data.forEach(q => {
        const item = document.createElement('div');
        item.className = 'quiz-item';
        item.innerHTML = `
            <div class="quiz-content">
                <h3>${q.question_didi}</h3>
                <ul>
                    <li>A: ${q.chouce1_didi}</li>
                    <li>B: ${q.chouce2_didi}</li>
                    <li>C: ${q.chouce3_didi}</li>
                    <li>D: ${q.chouce4_didi}</li>
                </ul>
                <p><strong>Jawaban:</strong> ${q.answer_didi}</p>
            </div>
            <div class="quiz-actions">
                <button class="btn-sm btn-edit" onclick='editQuiz(${JSON.stringify(q).replace(/'/g, "&#39;")})'>Edit</button>
                <button class="btn-sm btn-delete" onclick="deleteQuiz(${q.question_id_didi})">Hapus</button>
            </div>
        `;
        list.appendChild(item);
    });
}

function openQuizForm() {
    document.getElementById('quizModalTitle').innerText = 'Tambah Pertanyaan';
    document.getElementById('quizForm').reset();
    document.getElementById('quizId').value = '';
    document.getElementById('quizModal').style.display = 'flex';
}

function editQuiz(q) {
    document.getElementById('quizModalTitle').innerText = 'Edit Pertanyaan';
    document.getElementById('quizId').value = q.question_id_didi;
    document.getElementById('quizQuestion').value = q.question_didi;
    document.getElementById('quizChoice1').value = q.chouce1_didi;
    document.getElementById('quizChoice2').value = q.chouce2_didi;
    document.getElementById('quizChoice3').value = q.chouce3_didi;
    document.getElementById('quizChoice4').value = q.chouce4_didi;
    document.getElementById('quizAnswer').value = q.answer_didi;
    document.getElementById('quizModal').style.display = 'flex';
}

function closeQuizForm() {
    document.getElementById('quizModal').style.display = 'none';
}

document.getElementById('quizForm').onsubmit = async (e) => {
    e.preventDefault();
    const id = document.getElementById('quizId').value;
    const data = {
        question_didi: document.getElementById('quizQuestion').value,
        chouce1_didi: document.getElementById('quizChoice1').value,
        chouce2_didi: document.getElementById('quizChoice2').value,
        chouce3_didi: document.getElementById('quizChoice3').value,
        chouce4_didi: document.getElementById('quizChoice4').value,
        answer_didi: document.getElementById('quizAnswer').value,
    };

    const url = id ? `/api/quiz/${id}` : '/api/quiz';
    const method = id ? 'PUT' : 'POST';

    const res = await fetch(url, {
        method: method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });

    const result = await res.json();
    if (result.success) {
        closeQuizForm();
        loadQuiz();
    } else {
        alert(result.error);
    }
};

function deleteQuiz(id) {
    showConfirm('Yakin ingin menghapus pertanyaan ini?', async () => {
        const res = await fetch(`/api/quiz/${id}`, { method: 'DELETE' });
        const result = await res.json();
        if (result.success) {
            loadQuiz();
        } else {
            alert(result.error);
        }
    });
}

// ===== STORAGE =====
async function loadStorage() {
    const res = await fetch('/api/storage/list');
    const data = await res.json();
    const list = document.getElementById('storageList');
    list.innerHTML = '';

    if (data.error) return alert('Error loading storage');

    data.forEach(file => {
        const item = document.createElement('div');
        item.className = 'storage-item';
        item.innerHTML = `
            <div class="file-icon">📄</div>
            <div class="file-info">
                <a href="${file.publicUrl}" target="_blank">${file.name}</a>
                <p>${new Date(file.created_at).toLocaleString()}</p>
            </div>
            <button class="btn-sm btn-delete" onclick="deleteFile('${file.name}')">Hapus</button>
        `;
        list.appendChild(item);
    });
}

async function handleFileUpload(input) {
    if (input.files && input.files[0]) {
        const formData = new FormData();
        formData.append('file', input.files[0]);

        const res = await fetch('/api/storage/upload', {
            method: 'POST',
            body: formData
        });

        const result = await res.json();
        if (result.success) {
            loadStorage();
        } else {
            alert(result.error);
        }
        input.value = '';
    }
}

function deleteFile(fileName) {
    showConfirm(`Yakin ingin menghapus file ${fileName}?`, async () => {
        const res = await fetch('/api/storage/delete', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ fileName })
        });
        const result = await res.json();
        if (result.success) {
            loadStorage();
        } else {
            alert(result.error);
        }
    });
}

// ===== UTILS =====
function showConfirm(message, onConfirm) {
    document.getElementById('confirmMessage').innerText = message;
    document.getElementById('confirmDialog').style.display = 'flex';
    document.getElementById('confirmBtn').onclick = () => {
        onConfirm();
        closeConfirm();
    };
}

function closeConfirm() {
    document.getElementById('confirmDialog').style.display = 'none';
}

// Close modals when clicking outside
window.onclick = function (event) {
    if (event.target.className === 'modal') {
        event.target.style.display = 'none';
    }
}

// Expose functions to window
window.openAddForm = openAddForm;
window.closeForm = closeForm;
window.openMoviesForm = openMoviesForm;
window.closeMoviesForm = closeMoviesForm;
window.openQuizForm = openQuizForm;
window.closeQuizForm = closeQuizForm;
window.closeConfirm = closeConfirm;
window.handleFileUpload = handleFileUpload;
window.logout = logout;
window.deleteStudents = deleteStudents;
window.editStudents = editStudents;
window.deleteMovie = deleteMovie;
window.editMovie = editMovie;
window.deleteQuiz = deleteQuiz;
window.editQuiz = editQuiz;
window.deleteFile = deleteFile;
