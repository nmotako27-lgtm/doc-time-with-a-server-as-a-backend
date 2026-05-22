const express = require('express');
const router = express.Router();
const { check } = require('express-validator');
const appointmentController = require('../controllers/appointmentController');
const auth = require('../middlewares/auth');

// @route   POST api/appointments
// @desc    Create an appointment
// @access  Private
router.post('/', [auth, [
    check('doctorId', 'Doctor ID is required').not().isEmpty(),
    check('doctorName', 'Doctor Name is required').not().isEmpty(),
    check('patientId', 'Patient ID is required').not().isEmpty(),
    check('patient', 'Patient Name is required').not().isEmpty(),
    check('service', 'Service is required').not().isEmpty(),
    check('day', 'Day is required').not().isEmpty(),
    check('date', 'Date is required').not().isEmpty(),
    check('time', 'Time is required').not().isEmpty()
]], appointmentController.createAppointment);

// @route   GET api/appointments
// @desc    Get all appointments (with filtration via query params)
// @access  Private
router.get('/', auth, appointmentController.getAppointments);

// @route   GET api/appointments/:id
// @desc    Get appointment by ID
// @access  Private
router.get('/:id', auth, appointmentController.getAppointmentById);

// @route   PUT api/appointments/:id
// @desc    Update appointment
// @access  Private
router.put('/:id', auth, appointmentController.updateAppointment);

// @route   DELETE api/appointments/:id
// @desc    Delete appointment
// @access  Private
router.delete('/:id', auth, appointmentController.deleteAppointment);

module.exports = router;
