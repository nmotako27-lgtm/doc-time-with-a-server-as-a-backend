const express = require('express');
const app = express();

const User = require('../models/User');

app.use(express.json());


// ================= GET ALL USERS =================
app.get('/api/users', async (req, res) => {
    const users = await User.find();
    res.json(users);
});


// ================= GET USER BY ID =================
app.get('/api/users/:id', async (req, res) => {
    const user = await User.findById(req.params.id);

    if (!user) {
        return res.status(404).json({ message: "User not found!" });
    }

    res.json(user);
});


// ================= DOCTORS =================
app.get('/api/doctors', async (req, res) => {
    const doctors = await User.find({ role: 'doctor' });
    res.json(doctors);
});


// ================= PATIENTS =================
app.get('/api/patients', async (req, res) => {
    const patients = await User.find({ role: 'patient' });
    res.json(patients);
});


// ================= CREATE USER =================
app.post('/api/users', async (req, res) => {
    const existingUser = await User.findOne({ email: req.body.email });

    if (existingUser) {
        return res.status(400).json({ message: "Email already exists!" });
    }

    const user = await User.create(req.body);
    res.status(201).json(user);
});


// ================= UPDATE USER =================
app.patch('/api/users/:id', async (req, res) => {
    const updatedUser = await User.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true }
    );

    if (!updatedUser) {
        return res.status(404).json({ message: "User not found!" });
    }

    res.json(updatedUser);
});


// ================= DELETE USER =================
app.delete('/api/users/:id', async (req, res) => {
    const deletedUser = await User.findByIdAndDelete(req.params.id);

    if (!deletedUser) {
        return res.status(404).json({ message: "User not found!" });
    }

    res.json({ message: "User deleted successfully!" });
});

module.exports = app;