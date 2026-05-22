const express = require('express');
const router = express.Router();
const { check } = require('express-validator');
const authController = require('../controllers/authController');
const auth = require('../middlewares/auth');

// @route   POST api/auth/signup/patient
router.post('/signup/patient', [
    check('name', 'Name is required').not().isEmpty(),
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Please enter a password with 6 or more characters').isLength({ min: 6 })
], authController.signupPatient);

// @route   POST api/auth/signup/doctor
router.post('/signup/doctor', [
    check('name', 'Name is required').not().isEmpty(),
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Please enter a password with 6 or more characters').isLength({ min: 6 })
], authController.signupDoctor);

// @route   POST api/auth/login/patient
router.post('/login/patient', [
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password is required').exists()
], authController.loginPatient);

// @route   POST api/auth/login/doctor
router.post('/login/doctor', [
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password is required').exists()
], authController.loginDoctor);

// @route   POST api/auth/signup
// @desc    Register user (Deprecated - use specific role signup)
router.post('/signup', [
    check('name', 'Name is required').not().isEmpty(),
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Please enter a password with 6 or more characters').isLength({ min: 6 }),
    check('role', 'Role is required').isIn(['patient', 'doctor'])
], authController.signup);

// @route   POST api/auth/login
// @desc    Authenticate user & get token (Deprecated - use specific role login)
router.post('/login', [
    check('email', 'Please include a valid email').isEmail(),
    check('password', 'Password is required').exists()
], authController.login);

// @route   GET api/auth/user
// @desc    Get user data
// @access  Private
router.get('/user', auth, authController.getUser);

// @route   PUT api/auth/user
// @desc    Update user data
// @access  Private
router.put('/user', auth, authController.updateUser);

// @route   GET api/auth/doctors
// @desc    Get all doctors
// @access  Public
router.get('/doctors', authController.getDoctors);
// ================= FILTERATION =================
router.get('/doctors/filter', authController.filterDoctors);

router.get('/patients/filter', authController.filterPatients);
module.exports = router;
