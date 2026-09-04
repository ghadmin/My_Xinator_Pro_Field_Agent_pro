import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// "Fake journey" walkthrough played on top of the real Create Appointment
/// page. It opens after navigating there and spotlights each section of the
/// screen with static content only — nothing on the page is modified and no
/// real data is touched.
class CreateAppointmentTutorial {
  CreateAppointmentTutorial._();

  /// Plays the guided walkthrough as an overlay on the current screen.
  /// Call shortly after navigating to the Create Appointment page.
  static void show(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final tutorial = TutorialCoachMark(
      targets: _buildTargets(size),
      colorShadow: const Color(0xff1E293B),
      opacityShadow: 0.9,
      paddingFocus: 10,
      textSkip: 'SKIP',
      textStyleSkip: const TextStyle(color: Colors.white),
      alignSkip: Alignment.topLeft,
      onFinish: () {},
    );

    tutorial.show(context: context, rootOverlay: true);
  }

  /// Static spotlights following the real Create Appointment journey:
  /// the calendar screen first, then the form sections top to bottom.
  static List<TargetFocus> _buildTargets(Size size) {
    return [
      // 1 — pick a day on the calendar (step 0 screen).
      _staticTarget(
        identify: 'select_date',
        position: TargetPosition(
          Size(size.width - 40.w, size.height * 0.28),
          Offset(20.w, size.height * 0.16),
        ),
        contentAlign: ContentAlign.bottom,
        step: 0,
      ),
      // 2 — "Continue to Appointment Details" (appears under the calendar).
      _staticTarget(
        identify: 'continue_button',
        position: TargetPosition(
          Size(size.width - 40.w, 45.h),
          Offset(20.w, size.height * 0.47),
        ),
        contentAlign: ContentAlign.top,
        step: 1,
      ),
      // 3 — Calendar dropdown (CEC / FSM) at the top of the form.
      _staticTarget(
        identify: 'calendar_dropdown',
        position: TargetPosition(
          Size(size.width - 40.w, size.height * 0.06),
          Offset(20.w, size.height * 0.22),
        ),
        contentAlign: ContentAlign.bottom,
        step: 2,
      ),
      // 4 — Service Type dropdown.
      _staticTarget(
        identify: 'service_type',
        position: TargetPosition(
          Size(size.width - 40.w, size.height * 0.06),
          Offset(20.w, size.height * 0.32),
        ),
        contentAlign: ContentAlign.bottom,
        step: 3,
      ),
      // 5 — Appointment Time dropdown.
      _staticTarget(
        identify: 'appointment_time',
        position: TargetPosition(
          Size(size.width - 40.w, size.height * 0.07),
          Offset(20.w, size.height * 0.42),
        ),
        contentAlign: ContentAlign.bottom,
        step: 4,
      ),
      // 6 — Status & Scheduling dropdown.
      _staticTarget(
        identify: 'status_scheduling',
        position: TargetPosition(
          Size(size.width - 40.w, size.height * 0.06),
          Offset(20.w, size.height * 0.54),
        ),
        contentAlign: ContentAlign.top,
        step: 5,
      ),
      // 7 — Any Details notes field.
      _staticTarget(
        identify: 'any_details',
        position: TargetPosition(
          Size(size.width - 40.w, size.height * 0.09),
          Offset(20.w, size.height * 0.64),
        ),
        contentAlign: ContentAlign.top,
        step: 6,
      ),
      // 8 — Sites & Locations / create site.
      _staticTarget(
        identify: 'site_location',
        position: TargetPosition(
          Size(size.width - 40.w, size.height * 0.10),
          Offset(20.w, size.height * 0.76),
        ),
        contentAlign: ContentAlign.top,
        step: 7,
      ),
      // 9 — Create Appointment submit button.
      _staticTarget(
        identify: 'submit_button',
        position: TargetPosition(
          Size(size.width - 40.w, 50.h),
          Offset(20.w, size.height * 0.88),
        ),
        contentAlign: ContentAlign.top,
        step: 8,
      ),
    ];
  }

  /// Builds a spotlight on a static screen area with its step card.
  static TargetFocus _staticTarget({
    required String identify,
    required TargetPosition position,
    required ContentAlign contentAlign,
    required int step,
  }) {
    return TargetFocus(
      identify: identify,
      targetPosition: position,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: contentAlign,
          builder: (context, controller) => _StepCard(
            step: step + 1,
            totalSteps: _steps.length,
            title: _steps[step].title,
            description: _steps[step].description,
            onNext: controller.next,
          ),
        ),
      ],
    );
  }

  /// Static journey data shown on the step cards.
  static const List<_TutorialStep> _steps = [
    _TutorialStep(
      title: 'Select the Date',
      description: 'Tap a day on the calendar to choose the date of the visit.',
    ),
    _TutorialStep(
      title: 'Continue to Appointment Details',
      description:
          'After picking a date, tap Continue to Appointment Details to '
          'open the appointment form.',
    ),
    _TutorialStep(
      title: 'Calendar (CEC / FSM)',
      description:
          'Select the calendar the appointment belongs to — CEC or FSM.',
    ),
    _TutorialStep(
      title: 'Service Type',
      description:
          'Select the service type for the job. It also sets the time '
          'required.',
    ),
    _TutorialStep(
      title: 'Appointment Time',
      description:
          'Choose an appointment time slot that works for the customer.',
    ),
    _TutorialStep(
      title: 'Status & Scheduling',
      description: 'Select the current status of the appointment.',
    ),
    _TutorialStep(
      title: 'Any Details',
      description:
          'Write any details, notes or special instructions for the job.',
    ),
    _TutorialStep(
      title: 'Site & Location',
      description:
          'Select the site and location for the visit, or create a new '
          'site if needed.',
    ),
    _TutorialStep(
      title: 'Create the Appointment',
      description:
          'Tap Create Appointment to save it. The appointment appears '
          'instantly on your schedule.',
    ),
  ];
}

class _TutorialStep {
  const _TutorialStep({required this.title, required this.description});

  final String title;
  final String description;
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.description,
    required this.onNext,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String description;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.sp),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'STEP $step OF $totalSteps',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
                letterSpacing: 0.3,
              ),
            ),
          ),
          SizedBox(height: 10.sp),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 6.sp),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.sp),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onNext,
              child: Text(
                step == totalSteps ? 'FINISH' : 'NEXT',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
