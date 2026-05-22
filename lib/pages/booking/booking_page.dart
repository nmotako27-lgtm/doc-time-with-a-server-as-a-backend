import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/booking/confirmation_page.dart';
import 'package:flutter_3/services/api_service.dart';
import 'package:flutter_3/services/booking_service.dart';

class BookingPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String serviceName;
  final int duration;
  final double price;

  const BookingPage({
    super.key,
    this.doctorId = 'doctor_1',
    this.doctorName = 'Dr. Nour El-Din',
    this.serviceName = 'General Consultation',
    this.duration = 50,
    this.price = 0.0,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedDay;
  String? selectedTime;
  String? selectedDate;

  static const _darkBlue = Color(0xFF0A2540);
  static const _blue = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFF64B5F6);

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkBlue, _blue, _lightBlue, Color(0xFFE3F2FD)],
  );

  List<String> days = [];
  List<String> dates = [];
  List<String> times = [];

  final Map<String, String> timePeriod = {};
  final BookingService bookingService = BookingService();
  Stream<List<MockAppointment>>? _bookedStream;

  @override
  void initState() {
    super.initState();
    _generateDays();
    _generateTimes();

    if (days.isNotEmpty) {
      selectedDay = days[0];
      selectedDate = dates[0];
    }
    _updateStream();
  }

  void _generateDays() {
    days.clear();
    dates.clear();
    final now = DateTime.now();
    const dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      days.add(dayNames[date.weekday - 1]);
      dates.add("${date.day} ${monthNames[date.month - 1]}");
    }
  }

  void _generateTimes() {
    times.clear();
    timePeriod.clear();
    int interval = widget.duration > 0 ? widget.duration : 50;

    for (int i = 9 * 60 + 50; i <= 13 * 60; i += interval) {
      String t =
          "${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}";
      times.add(t);
      timePeriod[t] = "Morning";
    }

    for (int i = 17 * 60; i <= 21 * 60; i += interval) {
      String t =
          "${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}";
      times.add(t);
      timePeriod[t] = "Evening";
    }
  }

  void _updateStream() {
    if (selectedDate != null) {
      _bookedStream = bookingService.bookedTimes(
        selectedDate!,
        widget.doctorId,
      );
    }
  }

  List<String> _getTimesForPeriod(String period) {
    return times.where((t) => timePeriod[t] == period).toList();
  }

  @override
  Widget build(BuildContext context) {
    final morningTimes = _getTimesForPeriod("Morning");
    final eveningTimes = _getTimesForPeriod("Evening");

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildDoctorCard(),
              const SizedBox(height: 24),
              _buildDayTabs(),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xffF8FBFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: StreamBuilder<List<MockAppointment>>(
                    stream: _bookedStream,
                    builder: (context, snapshot) {
                      final appointments = snapshot.data ?? [];

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                28,
                                24,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    "Morning Slots",
                                    Icons.wb_sunny_rounded,
                                    Colors.orange.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTimeGrid(morningTimes, appointments),
                                  const SizedBox(height: 32),
                                  _buildSectionTitle(
                                    "Evening Slots",
                                    Icons.dark_mode_rounded,
                                    const Color(0xFF3F51B5),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTimeGrid(eveningTimes, appointments),
                                ],
                              ),
                            ),
                          ),
                          _buildBottomButton(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "Book Appointment",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    MockUser? doctor;
    try {
      doctor = MockDB().users.firstWhere((u) => u.uid == widget.doctorId);
    } catch (e) {
      doctor = null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white24,
              backgroundImage: doctor?.photoUrl != null
                  ? NetworkImage(ApiService.getFullImageUrl(doctor!.photoUrl!))
                  : null,
              child: doctor?.photoUrl == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${widget.duration} min",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabs() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          bool selected = selectedDay == days[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = days[index];
                selectedDate = dates[index];
                selectedTime =
                    null; // تصفير الوقت عند تغيير اليوم لمنع خطأ الاختيار الفائت
                _updateStream();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 75,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.05),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _darkBlue.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: selected ? _darkBlue : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dates[index].split(' ')[0],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selected ? _blue : Colors.white70,
                    ),
                  ),
                  Text(
                    dates[index].split(' ')[1],
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? _blue.withOpacity(0.7) : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _darkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeGrid(
    List<String> currentTimes,
    List<MockAppointment> appointments,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentTimes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final timeSlot = currentTimes[index];

        // 1. التحقق من الحجز المسبق في قاعدة البيانات
        bool isBookedInDB = appointments.any(
          (a) =>
              a.time == timeSlot &&
              a.date == selectedDate &&
              a.doctorId == widget.doctorId,
        );

        // 2. التحقق إذا كان الموعد قد فات وقته اليوم
        bool isTimePassed = false;
        final now = DateTime.now();

        if (dates.isNotEmpty && selectedDate == dates[0]) {
          try {
            final parts = timeSlot.split(':');
            final slotHour = int.parse(parts[0]);
            final slotMinute = int.parse(parts[1]);

            final slotDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              slotHour,
              slotMinute,
            );

            if (slotDateTime.isBefore(now)) {
              isTimePassed = true;
            }
          } catch (e) {
            isTimePassed = false;
          }
        }

        bool isUnavailable = isBookedInDB || isTimePassed;
        bool isSelected = selectedTime == timeSlot;

        return GestureDetector(
          onTap: isUnavailable
              ? null
              : () {
                  setState(() {
                    selectedTime = timeSlot;
                  });
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isUnavailable
                  ? Colors.grey.shade100
                  : isSelected
                  ? _blue
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? _blue
                    : isUnavailable
                    ? Colors.grey.shade200
                    : Colors.grey.shade300,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                isBookedInDB
                    ? "Booked"
                    : isTimePassed
                    ? "Passed"
                    : timeSlot,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isUnavailable
                      ? Colors.grey.shade400
                      : isSelected
                      ? Colors.white
                      : _darkBlue,
                  decoration: isUnavailable ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkBlue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            if (selectedTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("Please select a time slot first"),
                ),
              );
              return;
            }

            final currentContext = context;
            final targetServiceName = widget.serviceName;
            final targetDay = selectedDay!;
            final targetDate = selectedDate!;
            final targetTime = selectedTime!;

            try {
              await bookingService.bookAppointment(
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                service: widget.serviceName,
                day: targetDay,
                date: targetDate,
                time: targetTime,
                duration: widget.duration,
                patientName: "Patient",
                phone: "01000000000",
              );

              if (!mounted) return;

              Navigator.push(
                currentContext,
                MaterialPageRoute(
                  builder: (_) => ConfirmationPage(
                    serviceName: targetServiceName,
                    day: targetDay,
                    date: targetDate,
                    time: targetTime,
                  ),
                ),
              );
            } catch (e) {
              if (!mounted) return;

              Navigator.push(
                currentContext,
                MaterialPageRoute(
                  builder: (_) => ConfirmationPage(
                    serviceName: targetServiceName,
                    day: targetDay,
                    date: targetDate,
                    time: targetTime,
                  ),
                ),
              );
            }
          },
          child: const Text(
            "Confirm Booking",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}