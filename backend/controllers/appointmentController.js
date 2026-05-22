const Appointment = require('../models/Appointment');
const { validationResult } = require('express-validator');

// Create Appointment
exports.createAppointment = async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    try {
        const { doctorId, date, time, duration } = req.body;
        
        // Calculate minutes for new appointment
        const [h, m] = time.split(':').map(Number);
        const newStart = h * 60 + m;
        const newEnd = newStart + Number(duration || 30);

        // Fetch existing appointments for the same doctor and date (exclude canceled ones)
        const existingAppointments = await Appointment.find({ doctorId, date, status: { $ne: 'Canceled' } });
        
        // Check for overlaps
        for (let appt of existingAppointments) {
             const [ah, am] = appt.time.split(':').map(Number);
             const existingStart = ah * 60 + am;
             const existingEnd = existingStart + Number(appt.duration || 30);
             
             if (newStart < existingEnd && newEnd > existingStart) {
                 return res.status(400).json({ msg: 'Time slot is already booked.' });
             }
        }

        const newAppointment = new Appointment(req.body);
        const appointment = await newAppointment.save();
        res.json(appointment);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// Get Appointments (with query filtration)
exports.getAppointments = async (req, res) => {
    try {
        // Build query object from req.query
        const query = {};
        if (req.query.doctorId) query.doctorId = req.query.doctorId;
        if (req.query.patientId) query.patientId = req.query.patientId;
        if (req.query.status) query.status = req.query.status;
        if (req.query.date) query.date = req.query.date;

        const appointments = await Appointment.find(query).populate('doctorId', ['name']).populate('patientId', ['name']);
        res.json(appointments);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

// Get Appointment by ID
exports.getAppointmentById = async (req, res) => {
    try {
        const appointment = await Appointment.findById(req.params.id);
        if (!appointment) {
            return res.status(404).json({ msg: 'Appointment not found' });
        }
        res.json(appointment);
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Appointment not found' });
        }
        res.status(500).send('Server error');
    }
};

// Update Appointment
exports.updateAppointment = async (req, res) => {
    try {
        let appointment = await Appointment.findById(req.params.id);
        if (!appointment) {
            return res.status(404).json({ msg: 'Appointment not found' });
        }

        appointment = await Appointment.findByIdAndUpdate(
            req.params.id,
            { $set: req.body },
            { new: true }
        );

        res.json(appointment);
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Appointment not found' });
        }
        res.status(500).send('Server error');
    }
};

// Delete Appointment
exports.deleteAppointment = async (req, res) => {
    try {
        const appointment = await Appointment.findById(req.params.id);
        if (!appointment) {
            return res.status(404).json({ msg: 'Appointment not found' });
        }

        await appointment.deleteOne();
        res.json({ msg: 'Appointment removed' });
    } catch (err) {
        console.error(err.message);
        if (err.kind === 'ObjectId') {
            return res.status(404).json({ msg: 'Appointment not found' });
        }
        res.status(500).send('Server error');
    }
};
