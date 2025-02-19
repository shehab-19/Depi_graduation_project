import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';

const app = express();

app.use(cors());
app.use(express.json());

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/mydb';

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB!');
  })
  .catch((err) => {
    console.error('Error connecting to MongoDB:', err);
  });

app.get('/', (req, res) => {
  res.json({ message: 'Hello from backend!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});