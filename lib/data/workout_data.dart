// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables,
//   curly_braces_in_flow_control_structures, unnecessary_const, prefer_const_declarations

class ExerciseItem {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  // Remote ExerciseDB id (nullable). Keeps local slugs unchanged.
  final String? remoteId;
  // New nullable enrichment fields (backwards compatible)
  final String? bodyPart;
  final String? equipment;
  final String? muscle;
  final List<String> instructions;
  // Local structured fields for easier consumption by the UI
  final List<String> tips;
  final List<String> variations;
  final String? gifUrl;
  final String? videoUrl; // <-- Added
  final double met;

  const ExerciseItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = '',
    this.remoteId,
    this.bodyPart,
    this.equipment,
    this.muscle,
    this.instructions = const [],
    this.tips = const [],
    this.variations = const [],
    this.gifUrl,
    this.videoUrl, // <-- Added
    this.met = 0.0,
  });
  // Returns the best image or video preview for this exercise
  String get resolvedImageUrl {
    assert(!imageUrl.endsWith('.mp4'), 'IMAGE URL MP4 OLAMAZ: $imageUrl');
    return imageUrl;
  }

  // ------- Resolvers for backwards compatibility -------
  String? get resolvedGifUrl =>
      (gifUrl != null && gifUrl!.trim().isNotEmpty) ? gifUrl : null;

  String get resolvedBodyPart {
    if (bodyPart != null && bodyPart!.isNotEmpty) {
      return bodyPart!;
    }

    final lower = imageUrl.toLowerCase();

    if (lower.contains('_chest')) {
      return 'CHEST';
    }
    if (lower.contains('_back')) {
      return 'BACK';
    }
    if (lower.contains('_thighs') ||
        lower.contains('_hips') ||
        lower.contains('_legs')) {
      return 'LEGS';
    }
    if (lower.contains('_shoulder') || lower.contains('_shoulders')) {
      return 'SHOULDERS';
    }
    if (lower.contains('upper-arms') ||
        lower.contains('upper_arms') ||
        lower.contains('_arm')) {
      return 'ARMS';
    }
    if (lower.contains('_waist') ||
        lower.contains('_core') ||
        lower.contains('_abs')) {
      return 'CORE';
    }

    final n = name.toLowerCase();

    if (n.contains('bench') || n.contains('push') || n.contains('chest')) {
      return 'CHEST';
    }
    if (n.contains('squat') || n.contains('lunge') || n.contains('deadlift')) {
      return 'LEGS';
    }
    if (n.contains('row') ||
        n.contains('pull') ||
        n.contains('chin') ||
        n.contains('back')) {
      return 'BACK';
    }
    if (n.contains('press') || n.contains('shoulder') || n.contains('arnold')) {
      return 'SHOULDERS';
    }
    if (n.contains('curl') || n.contains('triceps') || n.contains('dip')) {
      return 'ARMS';
    }
    return 'FULL BODY';
  }

  String get resolvedEquipment {
    if (equipment != null && equipment!.isNotEmpty) {
      return equipment!;
    }

    final n = name.toLowerCase();

    if (n.contains('dumbbell')) {
      return 'DUMBBELL';
    }
    if (n.contains('barbell')) {
      return 'BARBELL';
    }
    if (n.contains('cable')) {
      return 'CABLE';
    }
    if (n.contains('machine') || n.contains('treadmill')) {
      return 'MACHINE';
    }
    if (n.contains('band')) {
      return 'RESISTANCE BAND';
    }
    if (n.contains('push') || n.contains('plank') || n.contains('body')) {
      return 'BODY WEIGHT';
    }
    switch (resolvedBodyPart) {
      case 'CHEST':
      case 'BACK':
      case 'SHOULDERS':
      case 'ARMS':
        return 'DUMBBELL';
      case 'LEGS':
        return 'BARBELL';
      case 'CORE':
        return 'BODY WEIGHT';
      default:
        return 'BODY WEIGHT';
    }
  }

  String get resolvedDescription {
    if (description.isNotEmpty) return description;
    final part = resolvedBodyPart.toLowerCase();
    final equip = resolvedEquipment.toLowerCase();
    final n = name.toLowerCase();
    if (n.contains('push') || n.contains('bench') || n.contains('press')) {
      return '$name is a $equip exercise that primarily targets the $part. It builds pressing strength and stability across the chest, shoulders and triceps.';
    }
    if (n.contains('squat') ||
        n.contains('lunge') ||
        n.contains('deadlift') ||
        n.contains('thrust')) {
      return '$name focuses on lower-body strength and power, emphasizing the $part. Use controlled technique and progress load gradually.';
    }
    if (n.contains('row') ||
        n.contains('pull') ||
        n.contains('chin') ||
        n.contains('pull-up')) {
      return '$name develops pulling strength for the $part, improving back and arm engagement. Keep the shoulder blades active and core braced.';
    }
    if (n.contains('plank') ||
        n.contains('sit') ||
        n.contains('crunch') ||
        n.contains('russian')) {
      return '$name is a core-focused exercise that strengthens the $part and improves trunk stability. Maintain a neutral spine and controlled breathing.';
    }
    if (n.contains('burpee') ||
        n.contains('run') ||
        n.contains('jump') ||
        n.contains('cardio')) {
      return '$name is a conditioning exercise that raises heart rate while engaging multiple muscle groups. Focus on efficient movement and safe landing mechanics.';
    }
    return '$name is an effective exercise that primarily works the $part. Focus on controlled movement and proper technique to get the most benefit.';
  }

  // Time & calorie estimation helpers
  double estimateMinutesFromRepsSets({
    required int reps,
    required int sets,
    double secondsPerRep = 3.0,
    int restSecondsBetweenSets = 45,
  }) {
    if (reps <= 0 || sets <= 0) return 0;

    final workSeconds = reps * sets * secondsPerRep;
    final restSeconds = (sets - 1).clamp(0, sets) * restSecondsBetweenSets;

    return (workSeconds + restSeconds) / 60.0;
  }

  double estimateCalories({
    required double weightKg,
    required double minutes,
  }) {
    if (minutes <= 0 || weightKg <= 0) return 0;
    // Require an explicit per-exercise MET value. If not provided, return 0
    // calories rather than using a name-based fallback. This enforces that
    // each exercise has a static MET value assigned in the data file.
    if (met <= 0) return 0;
    return (met * weightKg * minutes) / 60.0;
  }

  double estimateCaloriesFromRepsSets({
    required double weightKg,
    required int reps,
    required int sets,
  }) {
    final minutes = estimateMinutesFromRepsSets(reps: reps, sets: sets);
    return estimateCalories(weightKg: weightKg, minutes: minutes);
  }

  // If an explicit `met` wasn't provided, map exercise name to a best-estimate MET.
  double _resolvedMetFromName() {
    final n = name.toLowerCase();

    // Exact mappings provided by the user (or close matches)
    if (n.contains('bench press')) {
      return 6.0;
    }
    if (n.contains('palms in incline') || n.contains('incline bench')) {
      return 6.0;
    }
    if (n.contains('decline bench')) {
      return 6.0;
    }
    if (n.contains('push-up') ||
        n.contains('push up') ||
        n.contains('push-up')) {
      return 8.0;
    }
    if (n.contains('chest dip') || n.contains('chest dip')) {
      return 8.0;
    }
    if (n.contains('cable seated neck') || n.contains('neck extension')) {
      return 3.0;
    }
    if (n.contains('dumbbell clean') || n.contains('clean and press')) {
      return 8.5;
    }

    if (n.contains('pull-up') ||
        n.contains('pull up') ||
        n.contains('chin-up') ||
        n.contains('chin up')) {
      return 8.0;
    }
    if (n.contains('romanian deadlift') || n.contains('romanian')) {
      return 6.0;
    }
    if (n.contains('bent-over row') ||
        n.contains('bent over row') ||
        n.contains('row')) {
      return 6.0;
    }
    if (n.contains('suspended row')) {
      return 5.0;
    }
    if (n.contains('wide grip pull')) {
      return 8.0;
    }

    if (n.contains('split squat') ||
        n.contains('sumo squat') ||
        n.contains('lunge')) {
      return 5.5;
    }
    if (n.contains('walking lunge')) {
      return 6.5;
    }
    if (n.contains('single leg squat') || n.contains('pistol')) {
      return 8.0;
    }
    if (n.contains('stiff leg deadlift')) {
      return 6.0;
    }
    if (n.contains('seated calf')) {
      return 4.0;
    }

    if (n.contains('seated shoulder press') || n.contains('arnold press')) {
      return 6.0;
    }
    if (n.contains('lateral raise') ||
        n.contains('front raise') ||
        n.contains('rear delt')) {
      return 3.5;
    }

    if (n.contains('biceps') ||
        n.contains('hammer curl') ||
        n.contains('concentration curl')) {
      return 3.5;
    }
    if (n.contains('triceps') ||
        n.contains('skull crusher') ||
        n.contains('triceps dip')) {
      return 4.0;
    }
    if (n.contains('close-grip push-up')) {
      return 8.0;
    }

    if (n.contains('front plank') || n.contains('plank')) {
      return 3.0;
    }
    if (n.contains('crunch')) {
      return 3.0;
    }
    if (n.contains('wall sit') || n.contains('sit')) {
      return 4.0;
    }
    if (n.contains('russian twist')) {
      return 4.0;
    }
    if (n.contains('hanging leg') || n.contains('hanging')) {
      return 5.0;
    }
    if (n.contains('assault bike')) {
      return 10.0;
    }
    if (n.contains('bridge') || n.contains('mountain climber')) {
      return 7.0;
    }

    if (n.contains('running on treadmill') || n.contains('run')) {
      return 9.8;
    }
    if (n.contains('walking on treadmill') || n.contains('walking')) {
      return 3.5;
    }
    if (n.contains('cycling')) {
      return 7.0;
    }
    if (n.contains('jump rope') || n.contains('jump-rope')) {
      return 12.0;
    }
    if (n.contains('superman row') || n.contains('towel row')) {
      return 4.5;
    }
    if (n.contains('lever stepper') || n.contains('stepper')) {
      return 8.0;
    }
    if (n.contains('high knees')) {
      return 7.0;
    }

    if (n.contains('burpee')) {
      return 10.0;
    }
    if (n.contains('dumbbell burpee')) {
      return 11.0;
    }
    if (n.contains('squat thrust')) {
      return 8.0;
    }
    if (n.contains('thruster')) {
      return 8.5;
    }

    // Fallback estimate for any unmapped exercise.
    return 5.0;
  }

  List<String> get resolvedInstructions {
    if (instructions.isNotEmpty) return List<String>.from(instructions);
    final n = name.toLowerCase();
    if (n.contains('push') || n.contains('bench') || n.contains('press')) {
      return [
        'Set up with feet planted and a stable torso.',
        'Lower under control until the working muscle is challenged.',
        'Drive through the hands/feet to return to the start.',
        'Breathe steadily and repeat for reps with good form.'
      ];
    }
    if (n.contains('squat') || n.contains('lunge') || n.contains('thrust')) {
      return [
        'Stand tall with chest up and feet shoulder-width apart.',
        'Initiate the movement by sending hips back and bending knees.',
        'Drive through the heels to return to standing.',
        'Control the descent and keep knees aligned with toes.'
      ];
    }
    if (n.contains('deadlift')) {
      return [
        'Approach the load with a neutral spine and braced core.',
        'Hinge at the hips and drive the hips forward to stand.',
        'Keep the bar close to the body and push through the heels.',
        'Lower under control to the starting position.'
      ];
    }
    if (n.contains('row') ||
        n.contains('pull') ||
        n.contains('chin') ||
        n.contains('pull-up')) {
      return [
        'Start from a full stretch with scapulae mobile.',
        'Row/pull by driving the elbows back and squeezing the shoulder blades.',
        'Control the eccentric return and avoid shrugging.',
        'Repeat with steady tempo and full range.'
      ];
    }
    if (n.contains('plank') ||
        n.contains('sit') ||
        n.contains('crunch') ||
        n.contains('russian')) {
      return [
        'Find a neutral spine and brace the core.',
        'Maintain steady breathing and controlled movement.',
        'Avoid overarching or rounding the lower back.',
        'Perform for time or reps as appropriate to your level.'
      ];
    }
    if (n.contains('burpee')) {
      return [
        'Begin standing, then drop into a squat and place hands on the floor.',
        'Jump feet back into a plank, perform a push, then jump feet forward.',
        'Explode up into a jump and land softly.',
        'Repeat with consistent intensity.'
      ];
    }
    return [
      'Start in a stable position appropriate for $name.',
      'Engage your core and maintain proper posture throughout the movement.',
      'Perform the main movement with a controlled tempo and full range of motion.',
      'Return to the starting position and repeat for the desired number of reps.'
    ];
  }

  List<String> get resolvedTips {
    if (tips.isNotEmpty) return List<String>.from(tips);
    final n = name.toLowerCase();
    final base = [
      'Prioritize form over weight or speed to avoid injury.',
      'Warm up the relevant joints and muscles before heavy sets.'
    ];
    if (n.contains('push') || n.contains('bench') || n.contains('press')) {
      return [
        ...base,
        'Keep elbows at a safe angle and avoid flaring excessively.'
      ];
    }
    if (n.contains('squat') || n.contains('lunge')) {
      return [
        ...base,
        'Drive through the heels and keep knees tracking over toes.'
      ];
    }
    if (n.contains('deadlift')) {
      return [
        ...base,
        'Maintain a neutral spine and avoid rounding the lower back.'
      ];
    }
    if (n.contains('row') || n.contains('pull')) {
      return [...base, 'Initiate with the scapula and lead with the elbows.'];
    }
    return [...base, 'Control the eccentric phase for better strength gains.'];
  }

  List<String> get resolvedVariations {
    if (variations.isNotEmpty) return List<String>.from(variations);
    final n = name.toLowerCase();
    if (n.contains('push') || n.contains('bench') || n.contains('press')) {
      return [
        'Knee or incline variation for easier option.',
        'Weighted or decline variation to increase difficulty.',
        'Close-grip to emphasize triceps.'
      ];
    }
    if (n.contains('squat') || n.contains('lunge')) {
      return [
        'Assisted or box variation to reduce range.',
        'Single-leg variation to increase difficulty.',
        'Add weight to progress.'
      ];
    }
    if (n.contains('deadlift')) {
      return [
        'Romanian or stiff-leg variant to shift emphasis.',
        'Deficit or trap-bar variation to alter mechanics.',
        'Single-leg for balance and unilateral strength.'
      ];
    }
    if (n.contains('row') || n.contains('pull')) {
      return [
        'Seated or supported variation to reduce load.',
        'Single-arm row to focus on unilateral strength.',
        'Use heavier load for strength emphasis.'
      ];
    }
    if (n.contains('plank') || n.contains('crunch') || n.contains('sit')) {
      return [
        'Knee-supported or incline variation for beginners.',
        'Add instability or single-limb challenge for progression.',
        'Weighted or tempo variation for harder sets.'
      ];
    }
    return [
      'Easier variation: reduce range or use assistance.',
      'Harder variation: increase load, tempo, or range of motion.',
      'Single-limb variation to target unilateral strength.'
    ];
  }
}

class WorkoutCategory {
  final String id;
  final String emoji;
  final String name;
  final List<ExerciseItem> items;

  const WorkoutCategory(
      {required this.id,
      required this.emoji,
      required this.name,
      required this.items});
}

final workoutCategories = <WorkoutCategory>[
  WorkoutCategory(
    id: 'chest',
    emoji: '🏋️‍♂️',
    name: 'Chest Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
          remoteId: "exr_41n2hxnFMotsXTj3",
          id: 'bench_press',
          name: 'Bench Press',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/A8OLBqBa26.jpg",
          videoUrl:
              "assets/workout/video/male-barbell-bench-press-side_KciuhbB.mp4",
          description:
              'The Bench Press is a foundational pressing movement that targets the chest, shoulders and triceps. Focus on stable foot placement, tight upper-back and a controlled bar path to build pressing strength and power.',
          bodyPart: 'CHEST',
          equipment: 'BARBELL',
          instructions: <String>[
            'Lie back on the bench with feet planted and a neutral spine.',
            'Grip the bar slightly wider than shoulder-width and unrack under control.',
            'Lower to the mid-chest with a steady tempo and press back to full extension.',
            'Keep the shoulder blades engaged and exhale during the concentric phase.'
          ],
          tips: <String>[
            'Keep scapulae retracted and maintain a slight arch in the upper back.',
            'Drive through the feet and keep the bar path controlled.',
            'Avoid bouncing the bar off the chest; use a steady tempo.'
          ],
          variations: <String>[
            'Incline Bench Press to emphasize upper chest.',
            'Decline Bench Press to target lower chest.',
            'Dumbbell Bench Press for improved shoulder mobility.'
          ],
          gifUrl:
              'https://cdn.exercisedb.dev/w/videos/41n2hxnFMotsXTj3/41n2hxnFMotsXTj3__barbell-bench-press_Chest.mp4',
          met: 6.0),
      ExerciseItem(
          remoteId: "exr_41n2hsVHu7B1MTdr",
          id: 'palms in incline_bench_press',
          name: 'Palms In Incline Bench Press',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/DhC4s2apCJ.jpg",
          description:
              'An incline palms-in press emphasizes the upper chest and anterior deltoid while using a neutral grip to reduce shoulder strain. Use controlled motion and avoid excessive arching.',
          bodyPart: 'CHEST',
          equipment: 'DUMBBELL',
          instructions: <String>[
            'Set a bench to a 20–35° incline and sit with feet planted.',
            'Hold dumbbells at shoulder height with palms facing each other.',
            'Press the weights up and slightly together until arms are extended, then lower slowly.',
            'Maintain a stable torso and avoid overarching the low back.'
          ],
          tips: <String>[
            'Set the bench to a moderate incline (20–35°).',
            'Keep elbows slightly tucked to protect the shoulder.',
            'Control the descent and press with intent.'
          ],
          variations: <String>[
            'Barbell incline press for heavier loading.',
            'Machine incline press for stability.',
            'Alternating dumbbell incline for unilateral work.'
          ],
          gifUrl:
              'https://cdn.exercisedb.dev/w/videos/41n2hsVHu7B1MTdr/41n2hsVHu7B1MTdr__dumbbell-palms-in-incline-bench-press_Upper-Arms.mp4',
          met: 6.0),
      ExerciseItem(
          remoteId: "exr_41n2hsVHu7B1MTdr",
          id: 'decline_bench_press',
          name: 'Decline Bench Press',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/Fw2auG2NBK.jpg",
          description:
              'The Decline Bench Press shifts emphasis to the lower chest and can allow stronger pressing angles for some lifters. Maintain tightness through the torso and a steady tempo.',
          bodyPart: 'CHEST',
          equipment: 'DUMBBELL',
          instructions: <String>[
            'Lie on a decline bench with feet secured and maintain a stable core.',
            'Grip the weights/bar and lower under control to the lower chest.',
            'Press back up explosively while keeping the shoulder blades retracted.',
            'Use a spotter for heavy sets and avoid excessive shoulder extension.'
          ],
          tips: <String>[
            'Secure feet and keep the torso stable on the decline bench.',
            'Use a controlled eccentric to protect the shoulders.',
            'Choose a spotter for heavy sets.'
          ],
          variations: <String>[
            'Decline dumbbell press for range of motion control.',
            'Cable decline press for constant tension.',
            'Close-grip decline to emphasize triceps.'
          ],
          gifUrl:
              'https://cdn.exercisedb.dev/w/videos/41n2hsVHu7B1MTdr/41n2hsVHu7B1MTdr__decline-bench-press_Upper-Arms.mp4',
          met: 6.0),
      ExerciseItem(
        remoteId: 'exr_41n2hNXJadYcfjnd',
        id: 'push_up',
        name: 'Push-Up',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/dK9YEfnDTi.jpg",
        videoUrl:
            "assets/workout/video/male-Bodyweight-diamond-push-ups-side.mp4",
        description:
            "Push-ups are a versatile exercise that strengthens the chest, shoulders, triceps, and core muscles. They are ideal for improving upper body strength and endurance without equipment and can be modified for all fitness levels.",
        bodyPart: 'CHEST',
        equipment: 'BODY WEIGHT',
        // Detailed step instructions (from ExerciseDB gifUrl: 'https://cdn.exercisedb.dev/w/videos/G8ZH9KB/41n2hNXJadYcfjnd__Push-up-m_Chest.mp4',)
        instructions: <String>[
          'Lower your body until your chest is close to the floor, keeping your back straight and your elbows close to your body.',
          'Push your body up, extending your arms fully but without locking your elbows, while maintaining your body in a straight line.',
          'Pause for a moment at the top of the push-up.',
          'Lower your body back down to the starting position, ensuring you don\'t drop your body too quickly, and repeat the exercise.',
        ],
        // Structured local tips and variations so UI can consume them directly
        tips: <String>[
          'Hand Position — hands should be shoulder-width apart, directly under your shoulders to avoid excess strain.',
          'Full Range of Motion — lower until chest nearly touches floor and push back to full extension.',
          'Controlled Movement — avoid rushing; control descent and ascent for safety and effectiveness.',
        ],
        variations: <String>[
          'Diamond Push-up — targets triceps (hands form a diamond).',
          'Wide Grip Push-up — places more focus on chest muscles.',
          'Decline Push-up — elevating feet increases difficulty.',
          'Spiderman Push-up — adds core and hip flexor challenge.',
        ],
        // Use the video URL as demonstration media
        gifUrl:
            'https://cdn.exercisedb.dev/w/videos/G8ZH9KB/41n2hNXJadYcfjnd__Push-up-m_Chest.mp4',
        met: 8.0,
        // Keywords to help search/filter — also embedded in description for display
        // (kept here as part of description to avoid changing model shape)
        // Additional metadata appended to description
      ),
      ExerciseItem(
          remoteId: "exr_41n2hkK8hGAcSnW7",
          id: 'chest_dip',
          name: 'Chest Dip',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/w39q9vcRo1.jpg",
          description:
              'Chest Dips are a bodyweight pressing variation that targets the lower chest and triceps. Lean slightly forward to increase chest recruitment and control the depth for shoulder safety.',
          bodyPart: 'CHEST',
          equipment: 'BODY WEIGHT',
          instructions: <String>[
            'Grip parallel bars and lift yourself up to a locked-out position.',
            'Lean the torso slightly forward and lower until the shoulders are comfortably below the elbows.',
            'Drive back up through the hands, keeping control and avoiding shoulder pain.',
            'Progress with added weight once bodyweight dips become easy.'
          ],
          tips: <String>[
            'Lean the torso forward to emphasize chest.',
            'Keep shoulders packed and avoid excessive forward roll.',
            'Use assisted variations or band support if needed.'
          ],
          variations: <String>[
            'Weighted dips for progressive overload.',
            'Assisted machine dips for beginners.',
            'Ring dips to increase instability and core demand.'
          ],
          gifUrl:
              'https://cdn.exercisedb.dev/w/videos/41n2hkK8hGAcSnW7/41n2hkK8hGAcSnW7__chest-dip_Chest.mp4',
          met: 8.0),
      ExerciseItem(
          remoteId: "exr_41n2hn2kPMag9WCf",
          id: 'cable_seated_neck_extention',
          name: 'Cable Seated Neck Extension',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/iqDuGsnDUE.jpg",
          description:
              'The Cable Seated Neck Extension targets the posterior neck extensors and upper trapezius. Use light load and strict control—this should be approached cautiously and with good technique.',
          bodyPart: 'CHEST',
          equipment: 'CABLE',
          instructions: <String>[
            'Sit upright and attach a light handle for controlled resistance.',
            'Keep the chin slightly tucked and extend the neck using the posterior neck muscles.',
            'Move slowly through a small range and avoid ballistic motion.',
            'Use very light loads and higher reps for endurance work.'
          ],
          tips: <String>[
            'Use light resistance and control the movement.',
            'Keep the chin tucked slightly and avoid hyperextension.',
            'Perform higher reps for endurance rather than heavy loading.'
          ],
          variations: <String>[
            'Prone neck extensions on a bench for a bodyweight option.',
            'Isometric holds for neck endurance.',
            'Use a small plate or band for gentle loading.'
          ],
          gifUrl:
              'https://cdn.exercisedb.dev/w/videos/41n2hn2kPMag9WCf/41n2hn2kPMag9WCf__cable-seated-neck-extension_Chest.mp4',
          met: 3.0),
      ExerciseItem(
          remoteId: "exr_41n2hXfpvSshoXWG",
          id: 'dumbbell_clean_and_press',
          name: 'Dumbbell Clean andPress',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/1OBFu6DAxW.jpg",
          videoUrl:
              "assets/workout/video/male-Dumbbells-dumbbell-hang-clean-and-press-side.mp4",
          description:
              'The Dumbbell Clean and Press is a compound full-body movement that builds power, coordination and pressing strength. Focus on a strong hip drive into the clean and a stable press overhead.',
          bodyPart: 'CHEST',
          equipment: 'DUMBBELL',
          instructions: <String>[
            'Start standing with dumbbells at your sides and a braced core.',
            'Explode from the hips to bring the dumbbells to the rack position (clean).',
            'Stabilize briefly then press the dumbbells overhead with controlled movement.',
            'Lower under control and reset for the next rep.'
          ],
          tips: <String>[
            'Explode from the hips during the clean and receive the dumbbell in a strong rack position.',
            'Brace the core before pressing overhead.',
            'Use a controlled descent and avoid excessive lumbar extension.'
          ],
          variations: <String>[
            'Single-arm clean and press for unilateral stability.',
            'Power clean + push press for speed-strength.',
            'Seated dumbbell press to remove hip drive.'
          ],
          gifUrl:
              'https://cdn.exercisedb.dev/w/videos/41n2hXfpvSshoXWG/41n2hXfpvSshoXWG__dumbbell-clean-and-press_Weightlifting_720.mp4',
          met: 8.5),
      ExerciseItem(
          remoteId: "exr_41n2hXfpvSshoXWG",
          id: 'chest_dips',
          name: 'Chest Dips',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/w39q9vcRo1.jpg",
          description:
              'Chest Dips (duplicate listing) are presented here to give another dip option targeting the chest and triceps. Focus on forward lean and controlled depth to emphasize chest fibers.',
          bodyPart: 'CHEST',
          equipment: 'BODY WEIGHT',
          instructions: <String>[
            'Use parallel bars and lift to the starting position with arms extended.',
            'Lean slightly forward and lower with control to feel the lower chest.',
            'Press back up without locking the shoulders; control the descent on each rep.',
            'Modify range or use assistance if shoulders feel strained.'
          ],
          tips: <String>[
            'Use full range but avoid painful end ranges in the shoulder.',
            'Control tempo and avoid excessive swinging.',
            'Progress with added weight or band assistance as needed.'
          ],
          variations: <String>[
            'Parallel bar dips for strength.',
            'Ring dips for increased instability.',
            'Bench-supported dips for beginners.'
          ],
          gifUrl:
              'https://cdn.exercisedb.dev/w/videos/41n2hXfpvSshoXWG/41n2hXfpvSshoXWG__chest-dips_Weightlifting_720.mp4',
          met: 8.0),
    ],
  ),
  WorkoutCategory(
    id: 'back',
    emoji: '🧗‍♂️',
    name: 'Back Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
        remoteId: "exr_41n2hU4y6EaYXFhr",
        id: 'pull_up',
        name: 'Pull-Up',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/gNdMNPVxAj.jpg",
        videoUrl: "assets/workout/video/male-bodyweight-pullup-front.mp4",
        description:
            'Pull-ups develop upper-body pulling strength, focusing on the lats, rhomboids and biceps. Emphasize a full range of motion and controlled descent to build strength and scapular control.',
        bodyPart: 'BACK',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Grip the bar slightly wider than shoulder-width with palms facing away.',
          'Hang with scapulae engaged, then initiate the pull by driving the elbows down and back.',
          'Pull until your chin clears the bar (or chest to bar for full reps).',
          'Lower under control to a dead hang and repeat for repetitions.'
        ],
        tips: <String>[
          'Retract the shoulder blades before each rep to engage the lats.',
          'Avoid kipping unless performing a kipping variation; keep the torso stable.'
        ],
        variations: <String>[
          'Assisted pull-up (band or machine)',
          'Weighted pull-up for progression'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/3XMA2St/41n2hU4y6EaYXFhr__Pull-up-(neutral-grip)_Back.png',
        met: 8.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hd6SThQhAdnZ",
        id: 'chin_up',
        name: 'Chin-Up',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/TLX9vGr1dx.jpg",
        videoUrl: "assets/workout/video/male-bodyweight-chinup-front.mp4",
        description:
            'Chin-ups emphasize the biceps and lower lats while still providing strong upper-back activation. Use a supinated grip and focus on smooth, full-range reps.',
        bodyPart: 'BACK',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Grasp the bar with an underhand or neutral grip, hands shoulder-width apart.',
          'Engage the scapulae and pull the chest toward the bar while keeping the torso upright.',
          'Lower slowly back to the start with control.'
        ],
        tips: <String>[
          'Lead with the chest rather than the chin to maximize back recruitment.',
          'Use negatives or assistance if you cannot complete full reps yet.'
        ],
        variations: <String>['Close-grip chin-up', 'Weighted chin-up'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/MSgUDiH/41n2hd6SThQhAdnZ__Chin-ups-(narrow-parallel-grip)_Back.png',
        met: 8.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hsBtDXapcADg",
        id: 'pull-up-variant',
        name: 'Pull-Up (Variant)',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/DMKexKmHFn.jpg",
        description:
            'A pull-up variant that emphasizes upper-back and lat engagement. Useful for programming different grip widths and progressions.',
        bodyPart: 'BACK',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Set grip width according to desired emphasis (wide for lats, narrow for biceps).',
          'Pull with intent, leading with the elbows and chest towards the bar.',
          'Control the descent and avoid excessive swinging.'
        ],
        tips: <String>['Try tempo reps to build eccentric strength.'],
        variations: <String>['Wide-grip pull-up', 'Neutral-grip pull-up'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/qx0CUFh/41n2hsBtDXapcADg__Pull-up_Back.png',
        met: 8.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hn8rpbYihzEW",
        id: 'romanian_deadlift',
        name: 'Romanian Deadlift',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/3wgSOkOkH5.jpg",
        description:
            'The Romanian Deadlift targets the hamstrings, glutes and posterior chain while also strengthening the lower back. Focus on a hip hinge and maintain a neutral spine throughout.',
        bodyPart: 'LEGS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Stand tall with a slight bend in the knees and hold the dumbbells at thigh level.',
          'Hinge at the hips, pushing them back while keeping the spine neutral and core engaged.',
          'Lower the weights until you feel a stretch in the hamstrings, then drive hips forward to return to standing.'
        ],
        tips: <String>[
          'Keep the chest up and shoulders back to protect the lower back.',
          'Use a controlled tempo and avoid collapsing at the bottom.'
        ],
        variations: <String>['Single-leg RDL', 'Barbell Romanian Deadlift'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/QxA3A5m/41n2hn8rpbYihzEW__Dumbbell-Romanian-Deadlift_Hips.png',
        met: 6.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hY9EdwkdGz9a",
        id: 'bent_over_row',
        name: 'Bent-Over Row',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/Ndd2gbg1ko.jpg",
        description:
            'Bent-over rows build mid-back thickness and lat strength. Use a brace in the core and pull to the lower ribs while maintaining a strong hip hinge.',
        bodyPart: 'BACK',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Hinge at the hips with a flat back and hold the dumbbells.',
          'Row the weights toward your lower ribs, squeezing the shoulder blades together.',
          'Lower with control and reset before the next rep.'
        ],
        tips: <String>[
          'Avoid using momentum — initiate the pull with the lats and scapulae.',
          'Keep a neutral neck and strong core brace throughout.'
        ],
        variations: <String>[
          'Single-arm dumbbell row',
          'Barbell bent-over row'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/ok68B3e/41n2hY9EdwkdGz9a__Dumbbell-Bent-over-Row_back_Back.png',
        met: 6.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hdkBpqwoDmVq",
        id: 'suspended_row',
        name: 'Suspended Row',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/bXwXW2WUCj.jpg",
        description:
            'Suspended rows (inverted rows) are a bodyweight horizontal pulling variation that strengthens the mid-back, rear delts and biceps. Adjust foot position to change difficulty.',
        bodyPart: 'BACK',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Set the suspension trainer or bar at an appropriate height and grip with hands shoulder-width apart.',
          'Walk your feet forward to increase difficulty and keep the body straight from head to heels.',
          'Pull your chest to the handles/bar, squeezing the shoulder blades, then lower with control.'
        ],
        tips: <String>['Maintain a rigid plank line and avoid sagging hips.'],
        variations: <String>['Ring row', 'Feet-elevated inverted row'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/moTFBCp/41n2hdkBpqwoDmVq__Suspended-Row_back.png',
        met: 5.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hftBVLiXgtRQ",
        id: 'wide_grip_pull_up',
        name: 'Wide Grip Pull-Up',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/KTxTtuwOqD.jpg",
        description:
            'Wide-grip pull-ups place greater emphasis on the upper lats and create a broader back appearance. Use scapular control and avoid excessive shrugging during the movement.',
        bodyPart: 'BACK',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Grip the bar wider than shoulder-width and engage the scapulae.',
          'Pull the body up by driving the elbows down until the chin clears the bar.',
          'Lower under control and reset at the bottom.'
        ],
        tips: <String>[
          'If grip limits you, use straps or an assisted variation.'
        ],
        variations: <String>[
          'Neutral-grip pull-up',
          'Weighted wide-grip pull-up'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/KBzpP5C/41n2hftBVLiXgtRQ__Wide-Grip-Pull-Up_Back.png',
        met: 8.0,
      ),
    ],
  ),
  WorkoutCategory(
    id: 'legs',
    emoji: '🦵',
    name: 'Leg Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
        remoteId: "exr_41n2hHRszDHarrxK",
        id: 'split_squat',
        name: 'Split Squat',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/SBq6QCqfxq.jpg",
        videoUrl: "assets/workout/video/male-bodyweight-split-squat-front.mp4",
        description:
            'Split squats develop unilateral leg strength, balance and hip stability. Keep the torso upright and drive through the front heel for best results.',
        bodyPart: 'LEGS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Stand in a split stance with rear foot elevated (optional).',
          'Lower the back knee toward the floor while keeping the front knee aligned with the toes.',
          'Drive through the front foot to return to the start.'
        ],
        tips: <String>['Maintain an upright torso and steady tempo.'],
        variations: <String>['Bulgarian split squat', 'Weighted split squat'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/mj01SgJ/41n2hHRszDHarrxK__Split-Squats_Thighs.png',
        met: 5.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hYAP9oGEZk2P",
        id: 'sumo_squat',
        name: 'Sumo Squat',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/clrq0UgFbo.jpg",
        description:
            'Sumo squats emphasize the inner thighs and glutes thanks to a wider stance and toe flare. Use a controlled descent and drive through the heels.',
        bodyPart: 'LEGS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Stand with a wide stance and toes pointed outward.',
          'Hinge at the hips and bend the knees to lower into a squat while keeping the chest up.',
          'Drive through the heels to return to standing.'
        ],
        tips: <String>[
          'Keep knees tracking over toes; avoid collapsing the knees inward.'
        ],
        variations: <String>[
          'Weighted sumo squat',
          'Sumo deadlift stance squat'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/nKmfbcf/41n2hYAP9oGEZk2P__Sumo-Squat-m_Thighs.png',
        met: 5.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hYXWwoxiUk57",
        id: 'lunges',
        name: 'Lunges',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/pY88n4Aoim.jpg",
        description:
            'Lunges are a foundational unilateral leg exercise that strengthen quads, glutes and improve balance. Step far enough that the front knee stays behind the toes.',
        bodyPart: 'LEGS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Step forward with one leg and lower until both knees are bent at ~90°.',
          'Keep the torso tall and drive through the front heel to return to standing.'
        ],
        tips: <String>[
          'Control the descent; avoid letting the knee cave inward.'
        ],
        variations: <String>[
          'Reverse lunge',
          'Walking lunge',
          'Weighted lunge'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/svKtEC0/41n2hYXWwoxiUk57__Lunge_Hips.png',
        met: 5.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hQHmRSoUkk9F",
        id: 'walking_lunges',
        name: 'Walking Lunges',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/g2s9vxBfWN.jpg",
        videoUrl: "assets/workout/video/male-Recovery-lunge-walking-front.mp4",
        description:
            'Walking lunges build unilateral strength and conditioning while challenging balance and hip control. Keep an athletic posture and long stride.',
        bodyPart: 'LEGS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Take a long step forward and lower into a lunge, then push through the front foot to stand and step forward with the other leg.',
          'Repeat while maintaining a steady gait and controlled tempo.'
        ],
        tips: <String>['Keep cadence steady and core engaged for balance.'],
        variations: <String>[
          'Walking lunges with dumbbells',
          'Cross-over lunges'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/vxsAnsy/41n2hQHmRSoUkk9F__Walking-Lunge-Male_Hips.png',
        met: 6.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hd78zujKUEWK",
        id: 'single_leg_squat',
        name: 'Single Leg Squat',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/MosYINt7dV.jpg",
        videoUrl:
            "assets/workout/video/male-Recovery-squat-concentric-single-leg-front.mp4",
        description:
            'Single leg squats (pistols) build strength, mobility and balance in each leg. Use assistance or a box progression if mobility or balance is limited.',
        bodyPart: 'LEGS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Stand on one leg and lower yourself as far as mobility allows while keeping the chest upright.',
          'Use the opposite leg for balance or a light assist if needed, then drive up through the standing heel.'
        ],
        tips: <String>[
          'Progress with assisted variations before attempting full pistols.'
        ],
        variations: <String>[
          'Box-assisted pistol',
          'Weighted single-leg squat'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/motvNua/41n2hd78zujKUEWK__Single-Leg-Squat-(pistol)-male_Thighs.png',
        met: 8.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hcw2FN534HcA",
        id: 'dumbbell_stiff_leg_deadlift',
        name: 'Dumbbell Stiff Leg Deadlift',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/1aHXOCzatq.jpg",
        description:
            'Dumbbell stiff-leg deadlifts target the hamstrings and glutes with an emphasis on hip hinge mechanics. Keep a slight knee bend and hinge from the hips.',
        bodyPart: 'LEGS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Stand with dumbbells at thigh level and a slight bend in the knees.',
          'Hinge at the hips, lowering the dumbbells while keeping the back flat until a hamstring stretch is felt.',
          'Return to standing by driving the hips forward.'
        ],
        tips: <String>['Avoid rounding the lower back; hinge from the hips.'],
        variations: <String>['Romanian deadlift', 'Single-leg RDL'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/ep9ZHO7/41n2hcw2FN534HcA__Dumbbell-Stiff-Leg-Deadlift_Waist.png',
        met: 6.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hn8rpbYihzEW",
        id: 'romanian_deadlift_alt',
        name: 'Romanian Deadlift',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/3wgSOkOkH5.jpg",
        description:
            'Romanian deadlifts reinforce hip-hinge mechanics and strengthen the posterior chain. Maintain a neutral spine and hinge at the hips for best transfer to athletic movement.',
        bodyPart: 'LEGS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Stand with a slight knee bend and hold dumbbells in front of the thighs.',
          'Push the hips back, lowering the weights while keeping the back flat.',
          'Return by squeezing the glutes and driving the hips forward.'
        ],
        tips: <String>[
          'Focus on hip drive rather than lowering the torso excessively.'
        ],
        variations: <String>['Barbell RDL', 'Single-leg RDL'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/QxA3A5m/41n2hn8rpbYihzEW__Dumbbell-Romanian-Deadlift_Hips.png',
        met: 6.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hTs4q3ihihZs",
        id: 'seated_calf_raise',
        name: 'Seated Calf Raise',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/4TWa5X9NV0.jpg",
        description:
            'Seated calf raises isolate the soleus and lower calf muscles. Use a full range of motion and controlled tempo for best development.',
        bodyPart: 'LEGS',
        equipment: 'BARBELL',
        instructions: <String>[
          'Sit with the barbell or machine pad across the thighs and push through the balls of your feet to raise the heels.',
          'Lower slowly into a full stretch and repeat for sets.'
        ],
        tips: <String>[
          'Perform slow eccentrics and pause at the top for full contraction.'
        ],
        variations: <String>['Standing calf raise', 'Donkey calf raise'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/ny7VIEO/41n2hTs4q3ihihZs__Barbell-Seated-Calf-Raise_Calves.png',
        met: 4.0,
      ),
    ],
  ),
  WorkoutCategory(
    id: 'shoulders',
    emoji: '🤾‍♂️',
    name: 'Shoulder Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
        remoteId: "exr_41n2hs6camM22yBG",
        id: 'seated_shoulder_press',
        name: 'Seated Shoulder Press',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/bQUAOjC7qA.jpg",
        description:
            'Seated shoulder presses build overhead pressing strength targeting the deltoids and triceps. Keep a neutral spine and press in a controlled path.',
        bodyPart: 'SHOULDERS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Sit with back supported and dumbbells at shoulder height.',
          'Press the weights overhead until arms are extended without locking the elbows.',
          'Lower under control back to shoulder height.'
        ],
        tips: <String>[
          'Avoid overarching the lower back by bracing the core.',
          'Use a full, controlled range and avoid rapid bouncing.'
        ],
        variations: <String>[
          'Standing dumbbell press',
          'Barbell overhead press'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/y7xLPmP/41n2hs6camM22yBG__Dumbbell-Seated-Shoulder-Press_Shoulders.png',
        met: 6.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hMRXm49mM62z",
        id: 'arnold_press',
        name: 'Arnold Press',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/L0IHjzfG7P.jpg",
        description:
            'The Arnold press adds a rotation to the overhead press, targeting all three heads of the deltoid and promoting shoulder stability and mobility.',
        bodyPart: 'SHOULDERS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Start with dumbbells in front of the shoulders, palms facing you.',
          'Rotate the palms outward while pressing overhead, then reverse on the descent.',
          'Control the rotation to protect the shoulder joint.'
        ],
        tips: <String>[
          'Use moderate weight to preserve clean rotation mechanics.'
        ],
        variations: <String>['Seated Arnold press', 'Single-arm Arnold press'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/x8gEzvq/41n2hMRXm49mM62z__Dumbbell-Arnold-Press-II_Shoulders.png',
        met: 6.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hjuGpcex14w7",
        id: 'lateral_raise',
        name: 'Lateral Raise',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/qODXfaAVcz.jpg",
        description:
            'Lateral raises isolate the lateral deltoid to build shoulder width and definition. Perform with a slight elbow bend and controlled tempo.',
        bodyPart: 'SHOULDERS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Stand tall with a slight bend in the elbows and raise the dumbbells out to the sides to shoulder height.',
          'Lower slowly back to the start with control.'
        ],
        tips: <String>['Avoid swinging; use lighter weight for strict form.'],
        variations: <String>['Cable lateral raise', 'Seated lateral raise'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/wINC5NY/41n2hjuGpcex14w7__Dumbbell-Lateral-Raise_shoulder.png',
        met: 3.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2howQHvcrcrW6",
        id: 'front_raise',
        name: 'Front Raise',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/7ap5Us3CPK.jpg",
        description:
            'Front raises primarily target the anterior deltoid and are useful for developing front shoulder strength and aesthetics. Use controlled motion and moderate loads.',
        bodyPart: 'SHOULDERS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Hold dumbbells in front of your thighs with an overhand grip.',
          'Raise them straight in front of you to shoulder height with a slight bend in the elbows.',
          'Lower slowly to the starting position.'
        ],
        tips: <String>[
          'Keep core tight and avoid using momentum from the torso.'
        ],
        variations: <String>['Plate front raise', 'Cable front raise'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/1xKTESs/41n2howQHvcrcrW6__Dumbbell-Front-Raise_Shoulders.png',
        met: 3.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hyNf5GebszTf",
        id: 'dumbbell_rear_delt_fly',
        name: 'Dumbbell Rear Delt Fly',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/6Ak3e2G7EC.jpg",
        description:
            'Rear delt flies strengthen the posterior deltoids and upper back, improving shoulder health and posture. Use light weights and focus on scapular retraction.',
        bodyPart: 'SHOULDERS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Hinge at the hips with a flat back and hold the dumbbells beneath you.',
          'Raise the weights out to the sides with a slight bend in the elbows, squeezing the rear delts.',
          'Lower with control and repeat.'
        ],
        tips: <String>['Prioritize scapular movement over heavy loads.'],
        variations: <String>['Reverse pec-deck', 'Cable rear delt fly'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/xneLPAv/41n2hyNf5GebszTf__Dumbbell-Rear-Delt-Fly-(female)_Shoulders.png',
        met: 3.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hdkBpqwoDmVq",
        id: 'suspended_row',
        name: 'Suspended Row',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/bXwXW2WUCj.jpg",
        description:
            'Suspended rows are a horizontal pulling movement that target the mid-back and rear delts; included here as a shoulder-adjacent posterior chain exercise.',
        bodyPart: 'BACK',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Set the bar or rings at mid-height and grip with hands shoulder-width apart.',
          'Walk your feet forward to increase difficulty and pull your chest toward the handles, squeezing the shoulder blades.',
          'Lower with control to the starting position.'
        ],
        tips: <String>[
          'Keep the body in a straight line and avoid letting the hips sag.'
        ],
        variations: <String>['Ring rows', 'Feet-elevated inverted row'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/moTFBCp/41n2hdkBpqwoDmVq__Suspended-Row_back.png',
        met: 5.0,
      ),
    ],
  ),
  WorkoutCategory(
    id: 'arms',
    emoji: '💪',
    name: 'Arm Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
        remoteId: "exr_41n2hxqpSU5p6DZv",
        id: 'biceps_leg_concentration_curl',
        name: 'Biceps Leg Concentration Curl',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/YXSxsv8zit.jpg",
        description:
            'A strict single-arm curl variation that isolates the biceps for peak contraction. Use a slow, controlled tempo and avoid swinging.',
        bodyPart: 'ARMS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Sit with the working elbow braced against the inner thigh.',
          'Curl the dumbbell with a full range of motion, squeezing at the top.',
          'Lower with control and repeat for the desired reps.'
        ],
        tips: <String>[
          'Focus on elbow stability to prevent shoulder involvement.',
          'Use lighter weight to prioritize form and contraction.'
        ],
        variations: <String>[
          'Seated concentration curl',
          'Incline dumbbell curl'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/a6Od29C/41n2hxqpSU5p6DZv__Biceps-Leg-Concentration-Curl_Upper-Arms.png',
        met: 3.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hHH9bNfi98YU",
        id: 'triceps_dips_floor',
        name: 'Triceps Dips Floor',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/mc56eseHDh.jpg",
        description:
            'Floor dips target the triceps with a limited range of motion and are useful when no parallel bars are available. Keep the elbows close to the body.',
        bodyPart: 'ARMS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Sit on the floor with hands behind you and fingers pointing forward.',
          'Lift your hips and bend the elbows to lower slightly, then press back up using the triceps.',
          'Keep shoulders down and avoid shrugging.'
        ],
        tips: <String>[
          'Tuck the elbows to emphasize triceps and reduce shoulder strain.'
        ],
        variations: <String>['Bench dips', 'Assisted dips'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/O424Uel/41n2hHH9bNfi98YU__Triceps-Dips-Floor_Upper-Arms.png',
        met: 4.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hGioS8HumEF7",
        id: 'hammer_curl',
        name: 'Hammer Curl',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/kCGgHyMFzA.jpg",
        description:
            'Hammer curls develop the brachialis and forearm extensors while adding thickness to the upper arm. Use a neutral grip and controlled tempo.',
        bodyPart: 'ARMS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Stand tall with a neutral grip and dumbbells at your sides.',
          'Curl the weights keeping the palms facing each other throughout the movement.',
          'Lower slowly and repeat.'
        ],
        tips: <String>['Avoid swinging; keep the elbows fixed to the sides.'],
        variations: <String>['Cross-body hammer curl', 'Cable hammer curl'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/vvtrwNo/41n2hGioS8HumEF7__Cable-Hammer-Curl-(with-rope)-m_Forearms.png',
        met: 3.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hgCHNgtVLHna",
        id: 'cross_body_hammer_cur',
        name: 'Cross Body Hammer Curl',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/6vI4gkByYk.jpg",
        description:
            'Also known as diagonal hammer curl, this variation hits the brachialis and brachioradialis with a cross-body path for a slightly different stimulus.',
        bodyPart: 'ARMS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Stand and bring the dumbbell across the body toward the opposite shoulder.',
          'Keep the wrist neutral and control the descent back down.'
        ],
        tips: <String>['Perform slowly to feel the forearm engagement.'],
        variations: <String>[
          'Alternating cross-body',
          'Seated cross-body curl'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/Znk6RWF/41n2hgCHNgtVLHna__Dumbbell-Cross-Body-Hammer-Curl_Forearms.png',
        met: 3.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hGy6zE7fN6v2",
        id: 'one_arm_wrist_curl',
        name: 'One Arm Wrist Curl',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/R7X4eUdaGF.jpg",
        description:
            'One-arm wrist curls isolate the wrist flexors to build forearm strength and grip. Use a controlled tempo and full range of motion.',
        bodyPart: 'ARMS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Rest the forearm on a bench with the wrist hanging off the edge and palm up.',
          'Curl the wrist upward and then slowly lower to a full stretch.'
        ],
        tips: <String>['Slow eccentrics improve forearm hypertrophy.'],
        variations: <String>['Reverse wrist curl', 'Barbell wrist curl'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/d8HXS6b/41n2hGy6zE7fN6v2__Dumbbell-One-arm-Wrist-Curl_Forearm.png',
        met: 2.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hLA8xydD4dzE",
        id: 'triceps_press',
        name: 'Triceps Press',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/Ocsii6p15A.jpg",
        description:
            'Triceps presses target the long head and lateral head of the triceps; performed with elbows tucked, they build pressing lockout strength.',
        bodyPart: 'ARMS',
        equipment: 'BARBELL',
        instructions: <String>[
          'Lie on a bench and lower the barbell toward the forehead or slightly behind depending on variation.',
          'Extend the arms to press the weight back up, keeping the elbows steady.'
        ],
        tips: <String>[
          'Control the eccentric and avoid excessive rebound off the forehead.'
        ],
        variations: <String>['Skull crushers', 'Close-grip bench press'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/dK1H4xO/41n2hLA8xydD4dzE__Triceps-Press-(Head-Below-Bench)_Upper-Arms.png',
        met: 4.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hdHtZrMPkcqY",
        id: 'dumbbell_lying_floor_skull_crusher',
        name: 'Dumbbell Lying Floor Skull Crusher',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/LqKaE2JobC.jpg",
        description:
            'A skull crusher variant performed from the floor to limit shoulder involvement while isolating the triceps; use controlled ROM and moderate load.',
        bodyPart: 'ARMS',
        equipment: 'DUMBBELL',
        instructions: <String>[
          'Lie on the floor with dumbbells extended above the chest.',
          'Bend at the elbows to lower the weights toward the forehead, then extend back to start.'
        ],
        tips: <String>[
          'Keep the elbows stationary and focus on triceps contraction.'
        ],
        variations: <String>['Barbell skull crusher', 'Incline skull crusher'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/wRbgzmU/41n2hdHtZrMPkcqY__Dumbbell-Lying-Floor-Skullcrusher_Upper-Arms.png',
        met: 4.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hPgRbN1KtJuD",
        id: 'close-grip_push-up',
        name: 'Close-grip Push-up',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/bJE2dLg62R.jpg",
        description:
            'Close-grip push-ups shift emphasis to the triceps while still engaging the chest and shoulders. Keep the hands narrow and core braced.',
        bodyPart: 'ARMS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Assume a push-up position with hands placed narrower than shoulder width.',
          'Lower the body keeping elbows close to the ribs and press back up.'
        ],
        tips: <String>[
          'Keep the body in a straight line and avoid flaring the elbows.'
        ],
        variations: <String>[
          'Knee close-grip push-up',
          'Weighted close-grip push-up'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/nWji4PA/41n2hPgRbN1KtJuD__Close-Grip-Push-up_Upper-Arms.png',
        met: 8.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hndkoGHD1ogh",
        id: 'triceps_dip',
        name: 'Triceps Dip',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/MDpZM9TtVE.jpg",
        description:
            'Parallel-bar triceps dips are a compound pressing movement that emphasizes the triceps and lower chest depending on torso lean. Use full control on descent and ascent.',
        bodyPart: 'ARMS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Grip parallel bars and lift to the starting position with arms extended.',
          'Lower until elbows reach ~90°, then press back up to full extension.'
        ],
        tips: <String>[
          'Lean forward slightly to recruit more chest, stay upright for more triceps focus.'
        ],
        variations: <String>['Weighted dips', 'Bench dips'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/mfdrWaf/41n2hndkoGHD1ogh__Triceps-Dip_Upper-Arms.png',
        met: 6.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hUKc7JPrtJQj",
        id: 'dip_on_floor_with_chair',
        name: 'Dip on Floor with Chair',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/nuTgT7bqfw.jpg",
        description:
            'A bodyweight triceps dip using a chair for support; useful for home workouts to target triceps and shoulder stability.',
        bodyPart: 'ARMS',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Place hands on a chair behind you and extend the legs out in front.',
          'Lower the hips by bending the elbows, then press back up to starting position.'
        ],
        tips: <String>['Keep the shoulders down and avoid shrugging.'],
        variations: <String>['Bench dip', 'Assisted dip with feet elevated'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/KFWTdf7/41n2hUKc7JPrtJQj__Dip-on-Floor-with-Chair_Chest.png',
        met: 4.0,
      ),
    ],
  ),
  WorkoutCategory(
    id: 'core',
    emoji: '🧍‍♂️',
    name: 'Core / Abs Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
        remoteId: "exr_41n2hXQw5yAbbXL8",
        id: 'front_plank',
        name: 'Front Plank',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/mgFlomC4R9.jpg",
        description:
            'Front planks build isometric core strength and improve trunk stability by engaging the rectus abdominis, obliques and deep core muscles.',
        bodyPart: 'CORE',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Start in a forearm plank with elbows under shoulders and a straight line from head to heels.',
          'Brace the core and hold the position for time, avoiding hip sag or pike.'
        ],
        tips: <String>[
          'Progress by increasing hold time or adding single-leg variations.'
        ],
        variations: <String>[
          'Knee plank',
          'Side plank',
          'Plank with shoulder taps'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/SGDtnU7/41n2hXQw5yAbbXL8__Front-Plank_Waist.png',
        met: 3.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hskeb9dXgBoC",
        id: 'crunch_floor',
        name: 'Crunch Floor',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/vCL0Cgs8A4.jpg",
        description:
            'Floor crunches target the rectus abdominis with a limited range of motion, making them accessible for beginners and useful for focused abdominal work.',
        bodyPart: 'CORE',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Lie on your back with knees bent and feet flat, hands at the temples or across the chest.',
          'Curl the shoulders off the floor by contracting the abs, then lower with control.'
        ],
        tips: <String>['Avoid pulling the neck; lead with the chest.'],
        variations: <String>['Bicycle crunch', 'Weighted crunch'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/SYasbO5/41n2hskeb9dXgBoC__Crunch-Floor-m_waist.png',
        met: 3.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hvjrFJ2KjzGm",
        id: 'sit',
        name: 'Sit',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/QjeHnOqQNh.jpg",
        description:
            'Wall sits and sit variations improve isometric lower-body endurance and core bracing when performed with proper posture.',
        bodyPart: 'CORE',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Lean against a wall and slide down into a seated position with knees at ~90°, hold for time while engaging the core.'
        ],
        tips: <String>[
          'Keep weight through the heels and maintain upright posture.'
        ],
        variations: <String>['Weighted wall sit', 'Single-leg wall sit'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/dJWMhvz/41n2hvjrFJ2KjzGm__Sit-(wall)_Thighs.png',
        met: 4.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hWVVEwU54UtF",
        id: 'russian_twist',
        name: 'Russian Twist',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/Z50HKjVbLP.jpg",
        description:
            'Russian twists strengthen the obliques and rotational core muscles. Perform with controlled rotation and stable hips to avoid lower back strain.',
        bodyPart: 'CORE',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Sit with knees bent and heels on the floor, lean back slightly and rotate the torso from side to side.',
          'Keep movement driven from the core rather than the arms.'
        ],
        tips: <String>[
          'Use a med ball for added resistance once form is solid.'
        ],
        variations: <String>['Weighted Russian twist', 'Feet-elevated twist'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/yu2m14e/41n2hWVVEwU54UtF__Russian-Twist_waist.png',
        met: 4.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hMZCmZBvQApL",
        id: 'hanging_leg_straight_raise',
        name: 'Hanging Leg Straight Raise',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/RAFQMtW2iL.jpg",
        description:
            'Hanging straight-leg raises build lower abdominal strength and hip flexor control. Keep legs straight and avoid excessive swinging.',
        bodyPart: 'CORE',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Hang from a bar with an active scapular position and raise the legs straight until they reach hip level or higher.',
          'Lower slowly with control and repeat.'
        ],
        tips: <String>[
          'If straight legs are too hard, bend the knees to progress.'
        ],
        variations: <String>['Knee raises', 'Toes-to-bar'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/ze58T2O/41n2hMZCmZBvQApL__Hanging-Straight-Leg-Raise-(female)_Hips.png',
        met: 5.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hmhb4jD7H8Qk",
        id: 'assault_bike_run',
        name: 'Assault Bike Run',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/Tl37RFX06h.jpg",
        description:
            'Assault bike intervals are a high-intensity conditioning tool that also tax the core as a stabilizer during maximal efforts.',
        bodyPart: 'CORE',
        equipment: 'ASSAULT BIKE',
        instructions: <String>[
          'Perform short, intense intervals (e.g., 20s on / 40s off) focusing on maximal effort while maintaining an upright torso.'
        ],
        tips: <String>[
          'Keep the core braced during sprints to protect the lower back.'
        ],
        variations: <String>['Longer steady-state intervals', 'Tabata sprints'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/3wItidk/41n2hmhb4jD7H8Qk__Assault-Bike-Run_Cardio.png',
        met: 10.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2ha5iPFpN3hEJ",
        id: 'bridge_mountain_climber',
        name: 'Bridge - Mountain Climber',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/EsVOYBdhDN.jpg",
        description:
            'A combined bridge into mountain climber movement that challenges core stability, hip mobility and dynamic single-leg drive.',
        bodyPart: 'CORE',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Start in a bridge position, then alternate driving knees toward the chest in a controlled mountain-climber pattern while maintaining hip stability.'
        ],
        tips: <String>[
          'Control the hip movement and avoid dropping the hips during transitions.'
        ],
        variations: <String>[
          'Slow tempo bridge',
          'Alternating cross-body climbers'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/I88s2KW/41n2ha5iPFpN3hEJ__Bridge---Mountain-Climber-(Cross-Body)-(female)_Waist.png',
        met: 7.0,
      ),
    ],
  ),
  WorkoutCategory(
    id: 'cardio',
    emoji: '🏃‍♂️',
    name: 'Cardio Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
        remoteId: "exr_41n2hjkBReJMbDJk",
        id: 'running_on_treadmill',
        name: 'Running On Treadmill',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/t8EmH7ry7L.jpg",
        description:
            'Treadmill running is a primary cardio modality for improving aerobic fitness and leg endurance. Adjust speed and incline to vary intensity.',
        bodyPart: 'CARDIO',
        equipment: 'TREADMILL',
        instructions: <String>[
          'Warm up with 5–10 minutes of easy walking or jogging.',
          'Run at a steady pace or alternate intervals of higher intensity.',
          'Cool down with slow walking and stretching.'
        ],
        tips: <String>['Use incline to simulate hills and reduce impact.'],
        variations: <String>['Interval sprints', 'Incline steady-state runs'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/uS2nCGG/41n2hjkBReJMbDJk__Run-on-Treadmill-(female)_Cardio.png',
        met: 9.8,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hoyHUrhBiEWg",
        id: 'walking_on_treadmill',
        name: 'Walking On Treadmill',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/BhPdab2V0E.jpg",
        description:
            'Treadmill walking is a low-impact cardio option for general fitness and recovery days. Focus on posture and brisk cadence for best effect.',
        bodyPart: 'CARDIO',
        equipment: 'TREADMILL',
        instructions: <String>[
          'Maintain an upright posture and brisk cadence.',
          'Use incline for added intensity without increasing speed.'
        ],
        tips: <String>['Use intervals of faster walking to raise heart rate.'],
        variations: <String>['Incline walking', 'Pole-assisted walking'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/l8ApjiR/41n2hoyHUrhBiEWg__Walking-on-Treadmill_Cardio.png',
        met: 3.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hkB3FeGM3DEL",
        id: 'cycling',
        name: 'Cycling',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/Eh3snzsyct.jpg",
        description:
            'Cycling (stationary or road) improves cardiovascular fitness, leg muscular endurance and low-impact conditioning.',
        bodyPart: 'CARDIO',
        equipment: 'BICYCLE',
        instructions: <String>[
          'Set proper seat height to allow a slight knee bend at full extension.',
          'Use cadence targets and interval blocks to structure workouts.'
        ],
        tips: <String>[
          'Monitor cadence and perceived exertion to control intensity.'
        ],
        variations: <String>['Spin intervals', 'Endurance rides'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/K92XYgU/41n2hkB3FeGM3DEL__Lying-Scissor-Kick_Hips.png',
        met: 7.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hN468sP27Sac",
        id: 'jump_rope',
        name: 'Jump Rope',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/O0qDWx1dPm.jpg",
        description:
            'Jump rope is a high-intensity, low-equipment cardio exercise that also improves coordination and foot speed.',
        bodyPart: 'CARDIO',
        equipment: 'JUMP ROPE',
        instructions: <String>[
          'Use short, efficient jumps and keep wrists relaxed to rotate the rope.',
          'Start with intervals (e.g., 30s on / 30s off) to build stamina.'
        ],
        tips: <String>[
          'Land softly on the balls of your feet to reduce impact.'
        ],
        variations: <String>['Double-unders', 'Single-leg hops'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/4TlOJki/41n2hN468sP27Sac__Jump-Rope-(female)_Cardio.png',
        met: 12.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hWxnJoGwbJpa",
        id: 'superman_row_with_towel',
        name: 'Superman Row with Towel',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/ixufDWekVb.jpg",
        description:
            'A bodyweight rowing variation using a towel or strap to challenge posterior chain and core; often used for conditioning and back endurance.',
        bodyPart: 'FULL BODY',
        equipment: 'TOWEL',
        instructions: <String>[
          'Anchor the towel securely and lie prone or angle under it to perform a row motion, squeezing the shoulder blades.',
          'Control the eccentric return and maintain a neutral spine.'
        ],
        tips: <String>[
          'Adjust leverage to change difficulty and pace for conditioning.'
        ],
        variations: <String>['Inverted towel row', 'Ring row'],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/PjtZ3wH/41n2hWxnJoGwbJpa__Superman-Row-with-Towel_Back.png',
        met: 4.5,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hKiaWSZQTqgE",
        id: 'lever_stepper',
        name: 'Lever stepper',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/oA2FarJMAw.jpg",
        description:
            'Lever steppers simulate stair climbing to develop cardiovascular fitness and lower-body endurance with lower impact than running.',
        bodyPart: 'CARDIO',
        equipment: 'MACHINE',
        instructions: <String>[
          'Set resistance and step rhythmically, maintaining an upright torso.',
          'Use interval or steady-state approaches depending on goals.'
        ],
        tips: <String>[
          'Keep a steady cadence and avoid excessive forward lean.'
        ],
        variations: <String>[
          'High-resistance intervals',
          'Long steady sessions'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/BvRaui9/41n2hKiaWSZQTqgE__Lever-stepper_Cardio.png',
        met: 8.0,
      ),
      ExerciseItem(
        remoteId: "exr_41n2hmFcGGUCS289",
        id: 'walking_high_knees_lunge',
        name: 'Walking High Knees Lunge',
        imageUrl: "https://cdn.exercisedb.dev/media/w/images/ZxaRouBw7h.jpg",
        description:
            'A dynamic cardio-locomotor exercise combining walking, high-knees and lunges to elevate heart rate and challenge coordination.',
        bodyPart: 'CARDIO',
        equipment: 'BODY WEIGHT',
        instructions: <String>[
          'Perform alternating steps with exaggerated knee drive, moving forward with control.',
          'Maintain upright posture and engage the core throughout.'
        ],
        tips: <String>[
          'Use this as a high-intensity warm-up or conditioning drill.'
        ],
        variations: <String>[
          'Add hand weights',
          'Perform on a track for distance'
        ],
        gifUrl:
            'https://cdn.exercisedb.dev/w/images/Q89MA5y/41n2hmFcGGUCS289__Walking-High-Knees-Lunge_Cardio.png',
        met: 7.0,
      ),
    ],
  ),
  WorkoutCategory(
    id: 'full_body',
    emoji: '🤸‍♂️',
    name: 'Full Body Exercises',
    items: <ExerciseItem>[
      ExerciseItem(
          remoteId: "exr_41n2hqYdxG87hXz1",
          id: 'burpees',
          name: 'Burpees',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/Df8GGoa6Yl.jpg",
          description:
              'A full-body conditioning movement combining a squat, plank and jump to build strength and aerobic capacity.',
          bodyPart: 'FULL BODY',
          equipment: 'NONE',
          instructions: <String>[
            'Begin standing with feet shoulder-width apart.',
            'Drop into a squat and place hands on the floor.',
            'Kick feet back to a plank and perform a push-up if desired.',
            'Jump feet forward to the squat position and explode upward into a jump.',
          ],
          tips: <String>[
            'Keep hips low on the squat and a tight core through the plank.',
            'Land softly to reduce impact on knees.',
          ],
          variations: <String>[
            'Half burpee (no jump)',
            'Push-up burpee',
            'Dumbbell burpee'
          ],
          gifUrl:
              "https://cdn.exercisedb.dev/w/images/Nc6mGfp/41n2hqYdxG87hXz1__Burpee_Cardio.png",
          met: 10.0),
      ExerciseItem(
          remoteId: "exr_41n2hTaeNKWhMQHH",
          id: 'dumbbell_burpee',
          name: 'Dumbbell Burpee',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/Hi7uCOg9S1.jpg",
          description:
              'A burpee performed while holding dumbbells to add resistance and increase upper-body demand.',
          bodyPart: 'FULL BODY',
          equipment: 'DUMBBELLS',
          instructions: <String>[
            'Stand holding light dumbbells at your sides.',
            'Squat and place the dumbbells on the floor, stepping back into a plank.',
            'Perform a push-up if desired, step/jump feet forward, then stand and optionally press or jump.',
          ],
          tips: <String>[
            'Choose light weights to maintain safe mechanics.',
            'Keep shoulders stable while in plank.'
          ],
          variations: <String>['Single-dumbbell burpee', 'Kettlebell burpee'],
          gifUrl:
              "https://cdn.exercisedb.dev/w/images/9W5kw6w/41n2hTaeNKWhMQHH__Dumbbell-burpee_Cardio.png",
          met: 11.0),
      ExerciseItem(
          remoteId: "exr_41n2hRicz5MdZEns",
          id: 'squat_thrust',
          name: 'Squat Thrust',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/st1x4DMne6.jpg",
          description:
              'A conditioning move similar to a burpee but typically without the vertical jump — focuses on core and lower-body endurance.',
          bodyPart: 'FULL BODY',
          equipment: 'NONE',
          instructions: <String>[
            'Start standing, squat down and place hands on the floor.',
            'Jump or step feet back into plank, then immediately return feet to hands and stand.',
          ],
          tips: <String>[
            'Maintain a neutral spine during the plank phase.',
            'Use a controlled tempo for conditioning.'
          ],
          variations: <String>[
            'Step-back squat thrust',
            'Add a jump to convert to a burpee'
          ],
          gifUrl:
              "https://cdn.exercisedb.dev/w/images/fJwsZoX/41n2hRicz5MdZEns__Squat-Thrust_Waist.png",
          met: 8.0),
      ExerciseItem(
          remoteId: "exr_41n2hxxePSdr5oN1",
          id: 'thrusters',
          name: 'Thrusters',
          imageUrl: "https://cdn.exercisedb.dev/media/w/images/MpLOvIJHP1.jpg",
          description:
              'A compound front-squat into an overhead press that trains legs, core and shoulders in a single explosive movement.',
          bodyPart: 'FULL BODY',
          equipment: 'BARBELL OR DUMBBELLS',
          instructions: <String>[
            'Hold the weight at shoulder height, feet shoulder-width apart.',
            'Perform a full squat, then drive through the heels and press the weight overhead as you stand.',
          ],
          tips: <String>[
            'Use leg drive to assist the press and brace your core.',
            'Choose a manageable weight to preserve technique.'
          ],
          variations: <String>['Dumbbell thruster', 'Single-arm thruster'],
          gifUrl:
              "https://cdn.exercisedb.dev/w/images/6FHKzk5/41n2hxxePSdr5oN1__Hip-Thrusts_Hips.png",
          met: 8.5),
    ],
  ),
];
