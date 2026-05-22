const express = require('express');
const router = express.Router();

const User = require('../models/User');


// ================= GET ALL USERS =================
router.get('/', async (req, res) => {
    const users = await User.find();
    res.json(users);
});


// ================= DOCTORS =================
router.get('/doctors/all', async (req, res) => {
    const doctors = await User.find({ role: 'doctor' });
    res.json(doctors);
});


// ================= PATIENTS =================
router.get('/patients/all', async (req, res) => {
    const patients = await User.find({ role: 'patient' });
    res.json(patients);
});


// ================= GET USER BY ID =================
router.get('/:id', async (req, res) => {
    const user = await User.findById(req.params.id);

    if (!user) {
        return res.status(404).json({ message: "User not found!" });
    }

    res.json(user);
});


// ================= CREATE USER =================
router.post('/', async (req, res) => {
    const existingUser = await User.findOne({ email: req.body.email });

    if (existingUser) {
        return res.status(400).json({ message: "Email already exists!" });
    }

    const user = await User.create(req.body);
    res.status(201).json(user);
});


// ================= UPDATE USER =================
router.patch('/:id', async (req, res) => {
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
router.delete('/:id', async (req, res) => {
    const deletedUser = await User.findByIdAndDelete(req.params.id);

    if (!deletedUser) {
        return res.status(404).json({ message: "User not found!" });
    }

    res.json({ message: "User deleted successfully!" });
});

module.exports = router;