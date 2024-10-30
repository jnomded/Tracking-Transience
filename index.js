const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const app = express();
const port = 3000;

// Set up multer for handling file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/')
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname))
  }
});

const upload = multer({ storage: storage });

// In-memory storage for photos and metadata (key: personal code, value: array of {path, metadata})
const photoStorage = new Map();

app.use(express.static('public'));
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Serve the HTML file for the web interface
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Handle photo upload
app.post('/upload', upload.array('photos'), (req, res) => {
  const { personalCode } = req.body;
  if (!personalCode) {
    return res.status(400).json({ error: 'Personal code is required' });
  }

  const uploadedFiles = req.files.map((file, index) => ({
    path: file.path,
    metadata: req.body[`metadata${index}`] || ''
  }));
  photoStorage.set(personalCode, uploadedFiles);

  res.json({ message: 'Photos uploaded successfully', count: uploadedFiles.length });
});

// Retrieve photos for a given personal code
app.get('/photos/:personalCode', (req, res) => {
  const { personalCode } = req.params;
  const photos = photoStorage.get(personalCode);

  if (!photos) {
    return res.status(404).json({ error: 'No photos found for this code' });
  }

  res.json({ photos: photos.map(photo => ({
    url: '/' + photo.path,
    metadata: photo.metadata
  })) });
});

// Delete photos when requested (simulating app close)
app.delete('/photos/:personalCode', (req, res) => {
  const { personalCode } = req.params;
  const photos = photoStorage.get(personalCode);

  if (photos) {
    photos.forEach(photo => {
      fs.unlink(photo.path, (err) => {
        if (err) console.error(`Error deleting file ${photo.path}:`, err);
      });
    });
    photoStorage.delete(personalCode);
  }

  res.json({ message: 'Photos deleted successfully' });
});

// Add this line to listen on all network interfaces
app.listen(port, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${port}`);
});