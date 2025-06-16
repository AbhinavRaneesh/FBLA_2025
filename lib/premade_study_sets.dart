import 'package:flutter/foundation.dart';

class PremadeStudySet {
  final String name;
  final String description;
  final String subject;
  final List<Question> questions;

  PremadeStudySet({
    required this.name,
    required this.description,
    required this.subject,
    required this.questions,
  });
}

class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

class PremadeStudySetsRepository {
  static final List<PremadeStudySet> _premadeSets = [
    // AP Calculus AB
    PremadeStudySet(
      name: 'AP Calculus AB',
      description: 'Comprehensive review of AP Calculus AB concepts',
      subject: 'Math',
      questions: [
        Question(
          questionText: 'What is the derivative of f(x) = x²?',
          options: ['2x', 'x²', '2', 'x'],
          correctAnswer: '2x',
        ),
        Question(
          questionText: 'What is the integral of 2x?',
          options: ['x²', 'x² + C', '2x²', '2x² + C'],
          correctAnswer: 'x² + C',
        ),
        Question(
          questionText: 'What is the limit of sin(x)/x as x approaches 0?',
          options: ['0', '1', 'undefined', 'infinity'],
          correctAnswer: '1',
        ),
        Question(
          questionText: 'What is the chain rule formula?',
          options: [
            'f(g(x))\' = f\'(g(x))g\'(x)',
            'f(g(x))\' = f\'(x)g\'(x)',
            'f(g(x))\' = f\'(x)g(x)',
            'f(g(x))\' = f(x)g\'(x)'
          ],
          correctAnswer: 'f(g(x))\' = f\'(g(x))g\'(x)',
        ),
        Question(
          questionText: 'What is the derivative of ln(x)?',
          options: ['1/x', 'x', 'e^x', '1'],
          correctAnswer: '1/x',
        ),
      ],
    ),

    // AP Calculus BC
    PremadeStudySet(
      name: 'AP Calculus BC',
      description:
          'Advanced calculus concepts including series and polar equations',
      subject: 'Math',
      questions: [
        Question(
          questionText: 'What is the Taylor series expansion of e^x?',
          options: [
            '1 + x + x²/2! + x³/3! + ...',
            '1 - x + x²/2! - x³/3! + ...',
            'x + x²/2 + x³/3 + ...',
            '1 + x + x² + x³ + ...'
          ],
          correctAnswer: '1 + x + x²/2! + x³/3! + ...',
        ),
        Question(
          questionText: 'What is the radius of convergence for a power series?',
          options: [
            'The distance from the center to the nearest point where the series diverges',
            'The distance from the center to the farthest point where the series converges',
            'The diameter of the convergence circle',
            'The circumference of the convergence circle'
          ],
          correctAnswer:
              'The distance from the center to the nearest point where the series diverges',
        ),
        Question(
          questionText:
              'What is the formula for the arc length of a polar curve?',
          options: [
            'L = ∫√(r² + (dr/dθ)²)dθ',
            'L = ∫rdθ',
            'L = ∫√(1 + (dr/dθ)²)dθ',
            'L = ∫√(r² - (dr/dθ)²)dθ'
          ],
          correctAnswer: 'L = ∫√(r² + (dr/dθ)²)dθ',
        ),
        Question(
          questionText: 'What is the ratio test for convergence?',
          options: [
            'If lim|aₙ₊₁/aₙ| < 1, the series converges',
            'If lim|aₙ₊₁/aₙ| > 1, the series converges',
            'If lim|aₙ₊₁/aₙ| = 1, the series converges',
            'If lim|aₙ₊₁/aₙ| = 0, the series converges'
          ],
          correctAnswer: 'If lim|aₙ₊₁/aₙ| < 1, the series converges',
        ),
        Question(
          questionText: 'What is the formula for the area of a polar region?',
          options: ['A = 1/2∫r²dθ', 'A = ∫rdθ', 'A = 2∫rdθ', 'A = ∫r²dθ'],
          correctAnswer: 'A = 1/2∫r²dθ',
        ),
      ],
    ),

    // AP Statistics
    PremadeStudySet(
      name: 'AP Statistics',
      description: 'Statistical concepts and data analysis',
      subject: 'Math',
      questions: [
        Question(
          questionText:
              'What is the difference between a parameter and a statistic?',
          options: [
            'A parameter describes a population, while a statistic describes a sample',
            'A parameter describes a sample, while a statistic describes a population',
            'A parameter is always larger than a statistic',
            'A parameter is always smaller than a statistic'
          ],
          correctAnswer:
              'A parameter describes a population, while a statistic describes a sample',
        ),
        Question(
          questionText: 'What is the Central Limit Theorem?',
          options: [
            'The sampling distribution of the mean approaches a normal distribution as sample size increases',
            'The mean of a sample equals the population mean',
            'The standard deviation of a sample equals the population standard deviation',
            'The sample size must be at least 30 for any statistical test'
          ],
          correctAnswer:
              'The sampling distribution of the mean approaches a normal distribution as sample size increases',
        ),
        Question(
          questionText: 'What is a Type I error?',
          options: [
            'Rejecting a true null hypothesis',
            'Failing to reject a false null hypothesis',
            'Accepting a true alternative hypothesis',
            'Rejecting a false null hypothesis'
          ],
          correctAnswer: 'Rejecting a true null hypothesis',
        ),
        Question(
          questionText:
              'What is the formula for the standard error of the mean?',
          options: ['σ/√n', 'σ/n', '√σ/n', 'n/σ'],
          correctAnswer: 'σ/√n',
        ),
        Question(
          questionText: 'What is the purpose of a confidence interval?',
          options: [
            'To estimate a population parameter with a certain level of confidence',
            'To determine if a hypothesis test is significant',
            'To calculate the standard deviation of a sample',
            'To find the mean of a population'
          ],
          correctAnswer:
              'To estimate a population parameter with a certain level of confidence',
        ),
      ],
    ),

    // AP Physics 1
    PremadeStudySet(
      name: 'AP Physics 1',
      description: 'Algebra-based physics concepts',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is Newton\'s First Law?',
          options: [
            'An object in motion stays in motion unless acted upon by an external force',
            'Force equals mass times acceleration',
            'For every action there is an equal and opposite reaction',
            'Energy cannot be created or destroyed'
          ],
          correctAnswer:
              'An object in motion stays in motion unless acted upon by an external force',
        ),
        Question(
          questionText: 'What is the formula for kinetic energy?',
          options: ['KE = 1/2mv²', 'KE = mgh', 'KE = mv', 'KE = ma'],
          correctAnswer: 'KE = 1/2mv²',
        ),
        Question(
          questionText: 'What is the SI unit of force?',
          options: ['Newton', 'Joule', 'Watt', 'Pascal'],
          correctAnswer: 'Newton',
        ),
        Question(
          questionText: 'What is the formula for work?',
          options: ['W = Fd', 'W = ma', 'W = mv', 'W = mgh'],
          correctAnswer: 'W = Fd',
        ),
        Question(
          questionText: 'What is the principle of conservation of energy?',
          options: [
            'Energy cannot be created or destroyed, only transformed',
            'Energy can be created and destroyed',
            'Energy always increases',
            'Energy always decreases'
          ],
          correctAnswer:
              'Energy cannot be created or destroyed, only transformed',
        ),
      ],
    ),

    // AP Physics 2
    PremadeStudySet(
      name: 'AP Physics 2',
      description:
          'Advanced physics concepts including fluids, thermodynamics, and electromagnetism',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is Bernoulli\'s principle?',
          options: [
            'As the speed of a fluid increases, its pressure decreases',
            'As the speed of a fluid increases, its pressure increases',
            'As the speed of a fluid increases, its density decreases',
            'As the speed of a fluid increases, its temperature decreases'
          ],
          correctAnswer:
              'As the speed of a fluid increases, its pressure decreases',
        ),
        Question(
          questionText: 'What is the first law of thermodynamics?',
          options: [
            'The change in internal energy equals heat added minus work done',
            'Heat always flows from hot to cold',
            'Energy cannot be created or destroyed',
            'The entropy of the universe always increases'
          ],
          correctAnswer:
              'The change in internal energy equals heat added minus work done',
        ),
        Question(
          questionText: 'What is the formula for electric potential energy?',
          options: ['U = kq₁q₂/r', 'U = qV', 'U = 1/2CV²', 'U = 1/2LI²'],
          correctAnswer: 'U = kq₁q₂/r',
        ),
        Question(
          questionText: 'What is the right-hand rule used for?',
          options: [
            'Determining the direction of magnetic force on a moving charge',
            'Finding the direction of electric current',
            'Calculating the magnitude of magnetic field',
            'Determining the direction of electric field'
          ],
          correctAnswer:
              'Determining the direction of magnetic force on a moving charge',
        ),
        Question(
          questionText:
              'What is the formula for the period of a simple pendulum?',
          options: [
            'T = 2π√(L/g)',
            'T = 2π√(g/L)',
            'T = 2π√(m/k)',
            'T = 2π√(k/m)'
          ],
          correctAnswer: 'T = 2π√(L/g)',
        ),
      ],
    ),

    // AP Chemistry
    PremadeStudySet(
      name: 'AP Chemistry',
      description: 'Advanced chemistry concepts and laboratory skills',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is the ideal gas law?',
          options: ['PV = nRT', 'PV = RT', 'P = nRT/V', 'V = nRT/P'],
          correctAnswer: 'PV = nRT',
        ),
        Question(
          questionText: 'What is Le Chatelier\'s principle?',
          options: [
            'A system at equilibrium will shift to counteract any change',
            'The rate of a reaction is proportional to the concentration of reactants',
            'The entropy of the universe always increases',
            'Energy cannot be created or destroyed'
          ],
          correctAnswer:
              'A system at equilibrium will shift to counteract any change',
        ),
        Question(
          questionText: 'What is the Henderson-Hasselbalch equation?',
          options: [
            'pH = pKa + log([A⁻]/[HA])',
            'pH = -log[H⁺]',
            'pH = 14 - pOH',
            'pH = pKa - log([A⁻]/[HA])'
          ],
          correctAnswer: 'pH = pKa + log([A⁻]/[HA])',
        ),
        Question(
          questionText:
              'What is the formula for calculating the equilibrium constant?',
          options: [
            'K = [products]/[reactants]',
            'K = [reactants]/[products]',
            'K = [products] - [reactants]',
            'K = [products] + [reactants]'
          ],
          correctAnswer: 'K = [products]/[reactants]',
        ),
        Question(
          questionText:
              'What is the difference between a strong and weak acid?',
          options: [
            'Strong acids completely dissociate in water, weak acids partially dissociate',
            'Strong acids have a higher pH than weak acids',
            'Strong acids are more concentrated than weak acids',
            'Strong acids have more hydrogen atoms than weak acids'
          ],
          correctAnswer:
              'Strong acids completely dissociate in water, weak acids partially dissociate',
        ),
      ],
    ),

    // IB Mathematics HL
    PremadeStudySet(
      name: 'IB Mathematics HL',
      description: 'Advanced mathematics concepts for IB Higher Level',
      subject: 'Math',
      questions: [
        Question(
          questionText: 'What is the complex conjugate of 3 + 4i?',
          options: ['3 - 4i', '-3 + 4i', '-3 - 4i', '4 + 3i'],
          correctAnswer: '3 - 4i',
        ),
        Question(
          questionText: 'What is the modulus of a complex number?',
          options: [
            'The distance from the origin in the complex plane',
            'The angle with the positive real axis',
            'The real part of the number',
            'The imaginary part of the number'
          ],
          correctAnswer: 'The distance from the origin in the complex plane',
        ),
        Question(
          questionText: 'What is De Moivre\'s Theorem?',
          options: [
            '(cos θ + i sin θ)ⁿ = cos(nθ) + i sin(nθ)',
            '(cos θ + i sin θ)ⁿ = cos(θⁿ) + i sin(θⁿ)',
            '(cos θ + i sin θ)ⁿ = n(cos θ + i sin θ)',
            '(cos θ + i sin θ)ⁿ = cos θ + i sin θ'
          ],
          correctAnswer: '(cos θ + i sin θ)ⁿ = cos(nθ) + i sin(nθ)',
        ),
        Question(
          questionText:
              'What is the formula for the nth term of a geometric sequence?',
          options: [
            'aₙ = a₁rⁿ⁻¹',
            'aₙ = a₁ + (n-1)d',
            'aₙ = a₁ + nd',
            'aₙ = a₁rⁿ'
          ],
          correctAnswer: 'aₙ = a₁rⁿ⁻¹',
        ),
        Question(
          questionText: 'What is the sum of an infinite geometric series?',
          options: [
            'S = a₁/(1-r) where |r| < 1',
            'S = a₁/(1-r)',
            'S = a₁(1-rⁿ)/(1-r)',
            'S = a₁ + a₁r + a₁r² + ...'
          ],
          correctAnswer: 'S = a₁/(1-r) where |r| < 1',
        ),
      ],
    ),

    // IB Physics HL
    PremadeStudySet(
      name: 'IB Physics HL',
      description: 'Advanced physics concepts for IB Higher Level',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is the Heisenberg Uncertainty Principle?',
          options: [
            'It is impossible to know both position and momentum with perfect precision',
            'It is impossible to measure energy and time simultaneously',
            'It is impossible to observe quantum particles',
            'It is impossible to predict quantum behavior'
          ],
          correctAnswer:
              'It is impossible to know both position and momentum with perfect precision',
        ),
        Question(
          questionText: 'What is the formula for relativistic energy?',
          options: ['E = γmc²', 'E = mc²', 'E = 1/2mv²', 'E = hf'],
          correctAnswer: 'E = γmc²',
        ),
        Question(
          questionText: 'What is the principle of wave-particle duality?',
          options: [
            'Matter can exhibit both wave and particle properties',
            'Waves can only behave as particles',
            'Particles can only behave as waves',
            'Waves and particles are completely separate phenomena'
          ],
          correctAnswer: 'Matter can exhibit both wave and particle properties',
        ),
        Question(
          questionText: 'What is the formula for the de Broglie wavelength?',
          options: ['λ = h/p', 'λ = hf', 'λ = c/f', 'λ = v/f'],
          correctAnswer: 'λ = h/p',
        ),
        Question(
          questionText: 'What is quantum tunneling?',
          options: [
            'A particle passing through a potential barrier it classically shouldn\'t be able to',
            'A particle moving faster than light',
            'A particle changing its quantum state',
            'A particle splitting into two'
          ],
          correctAnswer:
              'A particle passing through a potential barrier it classically shouldn\'t be able to',
        ),
      ],
    ),

    // IB Chemistry HL
    PremadeStudySet(
      name: 'IB Chemistry HL',
      description: 'Advanced chemistry concepts for IB Higher Level',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is the difference between SN1 and SN2 reactions?',
          options: [
            'SN1 is unimolecular and forms a carbocation, SN2 is bimolecular and has a transition state',
            'SN1 is bimolecular and forms a carbocation, SN2 is unimolecular and has a transition state',
            'SN1 is faster than SN2',
            'SN1 only occurs with primary alcohols, SN2 with secondary'
          ],
          correctAnswer:
              'SN1 is unimolecular and forms a carbocation, SN2 is bimolecular and has a transition state',
        ),
        Question(
          questionText: 'What is the difference between E1 and E2 elimination?',
          options: [
            'E1 is unimolecular and forms a carbocation, E2 is bimolecular and has a transition state',
            'E1 is bimolecular and forms a carbocation, E2 is unimolecular and has a transition state',
            'E1 is faster than E2',
            'E1 only occurs with primary alcohols, E2 with secondary'
          ],
          correctAnswer:
              'E1 is unimolecular and forms a carbocation, E2 is bimolecular and has a transition state',
        ),
        Question(
          questionText:
              'What is the difference between a nucleophile and an electrophile?',
          options: [
            'A nucleophile donates electrons, an electrophile accepts electrons',
            'A nucleophile accepts electrons, an electrophile donates electrons',
            'A nucleophile is always negatively charged, an electrophile is always positively charged',
            'A nucleophile is always a base, an electrophile is always an acid'
          ],
          correctAnswer:
              'A nucleophile donates electrons, an electrophile accepts electrons',
        ),
        Question(
          questionText:
              'What is the difference between a primary, secondary, and tertiary alcohol?',
          options: [
            'Based on the number of carbon atoms attached to the carbon with the OH group',
            'Based on the number of hydrogen atoms attached to the carbon with the OH group',
            'Based on the number of OH groups in the molecule',
            'Based on the total number of carbon atoms in the molecule'
          ],
          correctAnswer:
              'Based on the number of carbon atoms attached to the carbon with the OH group',
        ),
        Question(
          questionText:
              'What is the difference between a reducing and oxidizing agent?',
          options: [
            'A reducing agent loses electrons, an oxidizing agent gains electrons',
            'A reducing agent gains electrons, an oxidizing agent loses electrons',
            'A reducing agent is always a metal, an oxidizing agent is always a non-metal',
            'A reducing agent is always a base, an oxidizing agent is always an acid'
          ],
          correctAnswer:
              'A reducing agent loses electrons, an oxidizing agent gains electrons',
        ),
      ],
    ),

    // AP Computer Science A
    PremadeStudySet(
      name: 'AP Computer Science A',
      description: 'Java programming and computer science concepts',
      subject: 'Computer Science',
      questions: [
        Question(
          questionText:
              'What is the difference between == and .equals() in Java?',
          options: [
            '== compares references, .equals() compares values',
            '== compares values, .equals() compares references',
            'They are exactly the same',
            '== is for primitives, .equals() is for objects'
          ],
          correctAnswer: '== compares references, .equals() compares values',
        ),
        Question(
          questionText: 'What is inheritance in Java?',
          options: [
            'A mechanism that allows a class to inherit properties and methods from another class',
            'A way to create multiple instances of a class',
            'A method to override existing functionality',
            'A technique to hide implementation details'
          ],
          correctAnswer:
              'A mechanism that allows a class to inherit properties and methods from another class',
        ),
        Question(
          questionText: 'What is polymorphism?',
          options: [
            'The ability of an object to take many forms',
            'The process of creating multiple copies of an object',
            'The technique of hiding implementation details',
            'The method of organizing code into packages'
          ],
          correctAnswer: 'The ability of an object to take many forms',
        ),
        Question(
          questionText: 'What is an interface in Java?',
          options: [
            'A contract that defines a set of methods that a class must implement',
            'A way to create multiple inheritance',
            'A method to override existing functionality',
            'A technique to hide implementation details'
          ],
          correctAnswer:
              'A contract that defines a set of methods that a class must implement',
        ),
        Question(
          questionText:
              'What is the difference between ArrayList and LinkedList?',
          options: [
            'ArrayList is faster for random access, LinkedList is faster for insertions/deletions',
            'ArrayList is faster for insertions/deletions, LinkedList is faster for random access',
            'They are exactly the same',
            'ArrayList can only store primitives, LinkedList can store objects'
          ],
          correctAnswer:
              'ArrayList is faster for random access, LinkedList is faster for insertions/deletions',
        ),
      ],
    ),

    // AP Computer Science Principles
    PremadeStudySet(
      name: 'AP Computer Science Principles',
      description: 'Computational Thinking',
      subject: 'Computer Science',
      questions: [
        Question(
          questionText: 'What is the primary purpose of an algorithm?',
          options: ['To solve problems', 'To create programs', 'To store data', 'To display graphics'],
          correctAnswer: 'To solve problems',
        ),
        Question(
          questionText: 'Which of the following is an example of abstraction?',
          options: ['Using a car without knowing how the engine works', 'Writing code', 'Debugging', 'Testing'],
          correctAnswer: 'Using a car without knowing how the engine works',
        ),
        Question(
          questionText: 'What does HTTP stand for?',
          options: ['HyperText Transfer Protocol', 'High Tech Transfer Process', 'Home Transfer Protocol', 'Hyper Transfer Process'],
          correctAnswer: 'HyperText Transfer Protocol',
        ),
        Question(
          questionText: 'Which programming paradigm focuses on objects?',
          options: ['Procedural', 'Object-Oriented', 'Functional', 'Logical'],
          correctAnswer: 'Object-Oriented',
        ),
        Question(
          questionText: 'What is the purpose of a firewall?',
          options: ['To speed up internet', 'To protect against unauthorized access', 'To store data', 'To create backups'],
          correctAnswer: 'To protect against unauthorized access',
        ),
      ],
    ),

    // AP Environmental Science
    PremadeStudySet(
      name: 'AP Environmental Science',
      description: 'Environmental Systems & Ecology',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is biodiversity?',
          options: ['Variety of life on Earth', 'Number of species', 'Genetic diversity', 'All of the above'],
          correctAnswer: 'All of the above',
        ),
        Question(
          questionText: 'What is the greenhouse effect?',
          options: ['Trapping of heat by atmospheric gases', 'Cooling of the Earth', 'Ozone depletion', 'Acid rain'],
          correctAnswer: 'Trapping of heat by atmospheric gases',
        ),
        Question(
          questionText: 'What is sustainable development?',
          options: [
            'Development that meets present needs without compromising future generations',
            'Economic growth only',
            'Environmental protection only',
            'Social equality only'
          ],
          correctAnswer: 'Development that meets present needs without compromising future generations',
        ),
        Question(
          questionText: 'What is the primary cause of climate change?',
          options: ['Human activities', 'Natural cycles', 'Solar radiation', 'Volcanic eruptions'],
          correctAnswer: 'Human activities',
        ),
        Question(
          questionText: 'What is an ecosystem?',
          options: [
            'Community of living organisms and their environment',
            'Group of animals',
            'Plant community',
            'Water system'
          ],
          correctAnswer: 'Community of living organisms and their environment',
        ),
      ],
    ),

    // IB Computer Science HL
    PremadeStudySet(
      name: 'IB Computer Science HL',
      description: 'Advanced computer science concepts for IB Higher Level',
      subject: 'Computer Science',
      questions: [
        Question(
          questionText: 'What is the time complexity of binary search?',
          options: ['O(log n)', 'O(n)', 'O(n log n)', 'O(n²)'],
          correctAnswer: 'O(log n)',
        ),
        Question(
          questionText: 'What is a binary search tree?',
          options: [
            'A tree data structure where each node has at most two children',
            'A tree where all nodes have exactly two children',
            'A tree where nodes are arranged in binary order',
            'A tree where each level is filled before moving to the next'
          ],
          correctAnswer:
              'A tree data structure where each node has at most two children',
        ),
        Question(
          questionText: 'What is the difference between TCP and UDP?',
          options: [
            'TCP is connection-oriented and reliable, UDP is connectionless and unreliable',
            'TCP is faster than UDP',
            'UDP is more secure than TCP',
            'TCP is for web traffic, UDP is for email'
          ],
          correctAnswer:
              'TCP is connection-oriented and reliable, UDP is connectionless and unreliable',
        ),
        Question(
          questionText: 'What is the purpose of a hash function?',
          options: [
            'To map data of arbitrary size to fixed-size values',
            'To encrypt data',
            'To compress data',
            'To validate data integrity'
          ],
          correctAnswer: 'To map data of arbitrary size to fixed-size values',
        ),
        Question(
          questionText: 'What is the difference between a stack and a queue?',
          options: [
            'Stack is LIFO, Queue is FIFO',
            'Stack is FIFO, Queue is LIFO',
            'Stack can only store integers, Queue can store any type',
            'Stack is faster than Queue'
          ],
          correctAnswer: 'Stack is LIFO, Queue is FIFO',
        ),
      ],
    ),

    // AP Biology
    PremadeStudySet(
      name: 'AP Biology',
      description: 'Biological Systems',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is the powerhouse of the cell?',
          options: ['Nucleus', 'Mitochondria', 'Endoplasmic reticulum', 'Golgi apparatus'],
          correctAnswer: 'Mitochondria',
        ),
        Question(
          questionText: 'What is the process by which plants make their own food?',
          options: ['Respiration', 'Photosynthesis', 'Digestion', 'Fermentation'],
          correctAnswer: 'Photosynthesis',
        ),
        Question(
          questionText: 'What are the building blocks of proteins?',
          options: ['Nucleotides', 'Amino acids', 'Fatty acids', 'Monosaccharides'],
          correctAnswer: 'Amino acids',
        ),
        Question(
          questionText: 'What is the genetic material of most organisms?',
          options: ['RNA', 'DNA', 'Protein', 'Lipid'],
          correctAnswer: 'DNA',
        ),
        Question(
          questionText: 'What is the process of cell division called?',
          options: ['Mitosis', 'Meiosis', 'Both A and B', 'Neither A nor B'],
          correctAnswer: 'Both A and B',
        ),
      ],
    ),

    // AP Physics C: Mechanics
    PremadeStudySet(
      name: 'AP Physics C: Mechanics',
      description: 'Classical Mechanics & Motion',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is the acceleration due to gravity on Earth?',
          options: ['9.8 m/s²', '9.8 m/s', '9.8 N/kg', '9.8 kg/m³'],
          correctAnswer: '9.8 m/s²',
        ),
        Question(
          questionText: 'What is the formula for kinetic energy?',
          options: ['KE = ½mv²', 'KE = mv', 'KE = mgh', 'KE = Fd'],
          correctAnswer: 'KE = ½mv²',
        ),
        Question(
          questionText: 'What is the unit of force in the SI system?',
          options: ['Newton', 'Joule', 'Watt', 'Pascal'],
          correctAnswer: 'Newton',
        ),
        Question(
          questionText: 'What is the law of conservation of momentum?',
          options: ['Total momentum remains constant', 'Momentum can be created', 'Momentum can be destroyed', 'Momentum always increases'],
          correctAnswer: 'Total momentum remains constant',
        ),
        Question(
          questionText: 'What is the formula for centripetal acceleration?',
          options: ['a = v²/r', 'a = v/r', 'a = r/v²', 'a = v/r²'],
          correctAnswer: 'a = v²/r',
        ),
      ],
    ),

    // AP English Literature
    PremadeStudySet(
      name: 'AP English Literature',
      description: 'Literary Analysis & Composition',
      subject: 'English',
      questions: [
        Question(
          questionText: 'What is a metaphor?',
          options: ['Direct comparison without like/as', 'Comparison using like/as', 'Repetition of sounds', 'Exaggeration for effect'],
          correctAnswer: 'Direct comparison without like/as',
        ),
        Question(
          questionText: 'What is dramatic irony?',
          options: ['Audience knows something characters don\'t', 'Character says opposite of what they mean', 'Unexpected outcome', 'Repetition of words'],
          correctAnswer: 'Audience knows something characters don\'t',
        ),
        Question(
          questionText: 'What is a sonnet?',
          options: ['14-line poem', '16-line poem', '12-line poem', '18-line poem'],
          correctAnswer: '14-line poem',
        ),
        Question(
          questionText: 'What is personification?',
          options: ['Giving human qualities to non-human things', 'Comparing two things', 'Repetition of consonant sounds', 'Using words that sound like what they mean'],
          correctAnswer: 'Giving human qualities to non-human things',
        ),
        Question(
          questionText: 'What is a soliloquy?',
          options: ['Character speaking alone on stage', 'Conversation between characters', 'Narrator\'s commentary', 'Stage directions'],
          correctAnswer: 'Character speaking alone on stage',
        ),
      ],
    ),

    // AP US History
    PremadeStudySet(
      name: 'AP US History',
      description: 'American History & Government',
      subject: 'History',
      questions: [
        Question(
          questionText: 'In what year did Columbus first reach the Americas?',
          options: ['1492', '1493', '1491', '1494'],
          correctAnswer: '1492',
        ),
        Question(
          questionText: 'What was the first permanent English settlement in North America?',
          options: ['Jamestown', 'Plymouth', 'Roanoke', 'St. Augustine'],
          correctAnswer: 'Jamestown',
        ),
        Question(
          questionText: 'In what year was the Declaration of Independence signed?',
          options: ['1776', '1775', '1777', '1778'],
          correctAnswer: '1776',
        ),
        Question(
          questionText: 'Who was the first President of the United States?',
          options: ['George Washington', 'John Adams', 'Thomas Jefferson', 'Benjamin Franklin'],
          correctAnswer: 'George Washington',
        ),
        Question(
          questionText: 'What was the Louisiana Purchase?',
          options: ['Land purchase from France', 'Land purchase from Spain', 'Land purchase from Mexico', 'Land purchase from Britain'],
          correctAnswer: 'Land purchase from France',
        ),
      ],
    ),

    // IB Biology HL
    PremadeStudySet(
      name: 'IB Biology HL',
      description: 'Higher Level Biology',
      subject: 'Science',
      questions: [
        Question(
          questionText: 'What is the powerhouse of the cell?',
          options: ['Mitochondria', 'Nucleus', 'Endoplasmic reticulum', 'Golgi apparatus'],
          correctAnswer: 'Mitochondria',
        ),
        Question(
          questionText: 'What is the process by which plants make their own food?',
          options: ['Photosynthesis', 'Respiration', 'Digestion', 'Fermentation'],
          correctAnswer: 'Photosynthesis',
        ),
        Question(
          questionText: 'What are the building blocks of proteins?',
          options: ['Amino acids', 'Nucleotides', 'Fatty acids', 'Monosaccharides'],
          correctAnswer: 'Amino acids',
        ),
        Question(
          questionText: 'What is the genetic material of most organisms?',
          options: ['DNA', 'RNA', 'Protein', 'Lipid'],
          correctAnswer: 'DNA',
        ),
        Question(
          questionText: 'What is the process of cell division called?',
          options: ['Mitosis', 'Meiosis', 'Both A and B', 'Neither A nor B'],
          correctAnswer: 'Both A and B',
        ),
      ],
    ),

    // AP World History
    PremadeStudySet(
      name: 'AP World History',
      description: 'Global History & Civilizations',
      subject: 'History',
      questions: [
        Question(
          questionText: 'What was the first civilization to develop writing?',
          options: ['Sumerians', 'Egyptians', 'Chinese', 'Indus Valley'],
          correctAnswer: 'Sumerians',
        ),
        Question(
          questionText: 'What was the Silk Road?',
          options: ['Trade route connecting East and West', 'Military road', 'Religious pilgrimage route', 'Migration path'],
          correctAnswer: 'Trade route connecting East and West',
        ),
        Question(
          questionText: 'What was the Renaissance?',
          options: ['Cultural rebirth in Europe', 'Religious movement', 'Political revolution', 'Economic system'],
          correctAnswer: 'Cultural rebirth in Europe',
        ),
        Question(
          questionText: 'What was the Industrial Revolution?',
          options: ['Transition to new manufacturing processes', 'Political revolution', 'Agricultural reform', 'Religious movement'],
          correctAnswer: 'Transition to new manufacturing processes',
        ),
        Question(
          questionText: 'What was the Cold War?',
          options: ['Political tension between US and USSR', 'Military conflict', 'Economic competition', 'Cultural exchange'],
          correctAnswer: 'Political tension between US and USSR',
        ),
      ],
    ),
  ];

  static List<PremadeStudySet> getPremadeSets() {
    return List<PremadeStudySet>.from(_premadeSets);
  }

  static List<PremadeStudySet> getPremadeSetsBySubject(String subject) {
    return _premadeSets.where((set) => set.subject == subject).toList();
  }

  static PremadeStudySet? getPremadeSetByName(String name) {
    try {
      return _premadeSets.firstWhere((set) => set.name == name);
    } catch (e) {
      debugPrint('Error finding premade set: $e');
      return null;
    }
  }
}