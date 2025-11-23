const express = require('express');
const dotenv = require('dotenv');
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });
const { createClient } = require('@supabase/supabase-js');
const path = require('path');
const fs = require('fs');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Supabase client
const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
);

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static('public'));

// ===== AUTH ROUTES =====

// Login route
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    console.log('Login attempt for:', email);

    if (!email || !password) {
        return res.status(400).json({ error: 'Email dan password wajib diisi' });
    }

    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            console.error('Supabase login error:', error);
            return res.status(401).json({ error: error.message });
        }

        console.log('Login successful for:', email);

        // Simpan session di cookie
        res.cookie('session', data.session.access_token, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 24 * 60 * 60 * 1000, // 24 jam
        });

        res.json({
            success: true,
            message: 'Login berhasil',
            user: data.user.email,
        });
    } catch (err) {
        console.error('Server login error:', err);
        res.status(500).json({ error: 'Terjadi kesalahan: ' + err.message });
    }
});

// Register route
app.post('/api/register', async (req, res) => {
    const { email, password, confirmPassword, fullName } = req.body;
    console.log('Register attempt for:', email);

    if (!email || !password || !confirmPassword || !fullName) {
        return res.status(400).json({ error: 'Semua field wajib diisi' });
    }

    if (password !== confirmPassword) {
        return res.status(400).json({ error: 'Password tidak sama' });
    }

    try {
        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    full_name: fullName,
                },
            },
        });

        if (error) {
            console.error('Supabase register error:', error);
            return res.status(400).json({ error: error.message });
        }

        console.log('Register successful for:', email);

        res.json({
            success: true,
            message: 'Registrasi berhasil. Silakan cek email untuk verifikasi.',
        });
    } catch (err) {
        console.error('Server register error:', err);
        res.status(500).json({ error: 'Terjadi kesalahan: ' + err.message });
    }
});

// Reset password - step 1: kirim OTP
app.post('/api/reset-password', async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ error: 'Email wajib diisi' });
    }

    try {
        const { error } = await supabase.auth.resetPasswordForEmail(email);

        if (error) {
            return res.status(400).json({ error: error.message });
        }

        res.json({
            success: true,
            message: 'OTP telah dikirim ke email Anda',
        });
    } catch (err) {
        res.status(500).json({ error: 'Terjadi kesalahan: ' + err.message });
    }
});

// Reset password - step 2: verifikasi OTP dan update password
app.post('/api/verify-otp-reset', async (req, res) => {
    const { email, otp, newPassword, confirmPassword } = req.body;

    if (!email || !otp || !newPassword || !confirmPassword) {
        return res.status(400).json({ error: 'Semua field wajib diisi' });
    }

    if (newPassword !== confirmPassword) {
        return res.status(400).json({ error: 'Password tidak sama' });
    }

    try {
        const { data, error } = await supabase.auth.verifyOtp({
            email,
            token: otp,
            type: 'recovery',
        });

        if (error) {
            return res.status(400).json({ error: error.message });
        }

        // Update password
        const { error: updateError } = await supabase.auth.updateUser({
            password: newPassword,
        });

        if (updateError) {
            return res.status(400).json({ error: updateError.message });
        }

        res.json({
            success: true,
            message: 'Password berhasil direset. Silakan login dengan password baru.',
        });
    } catch (err) {
        res.status(500).json({ error: 'Terjadi kesalahan: ' + err.message });
    }
});

// Logout
app.post('/api/logout', (req, res) => {
    res.clearCookie('session');
    res.json({ success: true, message: 'Logout berhasil' });
});

// ===== CRUD ROUTES (Mahasiswa) =====

// Middleware untuk verifikasi auth
const authMiddleware = (req, res, next) => {
    const token = req.cookies.session;
    if (!token) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    req.token = token;
    next();
};

// GET all students
app.get('/api/students', authMiddleware, async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('students')
            .select('*')
            .order('id', { ascending: true });

        if (error) throw error;
        res.json(data);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST insert student
app.post('/api/students', authMiddleware, async (req, res) => {
    const { nama, nim, kelas, nilai, bidang, gender } = req.body;

    try {
        const { data, error } = await supabase.from('students').insert([
            {
                nama,
                nim: parseInt(nim),
                kelas,
                nilai: parseFloat(nilai),
                bidang,
                gender,
            },
        ]);

        if (error) throw error;
        res.json({ success: true, message: 'Data berhasil ditambahkan', data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT update student
app.put('/api/students/:id', authMiddleware, async (req, res) => {
    const { id } = req.params;
    const { nama, nim, kelas, nilai, bidang, gender } = req.body;

    try {
        const { data, error } = await supabase
            .from('students')
            .update({
                nama,
                nim: parseInt(nim),
                kelas,
                nilai: parseFloat(nilai),
                bidang,
                gender,
            })
            .eq('id', id);

        if (error) throw error;
        res.json({ success: true, message: 'Data berhasil diperbarui', data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE student
app.delete('/api/students/:id', authMiddleware, async (req, res) => {
    const { id } = req.params;

    try {
        const { error } = await supabase.from('students').delete().eq('id', id);

        if (error) throw error;
        res.json({ success: true, message: 'Data berhasil dihapus' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ... (existing code) ...

// ... (existing code) ...

// ===== MOVIES ROUTES (Table: movies) =====

// GET all movies
app.get('/api/movies', authMiddleware, async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('movies')
            .select('*')
            .order('id', { ascending: false });

        if (error) throw error;
        res.json(data);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST insert movie (with image upload)
app.post('/api/movies', authMiddleware, upload.single('image'), async (req, res) => {
    const { judul, rilis, durasi, genre } = req.body;
    const file = req.file;
    let image_link = '';

    try {
        if (file) {
            const fileName = `public/${Date.now()}_${file.originalname}`;
            const { data: uploadData, error: uploadError } = await supabase.storage
                .from('thumbnail')
                .upload(fileName, file.buffer, {
                    contentType: file.mimetype,
                });

            if (uploadError) throw uploadError;

            const { data: urlData } = supabase.storage
                .from('thumbnail')
                .getPublicUrl(fileName);

            image_link = urlData.publicUrl;
        }

        const { data, error } = await supabase.from('movies').insert([
            {
                judul,
                rilis,
                durasi,
                genre,
                image_link,
            },
        ]);

        if (error) throw error;
        res.json({ success: true, message: 'Film berhasil ditambahkan', data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT update movie
app.put('/api/movies/:id', authMiddleware, upload.single('image'), async (req, res) => {
    const { id } = req.params;
    const { judul, rilis, durasi, genre, existing_image_link } = req.body;
    const file = req.file;
    let image_link = existing_image_link;

    try {
        if (file) {
            const fileName = `public/${Date.now()}_${file.originalname}`;
            const { error: uploadError } = await supabase.storage
                .from('thumbnail')
                .upload(fileName, file.buffer, {
                    contentType: file.mimetype,
                });

            if (uploadError) throw uploadError;

            const { data: urlData } = supabase.storage
                .from('thumbnail')
                .getPublicUrl(fileName);

            image_link = urlData.publicUrl;
        }

        const { data, error } = await supabase
            .from('movies')
            .update({
                judul,
                rilis,
                durasi,
                genre,
                image_link,
            })
            .eq('id', id);

        if (error) throw error;
        res.json({ success: true, message: 'Film berhasil diperbarui', data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE movie
app.delete('/api/movies/:id', authMiddleware, async (req, res) => {
    const { id } = req.params;
    // Note: In a real app, we should also delete the image from storage.
    // For simplicity, we'll just delete the record here, or handle it if image_link is passed.

    try {
        const { error } = await supabase.from('movies').delete().eq('id', id);
        if (error) throw error;
        res.json({ success: true, message: 'Film berhasil dihapus' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// ===== QUIZ ROUTES (Table: didi29) =====

// GET all questions
app.get('/api/quiz', authMiddleware, async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('didi29')
            .select('*')
            .order('question_id_didi', { ascending: true });

        if (error) throw error;
        res.json(data);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST insert question
app.post('/api/quiz', authMiddleware, async (req, res) => {
    const { question_didi, chouce1_didi, chouce2_didi, chouce3_didi, chouce4_didi, answer_didi } = req.body;

    try {
        const { data, error } = await supabase.from('didi29').insert([
            {
                question_didi,
                chouce1_didi,
                chouce2_didi,
                chouce3_didi,
                chouce4_didi,
                answer_didi,
            },
        ]);

        if (error) throw error;
        res.json({ success: true, message: 'Pertanyaan berhasil ditambahkan', data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT update question
app.put('/api/quiz/:id', authMiddleware, async (req, res) => {
    const { id } = req.params;
    const { question_didi, chouce1_didi, chouce2_didi, chouce3_didi, chouce4_didi, answer_didi } = req.body;

    try {
        const { data, error } = await supabase
            .from('didi29')
            .update({
                question_didi,
                chouce1_didi,
                chouce2_didi,
                chouce3_didi,
                chouce4_didi,
                answer_didi,
            })
            .eq('question_id_didi', id);

        if (error) throw error;
        res.json({ success: true, message: 'Pertanyaan berhasil diperbarui', data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE question
app.delete('/api/quiz/:id', authMiddleware, async (req, res) => {
    const { id } = req.params;

    try {
        const { error } = await supabase.from('didi29').delete().eq('question_id_didi', id);
        if (error) throw error;
        res.json({ success: true, message: 'Pertanyaan berhasil dihapus' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// ===== STORAGE ROUTES (Bucket: storage) =====

// GET list files
app.get('/api/storage/list', authMiddleware, async (req, res) => {
    try {
        const { data, error } = await supabase.storage.from('storage').list();
        if (error) throw error;

        // Add public URL to each file
        const filesWithUrl = data.map(file => {
            const { data: urlData } = supabase.storage.from('storage').getPublicUrl(file.name);
            return { ...file, publicUrl: urlData.publicUrl };
        });

        res.json(filesWithUrl);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST upload file
app.post('/api/storage/upload', authMiddleware, upload.single('file'), async (req, res) => {
    const file = req.file;
    if (!file) return res.status(400).json({ error: 'No file uploaded' });

    try {
        const fileName = file.originalname; // Or generate unique name
        const { data, error } = await supabase.storage
            .from('storage')
            .upload(fileName, file.buffer, {
                contentType: file.mimetype,
                upsert: true // Allow overwriting
            });

        if (error) throw error;
        res.json({ success: true, message: 'File berhasil diupload', data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE file
app.post('/api/storage/delete', authMiddleware, async (req, res) => {
    const { fileName } = req.body;
    if (!fileName) return res.status(400).json({ error: 'Filename required' });

    try {
        const { error } = await supabase.storage.from('storage').remove([fileName]);
        if (error) throw error;
        res.json({ success: true, message: 'File berhasil dihapus' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Serve HTML files
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

app.get('/register', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'register.html'));
});

app.get('/reset-password', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'resetpassword.html'));
});

app.get('/dashboard', (req, res) => {
    const token = req.cookies.session;
    if (!token) {
        return res.redirect('/');
    }
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});

// Start server
app.listen(PORT, () => {
    console.log(`Server berjalan di http://localhost:${PORT}`);
});
