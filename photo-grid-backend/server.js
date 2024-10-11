// server.js (Node/Express)
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3000;

// multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/')
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname))
  }
});
const upload = multer({ storage });

// We'll store photos in-memory by code
const photoStorage = new Map();

app.use(express.static('public'));
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Serves an index.html you might have in 'public'
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Upload route (multipart)
app.post('/upload', upload.array('photos'), (req, res) => {
  const { personalCode } = req.body;
  if (!personalCode) {
    return res.status(400).json({ error: 'Personal code is required' });
  }

  // Associate photos with metadata under the code
  const uploaded = req.files.map((file, i) => ({
    path: file.path,
    metadata: req.body[`metadata${i}`] || ''
  }));
  photoStorage.set(personalCode, uploaded);

  res.json({ message: 'Photos uploaded successfully', count: uploaded.length });
});

// Lets you retrieve photos by personal code
app.get('/photos/:personalCode', (req, res) => {
  const code = req.params.personalCode;
  const photos = photoStorage.get(code);

  if (!photos) {
    return res.status(404).json({ error: 'No photos found for this code' });
  }

  res.json({
    photos: photos.map(photo => ({
      url: '/' + photo.path,
      metadata: photo.metadata
    }))
  });
});

// Delete photos for a code
app.delete('/photos/:personalCode', (req, res) => {
  const code = req.params.personalCode;
  const photos = photoStorage.get(code);

  if (photos) {
    photos.forEach(photo => {
      fs.unlink(photo.path, err => {
        if (err) console.error(`Error deleting file ${photo.path}:`, err);
      });
    });
    photoStorage.delete(code);
  }

  res.json({ message: 'Photos deleted successfully' });
});

// Listen on all network interfaces so device can reach it
app.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${port}`);
});
