const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['patient', 'doctor'],
    required: true
  },
  photoUrl: {
    type: String
  },
  // Doctor specific
  specialty: { type: String },
  experience: { type: Number },
  workingHours: { type: String },
  bio: { type: String },
  services: { type: Object },
  // Patient specific
  phone: { type: String },
  birthdate: { type: String },
  gender: { type: String },
  address: { type: String },
  degree: { type: String },
  time: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('user', UserSchema);
