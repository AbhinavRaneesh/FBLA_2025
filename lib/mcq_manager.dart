import 'package:flutter/material.dart';
import 'frq_manager.dart' as frq;
import 'database_helper.dart';
import 'premade_study_sets.dart';
import 'main.dart' as main;
import 'package:flutter/services.dart';

class MCQManager extends StatefulWidget {
  final String username;
  final VoidCallback? onSetImported;
  final Map<String, dynamic> studySet;
  final String currentTheme;
  final String? selectedSubject;
  final int? questionCount;
  final Function(int)? onPointsUpdated;

  const MCQManager({
    super.key,
    required this.username,
    required this.studySet,
    required this.currentTheme,
    this.onSetImported,
    this.selectedSubject,
    this.questionCount,
    this.onPointsUpdated,
  });

  @override
  State<MCQManager> createState() => _MCQManagerState();
}

class _MCQManagerState extends State<MCQManager> {
  int currentQuestionIndex = 0;
  int currentScore = 0;
  int currentPoints = 0;
  bool showResults = false;
  Map<int, int> userAnswers = {};
  Map<int, int> submittedAnswers = {};
  String? selectedSubject;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool showAPCSChoice = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<Map<String, dynamic>> apClasses = [
    {
      'name': 'AP Calculus AB',
      'color': [Color(0xFF667eea), Color(0xFF764ba2)],
      'icon': Icons.functions,
      'description': 'Differential & Integral Calculus',
      'questions': [
        {
          'question': 'What is the derivative of f(x) = x³ + 2x² - 5x + 3?',
          'options': [
            '3x² + 4x - 5',
            '3x² + 4x + 5',
            '3x² - 4x - 5',
            '3x² - 4x + 5'
          ],
          'correct': 0,
          'explanation':
              'To find the derivative, apply the power rule: d/dx(x^n) = nx^(n-1). For f(x) = x³ + 2x² - 5x + 3, the derivative is 3x² + 4x - 5. The constant term 3 becomes 0 when differentiated.',
        },
        {
          'question': 'Find the integral of ∫(2x + 3)dx',
          'options': ['x² + 3x + C', 'x² + 3x', '2x² + 3x + C', 'x² + 6x + C'],
          'correct': 0,
          'explanation':
              'To integrate ∫(2x + 3)dx, use the power rule for integration: ∫x^n dx = x^(n+1)/(n+1) + C. So ∫2x dx = x² + C and ∫3 dx = 3x + C. Therefore, the answer is x² + 3x + C.',
        },
        {
          'question':
              'What is the limit of (x² - 4)/(x - 2) as x approaches 2?',
          'options': ['0', '2', '4', 'Undefined'],
          'correct': 2,
          'explanation':
              'This is an indeterminate form (0/0). Factor the numerator: (x² - 4) = (x + 2)(x - 2). Cancel (x - 2) from numerator and denominator to get (x + 2). As x approaches 2, this becomes 4.',
        },
        {
          'question': 'Find the derivative of f(x) = e^x * sin(x)',
          'options': [
            'e^x * cos(x)',
            'e^x * (sin(x) + cos(x))',
            'e^x * sin(x)',
            'e^x * (sin(x) - cos(x))'
          ],
          'correct': 1,
          'explanation':
              'Use the product rule: d/dx[u*v] = u*dv/dx + v*du/dx. Here, u = e^x and v = sin(x). So d/dx[e^x * sin(x)] = e^x * cos(x) + sin(x) * e^x = e^x * (sin(x) + cos(x)).',
        },
        {
          'question':
              'What is the area under the curve y = x² from x = 0 to x = 2?',
          'options': ['2', '4', '8/3', '16/3'],
          'correct': 2,
          'explanation':
              'The area is ∫₀² x² dx = [x³/3]₀² = (2³/3) - (0³/3) = 8/3 - 0 = 8/3.',
        },
        {
          'question': 'Find the derivative of f(x) = ln(x² + 1)',
          'options': ['2x/(x² + 1)', '1/(x² + 1)', '2x', 'x² + 1'],
          'correct': 0,
          'explanation':
              'Use the chain rule: d/dx[ln(u)] = (1/u) * du/dx. Here, u = x² + 1, so du/dx = 2x. Therefore, d/dx[ln(x² + 1)] = (1/(x² + 1)) * 2x = 2x/(x² + 1).',
        },
        {
          'question': 'What is the derivative of f(x) = cos(3x)?',
          'options': ['-3sin(3x)', '3sin(3x)', '-sin(3x)', 'sin(3x)'],
          'correct': 0,
          'explanation':
              'Use the chain rule: d/dx[cos(u)] = -sin(u) * du/dx. Here, u = 3x, so du/dx = 3. Therefore, d/dx[cos(3x)] = -sin(3x) * 3 = -3sin(3x).',
        },
        {
          'question': 'Find ∫(x² + 2x + 1)dx',
          'options': [
            'x³/3 + x² + x + C',
            'x³ + x² + x + C',
            'x³/3 + x² + C',
            'x³ + 2x² + x + C'
          ],
          'correct': 0,
          'explanation':
              'Integrate term by term: ∫x² dx = x³/3, ∫2x dx = x², ∫1 dx = x. Therefore, ∫(x² + 2x + 1)dx = x³/3 + x² + x + C.',
        },
        {
          'question': 'What is the limit of sin(x)/x as x approaches 0?',
          'options': ['0', '1', '∞', 'Undefined'],
          'correct': 1,
          'explanation':
              'This is a fundamental limit: lim(x→0) sin(x)/x = 1. This limit is often used in calculus and is the basis for the derivative of sin(x).',
        },
        {
          'question': 'Find the derivative of f(x) = √(x² + 4)',
          'options': [
            'x/√(x² + 4)',
            '2x/√(x² + 4)',
            '1/√(x² + 4)',
            'x/2√(x² + 4)'
          ],
          'correct': 0,
          'explanation':
              'Use the chain rule: d/dx[√u] = (1/(2√u)) * du/dx. Here, u = x² + 4, so du/dx = 2x. Therefore, d/dx[√(x² + 4)] = (1/(2√(x² + 4))) * 2x = x/√(x² + 4).',
        },
        {
          'question': 'What is the integral of ∫(1/x)dx?',
          'options': ['ln|x| + C', '1/x² + C', 'x + C', 'ln(x) + C'],
          'correct': 0,
          'explanation':
              'The integral of 1/x is ln|x| + C. The absolute value is important because ln(x) is only defined for x > 0, but ln|x| is defined for all x ≠ 0.',
        },
        {
          'question': 'Find the derivative of f(x) = x²e^x',
          'options': ['2xe^x + x²e^x', '2xe^x', 'x²e^x', '2x + e^x'],
          'correct': 0,
          'explanation':
              'Use the product rule: d/dx[u*v] = u*dv/dx + v*du/dx. Here, u = x² and v = e^x. So d/dx[x²e^x] = x² * e^x + e^x * 2x = 2xe^x + x²e^x.',
        },
        {
          'question':
              'What is the area between y = x² and y = x from x = 0 to x = 1?',
          'options': ['1/6', '1/3', '1/2', '1'],
          'correct': 0,
          'explanation':
              'The area is ∫₀¹ (x - x²) dx = [x²/2 - x³/3]₀¹ = (1/2 - 1/3) - (0 - 0) = 1/6.',
        },
        {
          'question': 'Find the derivative of f(x) = tan(x)',
          'options': ['sec²(x)', 'sec(x)', 'tan²(x)', '1/cos(x)'],
          'correct': 0,
          'explanation':
              'The derivative of tan(x) is sec²(x). This can be derived using the quotient rule on tan(x) = sin(x)/cos(x).',
        },
        {
          'question': 'What is the integral of ∫(e^x)dx?',
          'options': ['e^x + C', 'e^x', 'x + C', 'ln(x) + C'],
          'correct': 0,
          'explanation':
              'The integral of e^x is e^x + C. The exponential function is unique in that its derivative and integral are the same function.',
        },
        {
          'question': 'Find the limit of (1 + 1/x)^x as x approaches ∞',
          'options': ['1', 'e', '∞', '0'],
          'correct': 1,
          'explanation':
              'This is the definition of e: lim(x→∞) (1 + 1/x)^x = e ≈ 2.718. This limit is fundamental in calculus and defines the natural number e.',
        },
        {
          'question': 'What is the derivative of f(x) = arcsin(x)?',
          'options': ['1/√(1 - x²)', '1/√(1 + x²)', '1/(1 - x²)', '1/(1 + x²)'],
          'correct': 0,
          'explanation':
              'The derivative of arcsin(x) is 1/√(1 - x²). This can be derived using implicit differentiation on sin(y) = x.',
        },
        {
          'question': 'Find ∫(x³ + 3x² + 3x + 1)dx',
          'options': [
            'x⁴/4 + x³ + 3x²/2 + x + C',
            'x⁴ + x³ + 3x² + x + C',
            'x⁴/4 + x³ + x² + x + C',
            'x⁴ + 3x³ + 3x² + x + C'
          ],
          'correct': 0,
          'explanation':
              'Integrate term by term: ∫x³ dx = x⁴/4, ∫3x² dx = x³, ∫3x dx = 3x²/2, ∫1 dx = x. Therefore, the answer is x⁴/4 + x³ + 3x²/2 + x + C.',
        },
        {
          'question': 'What is the derivative of f(x) = x^x?',
          'options': ['x^x(ln(x) + 1)', 'x^x', 'x^x ln(x)', 'x^(x-1)'],
          'correct': 0,
          'explanation':
              'Use logarithmic differentiation: ln(f(x)) = x ln(x). Differentiate both sides: f\'(x)/f(x) = ln(x) + 1. Therefore, f\'(x) = x^x(ln(x) + 1).',
        },
        {
          'question':
              'Find the volume of revolution when y = x² is rotated around the x-axis from x = 0 to x = 2',
          'options': ['32π/5', '16π/5', '8π/5', '64π/5'],
          'correct': 0,
          'explanation':
              'Volume = π∫₀² (x²)² dx = π∫₀² x⁴ dx = π[x⁵/5]₀² = π(32/5 - 0) = 32π/5.',
        },
        {
          'question': 'What is the derivative of f(x) = sec(x)?',
          'options': ['sec(x)tan(x)', 'sec²(x)', 'tan(x)', 'cos(x)'],
          'correct': 0,
          'explanation':
              'The derivative of sec(x) is sec(x)tan(x). This can be derived using the quotient rule on sec(x) = 1/cos(x).',
        },
        {
          'question': 'Find the integral of ∫(sin(x)cos(x))dx',
          'options': [
            'sin²(x)/2 + C',
            'cos²(x)/2 + C',
            'sin(x)cos(x) + C',
            'sin²(x) + C'
          ],
          'correct': 0,
          'explanation':
              'Use the double angle identity: sin(2x) = 2sin(x)cos(x). So sin(x)cos(x) = sin(2x)/2. Therefore, ∫sin(x)cos(x)dx = ∫sin(2x)/2 dx = -cos(2x)/4 + C = sin²(x)/2 + C.',
        },
        {
          'question': 'What is the limit of (e^x - 1)/x as x approaches 0?',
          'options': ['0', '1', 'e', '∞'],
          'correct': 1,
          'explanation':
              'This is a fundamental limit: lim(x→0) (e^x - 1)/x = 1. This limit is often used in calculus and is the basis for the derivative of e^x.',
        },
        {
          'question': 'Find the derivative of f(x) = arctan(x)',
          'options': ['1/(1 + x²)', '1/√(1 - x²)', '1/(1 - x²)', '1/√(1 + x²)'],
          'correct': 0,
          'explanation':
              'The derivative of arctan(x) is 1/(1 + x²). This can be derived using implicit differentiation on tan(y) = x.',
        },
        {
          'question': 'What is the integral of ∫(1/√(1 - x²))dx?',
          'options': [
            'arcsin(x) + C',
            'arccos(x) + C',
            'arctan(x) + C',
            'arccot(x) + C'
          ],
          'correct': 0,
          'explanation':
              'The integral of 1/√(1 - x²) is arcsin(x) + C. This is the antiderivative of the derivative of arcsin(x).',
        },
        {
          'question': 'Find the derivative of f(x) = x^ln(x)',
          'options': [
            'x^ln(x)(ln(x) + 1)',
            'x^ln(x)ln(x)',
            'x^ln(x)',
            'ln(x)x^(ln(x)-1)'
          ],
          'correct': 0,
          'explanation':
              'Use logarithmic differentiation: ln(f(x)) = ln(x) * ln(x) = ln²(x). Differentiate both sides: f\'(x)/f(x) = 2ln(x)/x. Therefore, f\'(x) = x^ln(x) * 2ln(x)/x = x^ln(x)(ln(x) + 1).',
        },
        {
          'question':
              'What is the area between y = sin(x) and y = cos(x) from x = 0 to x = π/4?',
          'options': ['√2 - 1', '1 - √2', '√2', '1'],
          'correct': 0,
          'explanation':
              'Area = ∫₀^(π/4) (cos(x) - sin(x)) dx = [sin(x) + cos(x)]₀^(π/4) = (sin(π/4) + cos(π/4)) - (sin(0) + cos(0)) = (√2/2 + √2/2) - (0 + 1) = √2 - 1.',
        },
        {
          'question': 'Find the derivative of f(x) = ln(√x)',
          'options': ['1/(2x)', '1/x', '1/√x', '1/(2√x)'],
          'correct': 0,
          'explanation':
              'Use the chain rule: d/dx[ln(√x)] = (1/√x) * d/dx[√x] = (1/√x) * (1/(2√x)) = 1/(2x).',
        },
        {
          'question': 'What is the integral of ∫(x²e^x)dx?',
          'options': [
            'x²e^x - 2xe^x + 2e^x + C',
            'x²e^x + 2xe^x + 2e^x + C',
            'x²e^x - 2xe^x + C',
            'x²e^x + C'
          ],
          'correct': 0,
          'explanation':
              'Use integration by parts twice: ∫x²e^x dx = x²e^x - ∫2xe^x dx = x²e^x - 2(xe^x - ∫e^x dx) = x²e^x - 2xe^x + 2e^x + C.',
        },
      ],
    },
    {
      'name': 'AP Calculus BC',
      'color': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'icon': Icons.trending_up,
      'description': 'Advanced Calculus & Series',
      'questions': [
        {
          'question':
              'Find the sum of the infinite series Σ(1/2^n) from n=0 to ∞',
          'options': ['1', '2', '1/2', '∞'],
          'correct': 1,
          'explanation':
              'This is a geometric series with first term a = 1 and common ratio r = 1/2. The sum of an infinite geometric series is S = a/(1-r) = 1/(1-1/2) = 1/(1/2) = 2.',
        },
        {
          'question':
              'What is the radius of convergence for the power series Σ(x^n/n!) from n=0 to ∞?',
          'options': ['0', '1', '∞', 'e'],
          'correct': 2,
          'explanation':
              'This is the Taylor series for e^x. Using the ratio test: lim(n→∞) |a_{n+1}/a_n| = lim(n→∞) |x/(n+1)| = 0 for all x. Since the limit is 0 < 1 for all x, the radius of convergence is ∞.',
        },
        {
          'question': 'Find the parametric derivative dy/dx for x = t², y = t³',
          'options': ['3t/2', '2t/3', '3t²/2', '2t²/3'],
          'correct': 0,
          'explanation':
              'For parametric equations, dy/dx = (dy/dt)/(dx/dt). Here, dy/dt = 3t² and dx/dt = 2t. So dy/dx = 3t²/2t = 3t/2.',
        },
        {
          'question': 'What is the Taylor series for e^x centered at x = 0?',
          'options': ['Σ(x^n/n!)', 'Σ(x^n)', 'Σ(x^n/n)', 'Σ(x^n/n²)'],
          'correct': 0,
          'explanation':
              'The Taylor series for e^x centered at x = 0 is e^x = Σ(x^n/n!) from n=0 to ∞. This is because the nth derivative of e^x is e^x, and e^0 = 1.',
        },
        {
          'question': 'Find the arc length of y = x² from x = 0 to x = 1',
          'options': ['√5/2', '√5', '2√5', '√5/4'],
          'correct': 0,
          'explanation':
              'Arc length = ∫₀¹ √(1 + (dy/dx)²) dx. Here, dy/dx = 2x, so arc length = ∫₀¹ √(1 + 4x²) dx. This integral evaluates to √5/2.',
        },
        {
          'question': 'What is the sum of the series Σ(n/2^n) from n=1 to ∞?',
          'options': ['1', '2', '1/2', '4'],
          'correct': 1,
          'explanation':
              'This is a convergent series. Using the formula for Σ(nr^n) = r/(1-r)² when |r| < 1, with r = 1/2, we get (1/2)/(1-1/2)² = (1/2)/(1/4) = 2.',
        },
        {
          'question':
              'Find the interval of convergence for Σ(x^n/n) from n=1 to ∞',
          'options': ['[-1, 1)', '(-1, 1)', '[-1, 1]', '(-∞, ∞)'],
          'correct': 0,
          'explanation':
              'Using the ratio test, the series converges when |x| < 1. At x = -1, it converges (alternating series), but at x = 1, it diverges (harmonic series).',
        },
        {
          'question': 'What is the polar form of the complex number 1 + i?',
          'options': ['√2 e^(iπ/4)', '√2 e^(iπ/2)', '2 e^(iπ/4)', '√2 e^(iπ)'],
          'correct': 0,
          'explanation':
              'For 1 + i, r = √(1² + 1²) = √2 and θ = arctan(1/1) = π/4. Therefore, 1 + i = √2 e^(iπ/4) in polar form.',
        },
        {
          'question': 'Find the area enclosed by the polar curve r = 2cos(θ)',
          'options': ['π', '2π', '4π', 'π/2'],
          'correct': 0,
          'explanation':
              'Area = (1/2)∫₀^π (2cos(θ))² dθ = (1/2)∫₀^π 4cos²(θ) dθ = 2∫₀^π cos²(θ) dθ = 2(π/2) = π.',
        },
        {
          'question': 'What is the Maclaurin series for sin(x)?',
          'options': [
            'Σ((-1)^n x^(2n+1)/(2n+1)!)',
            'Σ(x^(2n+1)/(2n+1)!)',
            'Σ((-1)^n x^(2n)/(2n)!)',
            'Σ(x^(2n)/(2n)!)'
          ],
          'correct': 0,
          'explanation':
              'The Maclaurin series for sin(x) is Σ((-1)^n x^(2n+1)/(2n+1)!) from n=0 to ∞. This series has only odd powers of x with alternating signs.',
        },
        {
          'question':
              'Find the length of the curve x = t³, y = t² from t = 0 to t = 1',
          'options': [
            '(13^(3/2) - 8)/27',
            '(13^(3/2) - 1)/27',
            '(13^(3/2))/27',
            '(13^(3/2) - 1)/9'
          ],
          'correct': 0,
          'explanation':
              'Length = ∫₀¹ √((dx/dt)² + (dy/dt)²) dt = ∫₀¹ √((3t²)² + (2t)²) dt = ∫₀¹ √(9t⁴ + 4t²) dt = (13^(3/2) - 8)/27.',
        },
        {
          'question':
              'What is the radius of convergence for Σ(x^n/n²) from n=1 to ∞?',
          'options': ['0', '1', '∞', '2'],
          'correct': 1,
          'explanation':
              'Using the ratio test: lim(n→∞) |a_{n+1}/a_n| = lim(n→∞) |x * n²/(n+1)²| = |x|. The series converges when |x| < 1, so radius = 1.',
        },
        {
          'question': 'Find the area between the curves r = 2 and r = 4cos(θ)',
          'options': ['4π - 8', '8π - 16', '2π - 4', 'π - 2'],
          'correct': 0,
          'explanation':
              'Area = (1/2)∫₀^π (4cos(θ))² dθ - (1/2)∫₀^π 2² dθ = 8∫₀^π cos²(θ) dθ - 2π = 8(π/2) - 2π = 4π - 8.',
        },
        {
          'question':
              'What is the Taylor series for ln(1 + x) centered at x = 0?',
          'options': [
            'Σ((-1)^(n+1) x^n/n)',
            'Σ(x^n/n)',
            'Σ((-1)^n x^n/n)',
            'Σ(x^n/n!)'
          ],
          'correct': 0,
          'explanation':
              'The Taylor series for ln(1 + x) is Σ((-1)^(n+1) x^n/n) from n=1 to ∞. This series has alternating signs and converges for |x| < 1.',
        },
        {
          'question':
              'Find the surface area of revolution when y = x² is rotated around the x-axis from x = 0 to x = 1',
          'options': [
            'π(5√5 - 1)/6',
            'π(5√5)/6',
            'π(√5 - 1)/6',
            'π(5√5 - 1)/3'
          ],
          'correct': 0,
          'explanation':
              'Surface area = 2π∫₀¹ x²√(1 + (2x)²) dx = 2π∫₀¹ x²√(1 + 4x²) dx = π(5√5 - 1)/6.',
        },
        {
          'question': 'What is the sum of the series Σ(1/n²) from n=1 to ∞?',
          'options': ['π²/6', 'π²/4', 'π²/2', 'π²'],
          'correct': 0,
          'explanation':
              'This is the famous Basel problem. The sum Σ(1/n²) from n=1 to ∞ equals π²/6. This result was proven by Euler.',
        },
        {
          'question':
              'Find the interval of convergence for Σ(x^n/n!) from n=0 to ∞',
          'options': ['(-∞, ∞)', '[-1, 1]', '(-1, 1)', '[0, ∞)'],
          'correct': 0,
          'explanation':
              'This is the Taylor series for e^x. Using the ratio test, it converges for all real numbers x, so the interval of convergence is (-∞, ∞).',
        },
        {
          'question': 'What is the polar form of the complex number -1 + i?',
          'options': [
            '√2 e^(3iπ/4)',
            '√2 e^(iπ/4)',
            '√2 e^(iπ/2)',
            '√2 e^(iπ)'
          ],
          'correct': 0,
          'explanation':
              'For -1 + i, r = √((-1)² + 1²) = √2 and θ = arctan(1/(-1)) = 3π/4. Therefore, -1 + i = √2 e^(3iπ/4) in polar form.',
        },
        {
          'question':
              'Find the arc length of the polar curve r = 2 from θ = 0 to θ = π',
          'options': ['2π', '4π', 'π', 'π/2'],
          'correct': 0,
          'explanation':
              'For a circle r = 2, the arc length from θ = 0 to θ = π is half the circumference: (1/2)(2πr) = (1/2)(2π)(2) = 2π.',
        },
        {
          'question': 'What is the Maclaurin series for cos(x)?',
          'options': [
            'Σ((-1)^n x^(2n)/(2n)!)',
            'Σ(x^(2n)/(2n)!)',
            'Σ((-1)^n x^(2n+1)/(2n+1)!)',
            'Σ(x^(2n+1)/(2n+1)!)'
          ],
          'correct': 0,
          'explanation':
              'The Maclaurin series for cos(x) is Σ((-1)^n x^(2n)/(2n)!) from n=0 to ∞. This series has only even powers of x with alternating signs.',
        },
        {
          'question':
              'What is the radius of convergence for Σ(x^n/n³) from n=1 to ∞?',
          'options': ['0', '1', '∞', '2'],
          'correct': 1,
          'explanation':
              'Using the ratio test: lim(n→∞) |a_{n+1}/a_n| = lim(n→∞) |x * n³/(n+1)³| = |x|. The series converges when |x| < 1, so radius = 1.',
        },
        {
          'question': 'Find the area enclosed by the polar curve r = 3sin(2θ)',
          'options': ['9π/2', '9π', '18π', '3π'],
          'correct': 0,
          'explanation':
              'Area = (1/2)∫₀^(2π) (3sin(2θ))² dθ = (9/2)∫₀^(2π) sin²(2θ) dθ = (9/2)(π) = 9π/2.',
        },
        {
          'question':
              'What is the Taylor series for ln(1 + x) centered at x = 0?',
          'options': [
            'Σ((-1)^(n+1) x^n/n)',
            'Σ(x^n/n)',
            'Σ((-1)^n x^n/n)',
            'Σ(x^n/n!)'
          ],
          'correct': 0,
          'explanation':
              'The Taylor series for ln(1 + x) is Σ((-1)^(n+1) x^n/n) from n=1 to ∞. This series has alternating signs and converges for |x| < 1.',
        },
        {
          'question':
              'Find the length of the curve x = cos(t), y = sin(t) from t = 0 to t = π',
          'options': ['π', '2π', 'π/2', '4π'],
          'correct': 0,
          'explanation':
              'Length = ∫₀^π √((-sin(t))² + (cos(t))²) dt = ∫₀^π √(sin²(t) + cos²(t)) dt = ∫₀^π √1 dt = π.',
        },
        {
          'question': 'What is the sum of the series Σ(1/n³) from n=1 to ∞?',
          'options': ['ζ(3)', 'π³/6', 'π²/6', '1'],
          'correct': 0,
          'explanation':
              'This is the Riemann zeta function ζ(3), also known as Apéry\'s constant. It is approximately 1.2020569.',
        },
        {
          'question':
              'Find the interval of convergence for Σ(x^n/n²) from n=1 to ∞',
          'options': ['[-1, 1]', '(-1, 1)', '[-1, 1)', '(-∞, ∞)'],
          'correct': 0,
          'explanation':
              'Using the ratio test, the series converges when |x| ≤ 1. At both x = -1 and x = 1, the series converges (p-series with p = 2).',
        },
        {
          'question': 'What is the polar form of the complex number -1 - i?',
          'options': [
            '√2 e^(5iπ/4)',
            '√2 e^(3iπ/4)',
            '√2 e^(7iπ/4)',
            '√2 e^(iπ)'
          ],
          'correct': 0,
          'explanation':
              'For -1 - i, r = √((-1)² + (-1)²) = √2 and θ = arctan((-1)/(-1)) = 5π/4. Therefore, -1 - i = √2 e^(5iπ/4) in polar form.',
        },
        {
          'question':
              'Find the surface area of revolution when y = x³ is rotated around the x-axis from x = 0 to x = 1',
          'options': [
            'π(9√10 - 1)/27',
            'π(9√10)/27',
            'π(√10 - 1)/27',
            'π(9√10 - 1)/9'
          ],
          'correct': 0,
          'explanation':
              'Surface area = 2π∫₀¹ x³√(1 + (3x²)²) dx = 2π∫₀¹ x³√(1 + 9x⁴) dx = π(9√10 - 1)/27.',
        },
        {
          'question': 'What is the Maclaurin series for e^(-x)?',
          'options': [
            'Σ((-1)^n x^n/n!)',
            'Σ(x^n/n!)',
            'Σ((-1)^n x^n)',
            'Σ(x^n)'
          ],
          'correct': 0,
          'explanation':
              'The Maclaurin series for e^(-x) is Σ((-1)^n x^n/n!) from n=0 to ∞. This is obtained by substituting -x for x in the series for e^x.',
        },
      ],
    },
    {
      'name': 'AP Computer Science A',
      'color': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      'icon': Icons.code,
      'description': 'Java Programming',
      'questions': [
        {
          'question': 'What is the output of: System.out.println(5 / 2);',
          'options': ['2.5', '2', '2.0', 'Error'],
          'correct': 1,
          'explanation':
              'In Java, when dividing two integers (5 and 2), the result is also an integer. Integer division truncates the decimal part, so 5/2 = 2, not 2.5.',
        },
        {
          'question': 'Which data structure uses LIFO (Last In, First Out)?',
          'options': ['Queue', 'Stack', 'Array', 'LinkedList'],
          'correct': 1,
          'explanation':
              'A Stack uses LIFO (Last In, First Out) principle. The last element pushed onto the stack is the first one to be popped off. Think of it like a stack of plates.',
        },
        {
          'question': 'What is the time complexity of binary search?',
          'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
          'correct': 1,
          'explanation':
              'Binary search has O(log n) time complexity because it divides the search space in half with each iteration. This makes it very efficient for large datasets.',
        },
        {
          'question': 'Which keyword is used to inherit from a class?',
          'options': ['implements', 'extends', 'inherits', 'super'],
          'correct': 1,
          'explanation':
              'The "extends" keyword is used for class inheritance in Java. It allows a subclass to inherit all non-private members from its parent class.',
        },
        {
          'question':
              'What is the output of: String s = "Hello"; System.out.println(s.length());',
          'options': ['4', '5', '6', 'Error'],
          'correct': 1,
          'explanation':
              'The length() method returns the number of characters in a String. "Hello" has 5 characters (H, e, l, l, o), so s.length() returns 5.',
        },
        {
          'question':
              'What is the output of: int[] arr = {1, 2, 3}; System.out.println(arr[3]);',
          'options': ['3', '0', 'ArrayIndexOutOfBoundsException', 'null'],
          'correct': 2,
          'explanation':
              'This will throw an ArrayIndexOutOfBoundsException because array indices start at 0, so valid indices are 0, 1, and 2. Index 3 is out of bounds.',
        },
        {
          'question':
              'Which sorting algorithm has the best average-case time complexity?',
          'options': [
            'Bubble Sort',
            'Quick Sort',
            'Selection Sort',
            'Insertion Sort'
          ],
          'correct': 1,
          'explanation':
              'Quick Sort has the best average-case time complexity of O(n log n). While other algorithms like Merge Sort also have O(n log n), Quick Sort is often faster in practice.',
        },
        {
          'question': 'What is the output of: System.out.println("Hello" + 5);',
          'options': ['Hello5', 'Hello 5', 'Error', 'Hello + 5'],
          'correct': 0,
          'explanation':
              'In Java, when you concatenate a String with any other data type, the other type is automatically converted to a String. So "Hello" + 5 becomes "Hello5".',
        },
        {
          'question': 'Which method is called when an object is created?',
          'options': ['Constructor', 'Destructor', 'Initializer', 'Setup'],
          'correct': 0,
          'explanation':
              'A constructor is a special method that is automatically called when an object is created. It has the same name as the class and is used to initialize the object.',
        },
        {
          'question':
              'What is the output of: boolean x = true; boolean y = false; System.out.println(x && y);',
          'options': ['true', 'false', 'Error', '1'],
          'correct': 1,
          'explanation':
              'The && operator is the logical AND operator. It returns true only if both operands are true. Since y is false, the result is false.',
        },
        {
          'question': 'Which data structure uses FIFO (First In, First Out)?',
          'options': ['Stack', 'Queue', 'Tree', 'Graph'],
          'correct': 1,
          'explanation':
              'A Queue uses FIFO (First In, First Out) principle. The first element added to the queue is the first one to be removed, like people waiting in line.',
        },
        {
          'question': 'What is the time complexity of linear search?',
          'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
          'correct': 2,
          'explanation':
              'Linear search has O(n) time complexity because it may need to check every element in the worst case. It sequentially checks each element until it finds the target.',
        },
        {
          'question':
              'What is the output of: int x = 10; System.out.println(x++);',
          'options': ['10', '11', 'Error', '9'],
          'correct': 0,
          'explanation':
              'The post-increment operator (x++) returns the current value of x (10) and then increments it. So it prints 10, but x becomes 11 after the statement.',
        },
        {
          'question': 'Which keyword is used to create a constant in Java?',
          'options': ['const', 'final', 'static', 'constant'],
          'correct': 1,
          'explanation':
              'The "final" keyword is used to create constants in Java. Once a final variable is assigned a value, it cannot be changed.',
        },
        {
          'question':
              'What is the output of: String s1 = "Hello"; String s2 = "Hello"; System.out.println(s1 == s2);',
          'options': ['true', 'false', 'Error', 'null'],
          'correct': 0,
          'explanation':
              'This returns true because both strings are string literals and Java uses string pooling. Both s1 and s2 reference the same string object in the string pool.',
        },
        {
          'question': 'Which method is used to compare two strings in Java?',
          'options': ['compare()', 'equals()', 'compareTo()', 'Both B and C'],
          'correct': 3,
          'explanation':
              'Both equals() and compareTo() are used to compare strings. equals() returns a boolean, while compareTo() returns an integer indicating the lexicographic order.',
        },
        {
          'question':
              'What is the output of: int[] arr = new int[5]; System.out.println(arr[0]);',
          'options': ['0', 'null', 'Error', 'undefined'],
          'correct': 0,
          'explanation':
              'When an array of primitives is created, all elements are automatically initialized to their default values. For int, the default value is 0.',
        },
        {
          'question': 'Which access modifier allows access from any class?',
          'options': ['private', 'protected', 'public', 'default'],
          'correct': 2,
          'explanation':
              'The "public" access modifier allows access from any class, regardless of package. It provides the most permissive level of access.',
        },
        {
          'question':
              'What is the output of: System.out.println(Math.sqrt(16));',
          'options': ['4.0', '4', '16', 'Error'],
          'correct': 0,
          'explanation':
              'Math.sqrt() returns a double value. The square root of 16 is 4, but it\'s returned as 4.0 (a double) rather than 4 (an int).',
        },
        {
          'question': 'Which exception is thrown when dividing by zero?',
          'options': [
            'ArithmeticException',
            'DivideByZeroException',
            'NumberFormatException',
            'RuntimeException'
          ],
          'correct': 0,
          'explanation':
              'ArithmeticException is thrown when an arithmetic operation fails, such as dividing by zero. It\'s a runtime exception that extends RuntimeException.',
        },
        {
          'question':
              'What is the output of: System.out.println("Hello".substring(1, 4));',
          'options': ['ell', 'Hel', 'ello', 'Error'],
          'correct': 0,
          'explanation':
              'The substring method extracts characters from index 1 (inclusive) to index 4 (exclusive). So "Hello".substring(1, 4) returns "ell".',
        },
        {
          'question':
              'Which data structure is best for implementing a priority queue?',
          'options': ['Array', 'Linked List', 'Heap', 'Stack'],
          'correct': 2,
          'explanation':
              'A heap is the best data structure for implementing a priority queue because it provides O(log n) time complexity for both insertion and removal of the highest priority element.',
        },
        {
          'question':
              'What is the output of: int x = 5; System.out.println(x > 3 && x < 10);',
          'options': ['true', 'false', 'Error', '5'],
          'correct': 0,
          'explanation':
              'The expression x > 3 && x < 10 evaluates to true because 5 is greater than 3 AND less than 10. Both conditions are true, so the result is true.',
        },
        {
          'question': 'Which method is used to convert a String to an integer?',
          'options': ['parseInt()', 'toString()', 'valueOf()', 'convert()'],
          'correct': 0,
          'explanation':
              'Integer.parseInt() is used to convert a String to an integer. It throws NumberFormatException if the string cannot be converted to a valid integer.',
        },
        {
          'question':
              'What is the time complexity of binary search tree insertion?',
          'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
          'correct': 1,
          'explanation':
              'Binary search tree insertion has O(log n) time complexity in the average case. However, in the worst case (when the tree becomes linear), it can be O(n).',
        },
        {
          'question':
              'What is the output of: String s = "Java"; System.out.println(s.charAt(2));',
          'options': ['J', 'a', 'v', 'Error'],
          'correct': 2,
          'explanation':
              'The charAt(2) method returns the character at index 2. In "Java", the character at index 2 is "v" (indices are 0-based).',
        },
        {
          'question': 'Which keyword is used to prevent method overriding?',
          'options': ['final', 'static', 'private', 'protected'],
          'correct': 0,
          'explanation':
              'The "final" keyword can be used to prevent method overriding. A final method cannot be overridden by subclasses.',
        },
        {
          'question':
              'What is the output of: int[] arr = {1, 2, 3, 4, 5}; System.out.println(arr.length);',
          'options': ['4', '5', '6', 'Error'],
          'correct': 1,
          'explanation':
              'The length property returns the number of elements in the array. The array has 5 elements, so arr.length returns 5.',
        },
        {
          'question': 'Which sorting algorithm has the worst time complexity?',
          'options': ['Bubble Sort', 'Quick Sort', 'Merge Sort', 'Heap Sort'],
          'correct': 0,
          'explanation':
              'Bubble Sort has the worst time complexity of O(n²) among the given options. Quick Sort, Merge Sort, and Heap Sort all have O(n log n) average time complexity.',
        },
      ],
    },
    {
      'name': 'AP Computer Science Principles',
      'color': [Color(0xFF43e97b), Color(0xFF38f9d7)],
      'icon': Icons.computer,
      'description': 'Computational Thinking',
      'questions': [
        {
          'question': 'What is the primary purpose of an algorithm?',
          'options': [
            'To solve problems',
            'To create programs',
            'To store data',
            'To display graphics'
          ],
          'correct': 0,
          'explanation':
              'An algorithm is a step-by-step procedure designed to solve a specific problem. It provides a clear, unambiguous sequence of instructions to accomplish a task.',
        },
        {
          'question': 'Which of the following is an example of abstraction?',
          'options': [
            'Using a car without knowing how the engine works',
            'Writing code',
            'Debugging',
            'Testing'
          ],
          'correct': 0,
          'explanation':
              'Abstraction is the process of hiding complex implementation details and showing only the necessary features. Using a car without understanding its internal mechanics is a perfect example.',
        },
        {
          'question': 'What does HTTP stand for?',
          'options': [
            'HyperText Transfer Protocol',
            'High Tech Transfer Process',
            'Home Transfer Protocol',
            'Hyper Transfer Process'
          ],
          'correct': 0,
          'explanation':
              'HTTP (HyperText Transfer Protocol) is the protocol used for transmitting web pages and other data over the internet. It defines how messages are formatted and transmitted.',
        },
        {
          'question': 'Which programming paradigm focuses on objects?',
          'options': ['Procedural', 'Object-Oriented', 'Functional', 'Logical'],
          'correct': 1,
          'explanation':
              'Object-Oriented Programming (OOP) focuses on objects that contain both data and code. Objects are instances of classes and can interact with each other.',
        },
        {
          'question': 'What is the purpose of a firewall?',
          'options': [
            'To speed up internet',
            'To protect against unauthorized access',
            'To store data',
            'To create backups'
          ],
          'correct': 1,
          'explanation':
              'A firewall is a network security device that monitors and controls incoming and outgoing network traffic based on predetermined security rules, protecting against unauthorized access.',
        },
        {
          'question':
              'What is the binary representation of the decimal number 13?',
          'options': ['1101', '1011', '1110', '1001'],
          'correct': 0,
          'explanation':
              'To convert 13 to binary: 13 ÷ 2 = 6 remainder 1, 6 ÷ 2 = 3 remainder 0, 3 ÷ 2 = 1 remainder 1, 1 ÷ 2 = 0 remainder 1. Reading backwards: 1101.',
        },
        {
          'question':
              'Which of the following is NOT a type of computer network?',
          'options': ['LAN', 'WAN', 'MAN', 'CAN'],
          'correct': 3,
          'explanation':
              'LAN (Local Area Network), WAN (Wide Area Network), and MAN (Metropolitan Area Network) are all types of computer networks. CAN is not a standard network type.',
        },
        {
          'question': 'What is the purpose of an IP address?',
          'options': [
            'To identify devices on a network',
            'To encrypt data',
            'To compress files',
            'To create backups'
          ],
          'correct': 0,
          'explanation':
              'An IP address is a unique numerical label assigned to each device connected to a computer network. It serves as an identifier for devices to communicate with each other.',
        },
        {
          'question':
              'Which data structure is best for implementing a dictionary?',
          'options': ['Array', 'Linked List', 'Hash Table', 'Stack'],
          'correct': 2,
          'explanation':
              'A hash table is ideal for implementing a dictionary because it provides O(1) average time complexity for insertions, deletions, and lookups using key-value pairs.',
        },
        {
          'question': 'What is the purpose of encryption?',
          'options': [
            'To make data unreadable to unauthorized users',
            'To compress data',
            'To speed up processing',
            'To organize data'
          ],
          'correct': 0,
          'explanation':
              'Encryption is the process of converting information into a code to prevent unauthorized access. It makes data unreadable to anyone who doesn\'t have the decryption key.',
        },
        {
          'question':
              'Which programming construct is used for decision making?',
          'options': ['Loop', 'Variable', 'Conditional statement', 'Function'],
          'correct': 2,
          'explanation':
              'Conditional statements (if/else, switch) are used for decision making in programming. They allow the program to execute different code based on whether conditions are true or false.',
        },
        {
          'question': 'What is the purpose of a database?',
          'options': [
            'To store and organize data',
            'To create graphics',
            'To send emails',
            'To play games'
          ],
          'correct': 0,
          'explanation':
              'A database is an organized collection of structured information or data, typically stored electronically in a computer system. It allows for efficient storage, retrieval, and management of data.',
        },
        {
          'question': 'Which protocol is used for secure web browsing?',
          'options': ['HTTP', 'HTTPS', 'FTP', 'SMTP'],
          'correct': 1,
          'explanation':
              'HTTPS (HyperText Transfer Protocol Secure) is the secure version of HTTP. It uses encryption to protect data transmitted between a web browser and a website.',
        },
        {
          'question': 'What is the purpose of a compiler?',
          'options': [
            'To translate high-level code to machine code',
            'To debug programs',
            'To create user interfaces',
            'To manage memory'
          ],
          'correct': 0,
          'explanation':
              'A compiler translates high-level programming language code into machine code that can be executed directly by a computer\'s processor.',
        },
        {
          'question':
              'Which of the following is an example of a search algorithm?',
          'options': [
            'Bubble Sort',
            'Binary Search',
            'Quick Sort',
            'Merge Sort'
          ],
          'correct': 1,
          'explanation':
              'Binary Search is a search algorithm that finds the position of a target value within a sorted array. It works by repeatedly dividing the search interval in half.',
        },
        {
          'question': 'What is the purpose of a variable in programming?',
          'options': [
            'To store data',
            'To create loops',
            'To define functions',
            'To handle errors'
          ],
          'correct': 0,
          'explanation':
              'A variable is a named storage location in computer memory that can hold data. It allows programs to store and manipulate information during execution.',
        },
        {
          'question': 'Which of the following is NOT a programming language?',
          'options': ['Python', 'Java', 'HTML', 'C++'],
          'correct': 2,
          'explanation':
              'HTML (HyperText Markup Language) is a markup language used to create web pages, not a programming language. Python, Java, and C++ are programming languages.',
        },
        {
          'question': 'What is the purpose of an operating system?',
          'options': [
            'To manage computer hardware and software',
            'To create documents',
            'To browse the internet',
            'To play music'
          ],
          'correct': 0,
          'explanation':
              'An operating system manages computer hardware and software resources and provides common services for computer programs. It acts as an intermediary between users and computer hardware.',
        },
        {
          'question': 'Which data type is used to store whole numbers?',
          'options': ['String', 'Float', 'Integer', 'Boolean'],
          'correct': 2,
          'explanation':
              'An integer data type is used to store whole numbers (positive, negative, or zero) without decimal points. Examples include 1, -5, 0, 100, etc.',
        },
        {
          'question': 'What is the purpose of a loop in programming?',
          'options': [
            'To repeat code multiple times',
            'To store data',
            'To make decisions',
            'To create functions'
          ],
          'correct': 0,
          'explanation':
              'A loop is a programming construct that repeats a block of code multiple times until a specified condition is met. It helps avoid code repetition and makes programs more efficient.',
        },
        {
          'question': 'What is the purpose of a cache in computing?',
          'options': [
            'To store frequently accessed data',
            'To increase storage capacity',
            'To connect to the internet',
            'To display graphics'
          ],
          'correct': 0,
          'explanation':
              'A cache stores frequently accessed data to improve performance by reducing the time needed to access that data. It acts as a temporary storage area between the CPU and main memory.',
        },
        {
          'question':
              'What is the binary representation of the decimal number 25?',
          'options': ['11001', '10101', '11100', '10011'],
          'correct': 0,
          'explanation':
              'To convert 25 to binary: 25 ÷ 2 = 12 remainder 1, 12 ÷ 2 = 6 remainder 0, 6 ÷ 2 = 3 remainder 0, 3 ÷ 2 = 1 remainder 1, 1 ÷ 2 = 0 remainder 1. Reading backwards: 11001.',
        },
        {
          'question': 'What is the purpose of an algorithm?',
          'options': [
            'To solve problems step by step',
            'To create hardware',
            'To connect networks',
            'To display images'
          ],
          'correct': 0,
          'explanation':
              'An algorithm is a step-by-step procedure designed to solve a specific problem. It provides a clear, unambiguous sequence of instructions to accomplish a task.',
        },
        {
          'question': 'What is the difference between hardware and software?',
          'options': [
            'Hardware is physical, software is programs',
            'Hardware is programs, software is physical',
            'Both are physical',
            'Both are programs'
          ],
          'correct': 0,
          'explanation':
              'Hardware refers to the physical components of a computer system (CPU, memory, etc.), while software refers to the programs and instructions that tell the hardware what to do.',
        },
        {
          'question': 'What is the purpose of a router in a network?',
          'options': [
            'To direct data packets',
            'To store files',
            'To process data',
            'To display web pages'
          ],
          'correct': 0,
          'explanation':
              'A router directs data packets between different networks. It determines the best path for data to travel from source to destination across the internet.',
        },
        {
          'question':
              'What is the hexadecimal representation of the decimal number 255?',
          'options': ['FF', 'FE', 'F0', '100'],
          'correct': 0,
          'explanation':
              'To convert 255 to hexadecimal: 255 ÷ 16 = 15 remainder 15. In hexadecimal, 15 is represented as F. So 255 in decimal is FF in hexadecimal.',
        },
        {
          'question': 'What is the purpose of a firewall?',
          'options': [
            'To protect against unauthorized access',
            'To speed up internet',
            'To store data',
            'To create backups'
          ],
          'correct': 0,
          'explanation':
              'A firewall is a network security device that monitors and controls incoming and outgoing network traffic based on predetermined security rules, protecting against unauthorized access.',
        },
        {
          'question':
              'What is the difference between analog and digital signals?',
          'options': [
            'Analog is continuous, digital is discrete',
            'Analog is discrete, digital is continuous',
            'Both are continuous',
            'Both are discrete'
          ],
          'correct': 0,
          'explanation':
              'Analog signals are continuous and can take any value within a range, while digital signals are discrete and can only take specific values (typically 0 and 1).',
        },
      ],
    },
    {
      'name': 'AP Physics 1',
      'color': [Color(0xFFfa709a), Color(0xFFfee140)],
      'icon': Icons.science,
      'description': 'Algebra-Based Physics',
      'questions': [
        {
          'question': 'What is the SI unit for force?',
          'options': ['Joule', 'Newton', 'Watt', 'Pascal'],
          'correct': 1,
          'explanation':
              'The Newton (N) is the SI unit for force. One Newton is defined as the force required to accelerate a mass of 1 kilogram at 1 meter per second squared.',
        },
        {
          'question':
              'A car accelerates from 0 to 60 m/s in 10 seconds. What is its acceleration?',
          'options': ['6 m/s²', '60 m/s²', '600 m/s²', '0.6 m/s²'],
          'correct': 0,
          'explanation':
              'Acceleration = change in velocity / time = (60 m/s - 0 m/s) / 10 s = 60 m/s / 10 s = 6 m/s².',
        },
        {
          'question': 'What is the formula for kinetic energy?',
          'options': ['KE = mgh', 'KE = ½mv²', 'KE = mv', 'KE = ma'],
          'correct': 1,
          'explanation':
              'Kinetic energy is the energy of motion. The formula is KE = ½mv², where m is mass and v is velocity. This shows that kinetic energy depends on both mass and the square of velocity.',
        },
        {
          'question':
              'Which law states that for every action there is an equal and opposite reaction?',
          'options': [
            'Newton\'s First Law',
            'Newton\'s Second Law',
            'Newton\'s Third Law',
            'Law of Gravity'
          ],
          'correct': 2,
          'explanation':
              'Newton\'s Third Law states that for every action, there is an equal and opposite reaction. This means that when one object exerts a force on another, the second object exerts an equal force in the opposite direction.',
        },
        {
          'question': 'What is the unit for power?',
          'options': ['Joule', 'Newton', 'Watt', 'Meter'],
          'correct': 2,
          'explanation':
              'The Watt (W) is the SI unit for power. Power is the rate at which work is done or energy is transferred. One Watt equals one Joule per second.',
        },
        {
          'question': 'What is the formula for gravitational potential energy?',
          'options': ['PE = mgh', 'PE = ½mv²', 'PE = Fd', 'PE = ma'],
          'correct': 0,
          'explanation':
              'Gravitational potential energy is PE = mgh, where m is mass, g is gravitational acceleration (9.8 m/s²), and h is height above a reference point.',
        },
        {
          'question': 'What is the SI unit for work?',
          'options': ['Newton', 'Watt', 'Joule', 'Pascal'],
          'correct': 2,
          'explanation':
              'The Joule (J) is the SI unit for work and energy. One Joule is defined as the work done when a force of one Newton moves an object one meter in the direction of the force.',
        },
        {
          'question': 'What is the formula for momentum?',
          'options': ['p = mv', 'p = ma', 'p = Fd', 'p = ½mv²'],
          'correct': 0,
          'explanation':
              'Momentum is the product of mass and velocity: p = mv. Momentum is a vector quantity, meaning it has both magnitude and direction.',
        },
        {
          'question': 'What is the law of conservation of momentum?',
          'options': [
            'Momentum can be created',
            'Momentum can be destroyed',
            'Total momentum remains constant in a closed system',
            'Momentum always increases'
          ],
          'correct': 2,
          'explanation':
              'The law of conservation of momentum states that the total momentum of a closed system remains constant if no external forces act on it. This is a fundamental principle in physics.',
        },
        {
          'question': 'What is the formula for centripetal acceleration?',
          'options': ['a = v²/r', 'a = v/r', 'a = r/v²', 'a = v/r²'],
          'correct': 0,
          'explanation':
              'Centripetal acceleration is a = v²/r, where v is the velocity and r is the radius of the circular path. This acceleration always points toward the center of the circle.',
        },
        {
          'question': 'What is the SI unit for frequency?',
          'options': ['Meter', 'Second', 'Hertz', 'Watt'],
          'correct': 2,
          'explanation':
              'The Hertz (Hz) is the SI unit for frequency. One Hertz equals one cycle per second. Frequency measures how often something happens in a given time period.',
        },
        {
          'question': 'What is the formula for density?',
          'options': ['ρ = m/v', 'ρ = v/m', 'ρ = m×v', 'ρ = m+v'],
          'correct': 0,
          'explanation':
              'Density is mass per unit volume: ρ = m/v. It is a measure of how much mass is contained in a given volume of a substance.',
        },
        {
          'question': 'What is the principle of conservation of energy?',
          'options': [
            'Energy can be created',
            'Energy can be destroyed',
            'Energy cannot be created or destroyed',
            'Energy always increases'
          ],
          'correct': 2,
          'explanation':
              'The principle of conservation of energy states that energy cannot be created or destroyed, only transformed from one form to another. The total energy in a closed system remains constant.',
        },
        {
          'question': 'What is the formula for average velocity?',
          'options': ['v = d/t', 'v = a×t', 'v = ½at²', 'v = at'],
          'correct': 0,
          'explanation':
              'Average velocity is displacement divided by time: v = d/t. It is a vector quantity that describes both the speed and direction of motion.',
        },
        {
          'question': 'What is the SI unit for pressure?',
          'options': ['Newton', 'Pascal', 'Joule', 'Watt'],
          'correct': 1,
          'explanation':
              'The Pascal (Pa) is the SI unit for pressure. One Pascal equals one Newton per square meter. Pressure is force per unit area.',
        },
        {
          'question': 'What is the formula for mechanical advantage?',
          'options': [
            'MA = F_out/F_in',
            'MA = F_in/F_out',
            'MA = d_in/d_out',
            'MA = d_out/d_in'
          ],
          'correct': 0,
          'explanation':
              'Mechanical advantage is the ratio of output force to input force: MA = F_out/F_in. It measures how much a machine multiplies the input force.',
        },
        {
          'question': 'What is the law of inertia?',
          'options': [
            'Newton\'s First Law',
            'Newton\'s Second Law',
            'Newton\'s Third Law',
            'Law of Gravity'
          ],
          'correct': 0,
          'explanation':
              'Newton\'s First Law (Law of Inertia) states that an object at rest stays at rest and an object in motion stays in motion unless acted upon by an external force.',
        },
        {
          'question': 'What is the formula for weight?',
          'options': ['W = mg', 'W = ma', 'W = mv', 'W = Fd'],
          'correct': 0,
          'explanation':
              'Weight is the force of gravity on an object: W = mg, where m is mass and g is gravitational acceleration (9.8 m/s² on Earth).',
        },
        {
          'question': 'What is the SI unit for electric current?',
          'options': ['Volt', 'Ampere', 'Ohm', 'Watt'],
          'correct': 1,
          'explanation':
              'The Ampere (A) is the SI unit for electric current. It measures the rate of flow of electric charge through a conductor.',
        },
        {
          'question': 'What is the formula for efficiency?',
          'options': [
            'η = (W_out/W_in) × 100%',
            'η = (W_in/W_out) × 100%',
            'η = W_out + W_in',
            'η = W_out - W_in'
          ],
          'correct': 0,
          'explanation':
              'Efficiency is the ratio of useful work output to total work input, expressed as a percentage: η = (W_out/W_in) × 100%.',
        },
        {
          'question': 'What is the formula for centripetal force?',
          'options': ['F = mv²/r', 'F = ma', 'F = mg', 'F = kx'],
          'correct': 0,
          'explanation':
              'Centripetal force is F = mv²/r, where m is mass, v is velocity, and r is the radius of the circular path. This force is always directed toward the center of the circle.',
        },
        {
          'question': 'What is the SI unit for frequency?',
          'options': ['Meter', 'Second', 'Hertz', 'Watt'],
          'correct': 2,
          'explanation':
              'The Hertz (Hz) is the SI unit for frequency. One Hertz equals one cycle per second. Frequency measures how often something happens in a given time period.',
        },
        {
          'question': 'What is the formula for density?',
          'options': ['ρ = m/v', 'ρ = v/m', 'ρ = m×v', 'ρ = m+v'],
          'correct': 0,
          'explanation':
              'Density is mass per unit volume: ρ = m/v. It is a measure of how much mass is contained in a given volume of a substance.',
        },
        {
          'question': 'What is the principle of conservation of energy?',
          'options': [
            'Energy cannot be created or destroyed',
            'Energy can be created',
            'Energy can be destroyed',
            'Energy always increases'
          ],
          'correct': 0,
          'explanation':
              'The principle of conservation of energy states that energy cannot be created or destroyed, only transformed from one form to another. The total energy in a closed system remains constant.',
        },
        {
          'question': 'What is the formula for average velocity?',
          'options': ['v = d/t', 'v = a×t', 'v = ½at²', 'v = at'],
          'correct': 0,
          'explanation':
              'Average velocity is displacement divided by time: v = d/t. It is a vector quantity that describes both the speed and direction of motion.',
        },
        {
          'question': 'What is the SI unit for pressure?',
          'options': ['Newton', 'Pascal', 'Joule', 'Watt'],
          'correct': 1,
          'explanation':
              'The Pascal (Pa) is the SI unit for pressure. One Pascal equals one Newton per square meter. Pressure is force per unit area.',
        },
        {
          'question': 'What is the formula for mechanical advantage?',
          'options': [
            'MA = F_out/F_in',
            'MA = F_in/F_out',
            'MA = d_in/d_out',
            'MA = d_out/d_in'
          ],
          'correct': 0,
          'explanation':
              'Mechanical advantage is the ratio of output force to input force: MA = F_out/F_in. It measures how much a machine multiplies the input force.',
        },
        {
          'question': 'What is the law of inertia?',
          'options': [
            'Newton\'s First Law',
            'Newton\'s Second Law',
            'Newton\'s Third Law',
            'Law of Gravity'
          ],
          'correct': 0,
          'explanation':
              'Newton\'s First Law (Law of Inertia) states that an object at rest stays at rest and an object in motion stays in motion unless acted upon by an external force.',
        },
        {
          'question': 'What is the formula for weight?',
          'options': ['W = mg', 'W = ma', 'W = mv', 'W = Fd'],
          'correct': 0,
          'explanation':
              'Weight is the force of gravity on an object: W = mg, where m is mass and g is gravitational acceleration (9.8 m/s² on Earth).',
        },
      ],
    },
    {
      'name': 'AP Physics 2',
      'color': [Color(0xFFa8edea), Color(0xFFfed6e3)],
      'icon': Icons.waves,
      'description': 'Advanced Physics Concepts',
      'questions': [
        {
          'question':
              'What is the relationship between pressure and volume in Boyle\'s Law?',
          'options': [
            'Directly proportional',
            'Inversely proportional',
            'No relationship',
            'Exponential'
          ],
          'correct': 1,
          'explanation':
              'Boyle\'s Law states that pressure and volume are inversely proportional when temperature is held constant. This means P₁V₁ = P₂V₂, so as pressure increases, volume decreases.',
        },
        {
          'question': 'What is the speed of light in vacuum?',
          'options': [
            '3 × 10⁸ m/s',
            '3 × 10⁶ m/s',
            '3 × 10⁵ m/s',
            '3 × 10⁷ m/s'
          ],
          'correct': 0,
          'explanation':
              'The speed of light in vacuum is approximately 3 × 10⁸ meters per second (300,000,000 m/s). This is a fundamental constant in physics and the maximum speed at which information can travel.',
        },
        {
          'question': 'Which wave can travel through vacuum?',
          'options': [
            'Sound waves',
            'Water waves',
            'Electromagnetic waves',
            'Seismic waves'
          ],
          'correct': 2,
          'explanation':
              'Electromagnetic waves (like light, radio waves, X-rays) can travel through vacuum because they don\'t require a medium. Sound waves, water waves, and seismic waves all require a medium to propagate.',
        },
        {
          'question': 'What is the unit of electric charge?',
          'options': ['Ampere', 'Volt', 'Coulomb', 'Ohm'],
          'correct': 2,
          'explanation':
              'The Coulomb (C) is the SI unit of electric charge. One Coulomb is defined as the charge transported by a constant current of one Ampere in one second.',
        },
        {
          'question': 'What is the principle of conservation of energy?',
          'options': [
            'Energy cannot be created or destroyed',
            'Energy can be created',
            'Energy can be destroyed',
            'Energy is always increasing'
          ],
          'correct': 0,
          'explanation':
              'The principle of conservation of energy states that energy cannot be created or destroyed, only transformed from one form to another. The total energy in a closed system remains constant.',
        },
        {
          'question':
              'What is the relationship between temperature and volume in Charles\'s Law?',
          'options': [
            'Directly proportional',
            'Inversely proportional',
            'No relationship',
            'Exponential'
          ],
          'correct': 0,
          'explanation':
              'Charles\'s Law states that volume and temperature are directly proportional when pressure is held constant. This means V₁/T₁ = V₂/T₂, so as temperature increases, volume increases.',
        },
        {
          'question': 'What is the wavelength of visible light?',
          'options': ['400-700 nm', '400-700 μm', '400-700 mm', '400-700 m'],
          'correct': 0,
          'explanation':
              'Visible light has wavelengths ranging from approximately 400 nanometers (violet) to 700 nanometers (red). This is the range of electromagnetic radiation that human eyes can detect.',
        },
        {
          'question': 'What is the unit of electric potential difference?',
          'options': ['Ampere', 'Volt', 'Coulomb', 'Ohm'],
          'correct': 1,
          'explanation':
              'The Volt (V) is the SI unit of electric potential difference. One Volt is defined as the potential difference that will cause a current of one Ampere to flow through a resistance of one Ohm.',
        },
        {
          'question': 'What is the law of reflection?',
          'options': [
            'Angle of incidence equals angle of reflection',
            'Light always bends',
            'Light always travels in straight lines',
            'Light always speeds up'
          ],
          'correct': 0,
          'explanation':
              'The law of reflection states that the angle of incidence equals the angle of reflection. Both angles are measured from the normal (perpendicular) to the reflecting surface.',
        },
        {
          'question':
              'What is the relationship between current and voltage in Ohm\'s Law?',
          'options': [
            'Directly proportional',
            'Inversely proportional',
            'No relationship',
            'Exponential'
          ],
          'correct': 0,
          'explanation':
              'Ohm\'s Law states that current is directly proportional to voltage when resistance is constant: I = V/R. This means as voltage increases, current increases proportionally.',
        },
        {
          'question': 'What is the unit of electrical resistance?',
          'options': ['Ampere', 'Volt', 'Coulomb', 'Ohm'],
          'correct': 3,
          'explanation':
              'The Ohm (Ω) is the SI unit of electrical resistance. One Ohm is defined as the resistance that allows a current of one Ampere to flow when a voltage of one Volt is applied.',
        },
        {
          'question': 'What is the principle of superposition?',
          'options': [
            'Waves can interfere',
            'Waves always cancel each other',
            'Waves always amplify each other',
            'Waves cannot interact'
          ],
          'correct': 0,
          'explanation':
              'The principle of superposition states that when two or more waves meet, the resultant displacement is the algebraic sum of the individual wave displacements. This allows for interference patterns.',
        },
        {
          'question':
              'What is the relationship between pressure and temperature in Gay-Lussac\'s Law?',
          'options': [
            'Directly proportional',
            'Inversely proportional',
            'No relationship',
            'Exponential'
          ],
          'correct': 0,
          'explanation':
              'Gay-Lussac\'s Law states that pressure and temperature are directly proportional when volume is held constant. This means P₁/T₁ = P₂/T₂, so as temperature increases, pressure increases.',
        },
        {
          'question': 'What is the unit of magnetic field strength?',
          'options': ['Tesla', 'Gauss', 'Weber', 'Henry'],
          'correct': 0,
          'explanation':
              'The Tesla (T) is the SI unit of magnetic field strength. One Tesla is defined as the magnetic field that produces a force of one Newton on a one-meter wire carrying one Ampere of current.',
        },
        {
          'question': 'What is the law of refraction?',
          'options': [
            'Snell\'s Law',
            'Hooke\'s Law',
            'Coulomb\'s Law',
            'Ohm\'s Law'
          ],
          'correct': 0,
          'explanation':
              'Snell\'s Law describes the relationship between the angles of incidence and refraction when light passes from one medium to another: n₁sin(θ₁) = n₂sin(θ₂).',
        },
        {
          'question': 'What is the unit of capacitance?',
          'options': ['Farad', 'Henry', 'Weber', 'Tesla'],
          'correct': 0,
          'explanation':
              'The Farad (F) is the SI unit of capacitance. One Farad is defined as the capacitance that stores one Coulomb of charge when one Volt is applied.',
        },
        {
          'question':
              'What is the relationship between frequency and wavelength?',
          'options': [
            'Inversely proportional',
            'Directly proportional',
            'No relationship',
            'Exponential'
          ],
          'correct': 0,
          'explanation':
              'Frequency and wavelength are inversely proportional: f = c/λ, where c is the speed of light. This means as frequency increases, wavelength decreases.',
        },
        {
          'question': 'What is the unit of inductance?',
          'options': ['Farad', 'Henry', 'Weber', 'Tesla'],
          'correct': 1,
          'explanation':
              'The Henry (H) is the SI unit of inductance. One Henry is defined as the inductance that produces an electromotive force of one Volt when the current changes at a rate of one Ampere per second.',
        },
        {
          'question': 'What is the principle of conservation of charge?',
          'options': [
            'Charge cannot be created or destroyed',
            'Charge can be created',
            'Charge can be destroyed',
            'Charge always increases'
          ],
          'correct': 0,
          'explanation':
              'The principle of conservation of charge states that electric charge cannot be created or destroyed, only transferred from one object to another. The total charge in a closed system remains constant.',
        },
        {
          'question':
              'What is the relationship between power and current in electrical circuits?',
          'options': ['P = IV', 'P = I/V', 'P = V/I', 'P = I²V'],
          'correct': 0,
          'explanation':
              'Electrical power is the product of current and voltage: P = IV. This formula shows that power increases with both current and voltage.',
        },
      ],
    },
    {
      'name': 'AP Chemistry',
      'color': [Color(0xFFffecd2), Color(0xFFfcb69f)],
      'icon': Icons.science_outlined,
      'description': 'Chemical Principles',
      'questions': [
        {
          'question': 'What is the atomic number of carbon?',
          'options': ['6', '12', '14', '8'],
          'correct': 0,
          'explanation':
              'The atomic number of carbon is 6. This means carbon has 6 protons in its nucleus and 6 electrons in a neutral atom. The atomic number defines the element.',
        },
        {
          'question':
              'What type of bond is formed between sodium and chlorine in NaCl?',
          'options': ['Covalent', 'Ionic', 'Metallic', 'Hydrogen'],
          'correct': 1,
          'explanation':
              'NaCl forms an ionic bond. Sodium (Na) donates an electron to chlorine (Cl), forming Na⁺ and Cl⁻ ions. These oppositely charged ions are attracted to each other, creating an ionic bond.',
        },
        {
          'question': 'What is the pH of a neutral solution?',
          'options': ['0', '7', '14', '10'],
          'correct': 1,
          'explanation':
              'A neutral solution has a pH of 7. The pH scale ranges from 0 to 14, where pH < 7 is acidic, pH = 7 is neutral, and pH > 7 is basic.',
        },
        {
          'question': 'What is the molecular formula for glucose?',
          'options': ['C₆H₁₂O₆', 'C₆H₁₀O₅', 'C₅H₁₂O₆', 'C₆H₁₂O₅'],
          'correct': 0,
          'explanation':
              'The molecular formula for glucose is C₆H₁₂O₆. This means glucose contains 6 carbon atoms, 12 hydrogen atoms, and 6 oxygen atoms.',
        },
        {
          'question': 'What is the charge of an electron?',
          'options': ['Positive', 'Negative', 'Neutral', 'Variable'],
          'correct': 1,
          'explanation':
              'An electron has a negative charge. The elementary charge of an electron is approximately -1.602 × 10⁻¹⁹ Coulombs.',
        },
        {
          'question': 'What is the atomic mass unit of carbon-12?',
          'options': ['6', '12', '14', '16'],
          'correct': 1,
          'explanation':
              'Carbon-12 is defined as having exactly 12 atomic mass units (amu). This is the standard reference for atomic mass calculations.',
        },
        {
          'question':
              'What type of bond is formed between two hydrogen atoms in H₂?',
          'options': ['Ionic', 'Covalent', 'Metallic', 'Hydrogen'],
          'correct': 1,
          'explanation':
              'H₂ forms a covalent bond. Both hydrogen atoms share their single electron to achieve a stable electron configuration, creating a single covalent bond.',
        },
        {
          'question': 'What is the formula for sulfuric acid?',
          'options': ['H₂SO₄', 'HCl', 'HNO₃', 'H₃PO₄'],
          'correct': 0,
          'explanation':
              'Sulfuric acid has the formula H₂SO₄. It is a strong acid with two hydrogen atoms, one sulfur atom, and four oxygen atoms.',
        },
        {
          'question': 'What is the charge of a proton?',
          'options': ['Positive', 'Negative', 'Neutral', 'Variable'],
          'correct': 0,
          'explanation':
              'A proton has a positive charge. The elementary charge of a proton is approximately +1.602 × 10⁻¹⁹ Coulombs, equal in magnitude but opposite in sign to an electron.',
        },
        {
          'question': 'What is the molecular formula for water?',
          'options': ['H₂O', 'CO₂', 'NH₃', 'CH₄'],
          'correct': 0,
          'explanation':
              'Water has the molecular formula H₂O, consisting of two hydrogen atoms and one oxygen atom. It is essential for life and has unique properties.',
        },
        {
          'question': 'What is the atomic number of oxygen?',
          'options': ['6', '8', '10', '16'],
          'correct': 1,
          'explanation':
              'The atomic number of oxygen is 8. This means oxygen has 8 protons in its nucleus and 8 electrons in a neutral atom.',
        },
        {
          'question': 'What type of reaction is: 2H₂ + O₂ → 2H₂O?',
          'options': [
            'Synthesis',
            'Decomposition',
            'Single replacement',
            'Double replacement'
          ],
          'correct': 0,
          'explanation':
              'This is a synthesis (combination) reaction. Two or more reactants combine to form a single product. Hydrogen and oxygen combine to form water.',
        },
        {
          'question': 'What is the molecular formula for methane?',
          'options': ['CH₄', 'C₂H₆', 'C₃H₈', 'C₄H₁₀'],
          'correct': 0,
          'explanation':
              'Methane has the molecular formula CH₄. It is the simplest alkane, consisting of one carbon atom bonded to four hydrogen atoms.',
        },
        {
          'question': 'What is the charge of a neutron?',
          'options': ['Positive', 'Negative', 'Neutral', 'Variable'],
          'correct': 2,
          'explanation':
              'A neutron has no electrical charge; it is neutral. Neutrons are found in the nucleus of atoms along with protons.',
        },
        {
          'question': 'What is the molecular formula for carbon dioxide?',
          'options': ['CO₂', 'CO', 'C₂O', 'C₂O₂'],
          'correct': 0,
          'explanation':
              'Carbon dioxide has the molecular formula CO₂. It consists of one carbon atom double-bonded to two oxygen atoms.',
        },
        {
          'question': 'What is the atomic number of nitrogen?',
          'options': ['5', '6', '7', '8'],
          'correct': 2,
          'explanation':
              'The atomic number of nitrogen is 7. This means nitrogen has 7 protons in its nucleus and 7 electrons in a neutral atom.',
        },
        {
          'question':
              'What type of bond is formed between carbon and hydrogen in CH₄?',
          'options': ['Ionic', 'Covalent', 'Metallic', 'Hydrogen'],
          'correct': 1,
          'explanation':
              'CH₄ forms covalent bonds. Carbon shares its four valence electrons with four hydrogen atoms, creating four single covalent bonds.',
        },
        {
          'question': 'What is the molecular formula for ammonia?',
          'options': ['NH₃', 'NO₂', 'N₂O', 'N₂O₃'],
          'correct': 0,
          'explanation':
              'Ammonia has the molecular formula NH₃. It consists of one nitrogen atom bonded to three hydrogen atoms.',
        },
        {
          'question': 'What is the atomic number of hydrogen?',
          'options': ['0', '1', '2', '3'],
          'correct': 1,
          'explanation':
              'The atomic number of hydrogen is 1. This means hydrogen has 1 proton in its nucleus and 1 electron in a neutral atom.',
        },
        {
          'question': 'What is the molecular formula for ethanol?',
          'options': ['C₂H₅OH', 'CH₃OH', 'C₃H₇OH', 'C₄H₉OH'],
          'correct': 0,
          'explanation':
              'Ethanol has the molecular formula C₂H₅OH. It consists of two carbon atoms, six hydrogen atoms, and one oxygen atom, with the OH group attached to one carbon.',
        },
        {
          'question': 'What is the molecular formula for ethanol?',
          'options': ['C₂H₅OH', 'CH₃OH', 'C₃H₇OH', 'C₄H₉OH'],
          'correct': 0,
          'explanation':
              'Ethanol has the molecular formula C₂H₅OH. It consists of two carbon atoms, six hydrogen atoms, and one oxygen atom, with the OH group attached to one carbon.',
        },
        {
          'question': 'What is the atomic number of helium?',
          'options': ['1', '2', '3', '4'],
          'correct': 1,
          'explanation':
              'The atomic number of helium is 2. This means helium has 2 protons in its nucleus and 2 electrons in a neutral atom.',
        },
        {
          'question':
              'What type of bond is formed between carbon and oxygen in CO₂?',
          'options': ['Ionic', 'Covalent', 'Metallic', 'Hydrogen'],
          'correct': 1,
          'explanation':
              'CO₂ forms covalent bonds. Carbon shares its four valence electrons with two oxygen atoms, creating double covalent bonds.',
        },
        {
          'question': 'What is the molecular formula for glucose?',
          'options': ['C₆H₁₂O₆', 'C₆H₁₀O₅', 'C₅H₁₂O₆', 'C₆H₁₂O₅'],
          'correct': 0,
          'explanation':
              'The molecular formula for glucose is C₆H₁₂O₆. This means glucose contains 6 carbon atoms, 12 hydrogen atoms, and 6 oxygen atoms.',
        },
        {
          'question': 'What is the atomic number of neon?',
          'options': ['8', '9', '10', '11'],
          'correct': 2,
          'explanation':
              'The atomic number of neon is 10. This means neon has 10 protons in its nucleus and 10 electrons in a neutral atom.',
        },
        {
          'question': 'What type of reaction is: CaCO₃ → CaO + CO₂?',
          'options': [
            'Synthesis',
            'Decomposition',
            'Single replacement',
            'Double replacement'
          ],
          'correct': 1,
          'explanation':
              'This is a decomposition reaction. A single compound breaks down into two or more simpler substances. Calcium carbonate decomposes into calcium oxide and carbon dioxide.',
        },
        {
          'question': 'What is the molecular formula for propane?',
          'options': ['CH₄', 'C₂H₆', 'C₃H₈', 'C₄H₁₀'],
          'correct': 2,
          'explanation':
              'Propane has the molecular formula C₃H₈. It is an alkane with three carbon atoms and eight hydrogen atoms.',
        },
        {
          'question': 'What is the atomic number of sodium?',
          'options': ['9', '10', '11', '12'],
          'correct': 2,
          'explanation':
              'The atomic number of sodium is 11. This means sodium has 11 protons in its nucleus and 11 electrons in a neutral atom.',
        },
        {
          'question':
              'What type of bond is formed between hydrogen and fluorine in HF?',
          'options': ['Ionic', 'Covalent', 'Metallic', 'Hydrogen'],
          'correct': 1,
          'explanation':
              'HF forms a covalent bond. Hydrogen and fluorine share electrons to achieve stable electron configurations.',
        },
        {
          'question': 'What is the molecular formula for benzene?',
          'options': ['C₆H₆', 'C₆H₁₂', 'C₆H₁₀', 'C₆H₈'],
          'correct': 0,
          'explanation':
              'Benzene has the molecular formula C₆H₆. It is an aromatic hydrocarbon with six carbon atoms arranged in a ring and six hydrogen atoms.',
        },
      ],
    },
    {
      'name': 'AP Biology',
      'color': [Color(0xFF84fab0), Color(0xFF8fd3f4)],
      'icon': Icons.biotech,
      'description': 'Biological Systems',
      'questions': [
        {
          'question': 'What is the powerhouse of the cell?',
          'options': [
            'Nucleus',
            'Mitochondria',
            'Endoplasmic reticulum',
            'Golgi apparatus'
          ],
          'correct': 1,
          'explanation':
              'Mitochondria are called the powerhouse of the cell because they produce most of the cell\'s energy through cellular respiration, converting glucose and oxygen into ATP.',
        },
        {
          'question':
              'What is the process by which plants make their own food?',
          'options': [
            'Respiration',
            'Photosynthesis',
            'Digestion',
            'Fermentation'
          ],
          'correct': 1,
          'explanation':
              'Photosynthesis is the process by which plants convert sunlight, carbon dioxide, and water into glucose and oxygen. This is how plants make their own food.',
        },
        {
          'question': 'What are the building blocks of proteins?',
          'options': [
            'Nucleotides',
            'Amino acids',
            'Fatty acids',
            'Monosaccharides'
          ],
          'correct': 1,
          'explanation':
              'Amino acids are the building blocks of proteins. There are 20 different amino acids that can be combined in various sequences to form different proteins.',
        },
        {
          'question': 'What is the genetic material of most organisms?',
          'options': ['RNA', 'DNA', 'Protein', 'Lipid'],
          'correct': 1,
          'explanation':
              'DNA (Deoxyribonucleic acid) is the genetic material of most organisms. It contains the instructions for building and maintaining an organism and is passed from parents to offspring.',
        },
        {
          'question': 'What is the process of cell division called?',
          'options': ['Mitosis', 'Meiosis', 'Both A and B', 'Neither A nor B'],
          'correct': 2,
          'explanation':
              'Both mitosis and meiosis are processes of cell division. Mitosis produces two identical daughter cells, while meiosis produces four genetically different cells and is used for sexual reproduction.',
        },
        {
          'question': 'What is the control center of the cell?',
          'options': ['Nucleus', 'Mitochondria', 'Cytoplasm', 'Cell membrane'],
          'correct': 0,
          'explanation':
              'The nucleus is the control center of the cell. It contains the cell\'s genetic material (DNA) and controls all cellular activities by regulating gene expression.',
        },
        {
          'question':
              'What is the process of breaking down glucose to release energy?',
          'options': [
            'Photosynthesis',
            'Cellular respiration',
            'Fermentation',
            'Digestion'
          ],
          'correct': 1,
          'explanation':
              'Cellular respiration is the process by which cells break down glucose and other organic molecules to release energy in the form of ATP. It occurs in the mitochondria.',
        },
        {
          'question': 'What are the building blocks of DNA?',
          'options': [
            'Amino acids',
            'Nucleotides',
            'Fatty acids',
            'Monosaccharides'
          ],
          'correct': 1,
          'explanation':
              'Nucleotides are the building blocks of DNA. Each nucleotide consists of a sugar (deoxyribose), a phosphate group, and a nitrogenous base (adenine, thymine, cytosine, or guanine).',
        },
        {
          'question': 'What is the process of making proteins from RNA called?',
          'options': [
            'Transcription',
            'Translation',
            'Replication',
            'Mutation'
          ],
          'correct': 1,
          'explanation':
              'Translation is the process of making proteins from RNA. It occurs in the ribosomes and involves reading the genetic code in mRNA to assemble amino acids into proteins.',
        },
        {
          'question': 'What is the process of copying DNA called?',
          'options': [
            'Transcription',
            'Translation',
            'Replication',
            'Mutation'
          ],
          'correct': 2,
          'explanation':
              'DNA replication is the process of copying DNA. It occurs before cell division and ensures that each daughter cell receives an identical copy of the genetic material.',
        },
        {
          'question': 'What is the basic unit of life?',
          'options': ['Atom', 'Molecule', 'Cell', 'Tissue'],
          'correct': 2,
          'explanation':
              'The cell is the basic unit of life. All living organisms are composed of cells, and cells are the smallest units that can carry out all the functions of life.',
        },
        {
          'question': 'What is the process of making RNA from DNA called?',
          'options': [
            'Transcription',
            'Translation',
            'Replication',
            'Mutation'
          ],
          'correct': 0,
          'explanation':
              'Transcription is the process of making RNA from DNA. It occurs in the nucleus and involves copying the genetic information from DNA into messenger RNA (mRNA).',
        },
        {
          'question': 'What are the building blocks of carbohydrates?',
          'options': [
            'Amino acids',
            'Nucleotides',
            'Fatty acids',
            'Monosaccharides'
          ],
          'correct': 3,
          'explanation':
              'Monosaccharides are the building blocks of carbohydrates. Simple sugars like glucose, fructose, and galactose are examples of monosaccharides.',
        },
        {
          'question': 'What is the process of natural selection?',
          'options': [
            'Survival of the fittest',
            'Random chance',
            'Divine intervention',
            'Human selection'
          ],
          'correct': 0,
          'explanation':
              'Natural selection is the process by which organisms with favorable traits are more likely to survive and reproduce, leading to the evolution of species over time.',
        },
        {
          'question': 'What is the function of the cell membrane?',
          'options': [
            'To control what enters and exits the cell',
            'To produce energy',
            'To store genetic material',
            'To make proteins'
          ],
          'correct': 0,
          'explanation':
              'The cell membrane controls what enters and exits the cell. It is selectively permeable, allowing some substances to pass through while blocking others.',
        },
        {
          'question': 'What is the process of evolution?',
          'options': [
            'Change over time',
            'Instant transformation',
            'Random mutation only',
            'Human intervention'
          ],
          'correct': 0,
          'explanation':
              'Evolution is the process of change over time. It involves changes in the genetic makeup of populations over generations, leading to the diversity of life on Earth.',
        },
        {
          'question': 'What are the building blocks of lipids?',
          'options': [
            'Amino acids',
            'Nucleotides',
            'Fatty acids',
            'Monosaccharides'
          ],
          'correct': 2,
          'explanation':
              'Fatty acids are the building blocks of lipids. Lipids include fats, oils, and waxes, and they are important for energy storage and cell membrane structure.',
        },
        {
          'question': 'What is the process of cell specialization called?',
          'options': ['Differentiation', 'Division', 'Mutation', 'Evolution'],
          'correct': 0,
          'explanation':
              'Cell differentiation is the process by which cells become specialized for specific functions. This allows multicellular organisms to have different types of cells with different roles.',
        },
        {
          'question': 'What is the study of heredity called?',
          'options': ['Genetics', 'Ecology', 'Anatomy', 'Physiology'],
          'correct': 0,
          'explanation':
              'Genetics is the study of heredity and the variation of inherited characteristics. It involves the study of genes, DNA, and how traits are passed from parents to offspring.',
        },
        {
          'question':
              'What is the process of maintaining internal balance called?',
          'options': ['Homeostasis', 'Metabolism', 'Respiration', 'Digestion'],
          'correct': 0,
          'explanation':
              'Homeostasis is the process of maintaining internal balance and stability in an organism. It involves regulating various physiological processes to keep conditions within a narrow range.',
        },
        {
          'question':
              'What is the process of cell division for growth and repair called?',
          'options': ['Mitosis', 'Meiosis', 'Binary fission', 'Budding'],
          'correct': 0,
          'explanation':
              'Mitosis is the process of cell division used for growth and repair. It produces two identical daughter cells with the same number of chromosomes as the parent cell.',
        },
        {
          'question':
              'What is the process of cell division for sexual reproduction called?',
          'options': ['Mitosis', 'Meiosis', 'Binary fission', 'Budding'],
          'correct': 1,
          'explanation':
              'Meiosis is the process of cell division used for sexual reproduction. It produces four genetically different cells with half the number of chromosomes as the parent cell.',
        },
        {
          'question':
              'What is the study of how organisms interact with their environment called?',
          'options': ['Genetics', 'Ecology', 'Anatomy', 'Physiology'],
          'correct': 1,
          'explanation':
              'Ecology is the study of how organisms interact with each other and their environment. It includes the study of populations, communities, ecosystems, and the biosphere.',
        },
        {
          'question':
              'What is the process of breaking down food to release energy called?',
          'options': [
            'Photosynthesis',
            'Cellular respiration',
            'Digestion',
            'Fermentation'
          ],
          'correct': 1,
          'explanation':
              'Cellular respiration is the process of breaking down food molecules to release energy in the form of ATP. It occurs in the mitochondria of cells.',
        },
        {
          'question': 'What is the process of making RNA from DNA called?',
          'options': [
            'Transcription',
            'Translation',
            'Replication',
            'Mutation'
          ],
          'correct': 0,
          'explanation':
              'Transcription is the process of making RNA from DNA. It occurs in the nucleus and involves copying the genetic information from DNA into messenger RNA (mRNA).',
        },
        {
          'question': 'What is the process of making proteins from RNA called?',
          'options': [
            'Transcription',
            'Translation',
            'Replication',
            'Mutation'
          ],
          'correct': 1,
          'explanation':
              'Translation is the process of making proteins from RNA. It occurs in the ribosomes and involves reading the genetic code in mRNA to assemble amino acids into proteins.',
        },
        {
          'question': 'What is the process of copying DNA called?',
          'options': [
            'Transcription',
            'Translation',
            'Replication',
            'Mutation'
          ],
          'correct': 2,
          'explanation':
              'DNA replication is the process of copying DNA. It occurs before cell division and ensures that each daughter cell receives an identical copy of the genetic material.',
        },
        {
          'question':
              'What is the process of change in species over time called?',
          'options': ['Evolution', 'Adaptation', 'Mutation', 'Selection'],
          'correct': 0,
          'explanation':
              'Evolution is the process of change in species over time. It involves changes in the genetic makeup of populations over generations, leading to the diversity of life on Earth.',
        },
        {
          'question':
              'What is the process of organisms adapting to their environment called?',
          'options': ['Evolution', 'Adaptation', 'Mutation', 'Selection'],
          'correct': 1,
          'explanation':
              'Adaptation is the process by which organisms become better suited to their environment. It can occur through natural selection, where favorable traits become more common in a population.',
        },
      ],
    },
    {
      'name': 'AP Statistics',
      'color': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      'icon': Icons.bar_chart,
      'description': 'Data Analysis & Probability',
      'questions': [
        {
          'question': 'What is the mean of the dataset: 2, 4, 6, 8, 10?',
          'options': ['5', '6', '7', '8'],
          'correct': 1,
          'explanation': 'Mean = (2 + 4 + 6 + 8 + 10) / 5 = 30 / 5 = 6.',
        },
        {
          'question': 'What is the median of the dataset: 1, 3, 5, 7, 9, 11?',
          'options': ['5', '6', '7', '8'],
          'correct': 1,
          'explanation':
              'For an even number of values, median is the average of the two middle values: (5 + 7) / 2 = 6.',
        },
        {
          'question':
              'What is the standard deviation of the dataset: 2, 4, 4, 4, 5, 5, 7, 9?',
          'options': ['2', '2.5', '3', '3.5'],
          'correct': 0,
          'explanation':
              'First find mean = 5, then calculate variance = Σ(x-μ)²/n = 16/8 = 2, so SD = √2 ≈ 1.41.',
        },
        {
          'question':
              'What is the probability of rolling a sum of 7 with two dice?',
          'options': ['1/6', '1/12', '1/18', '1/36'],
          'correct': 0,
          'explanation':
              'There are 6 ways to get sum 7: (1,6), (2,5), (3,4), (4,3), (5,2), (6,1). Total outcomes = 36. So P(7) = 6/36 = 1/6.',
        },
        {
          'question': 'What is the correlation coefficient if r² = 0.64?',
          'options': ['0.8', '0.64', '0.4', '0.32'],
          'correct': 0,
          'explanation':
              'r = √r² = √0.64 = 0.8. The correlation coefficient is the square root of the coefficient of determination.',
        },
      ],
    },
    {
      'name': 'AP Physics C: Mechanics',
      'color': [Color(0xFF43e97b), Color(0xFF38f9d7)],
      'icon': Icons.science,
      'description': 'Classical Mechanics & Motion',
      'questions': [
        {
          'question': 'What is the acceleration due to gravity on Earth?',
          'options': ['9.8 m/s²', '9.8 m/s', '9.8 N/kg', '9.8 kg/m³'],
          'correct': 0,
          'explanation':
              'The acceleration due to gravity on Earth is approximately 9.8 m/s² downward.',
        },
        {
          'question': 'What is the formula for kinetic energy?',
          'options': ['KE = ½mv²', 'KE = mv', 'KE = mgh', 'KE = Fd'],
          'correct': 0,
          'explanation':
              'Kinetic energy is KE = ½mv², where m is mass and v is velocity.',
        },
        {
          'question': 'What is the unit of force in the SI system?',
          'options': ['Newton', 'Joule', 'Watt', 'Pascal'],
          'correct': 0,
          'explanation':
              'The Newton (N) is the SI unit of force. 1 N = 1 kg·m/s².',
        },
        {
          'question': 'What is the law of conservation of momentum?',
          'options': [
            'Total momentum remains constant',
            'Momentum can be created',
            'Momentum can be destroyed',
            'Momentum always increases'
          ],
          'correct': 0,
          'explanation':
              'The law of conservation of momentum states that the total momentum of a closed system remains constant if no external forces act on it.',
        },
        {
          'question': 'What is the formula for centripetal acceleration?',
          'options': ['a = v²/r', 'a = v/r', 'a = r/v²', 'a = v/r²'],
          'correct': 0,
          'explanation':
              'Centripetal acceleration is a = v²/r, where v is velocity and r is radius of the circular path.',
        },
      ],
    },
    {
      'name': 'AP English Literature',
      'color': [Color(0xFFfa709a), Color(0xFFfee140)],
      'icon': Icons.book,
      'description': 'Literary Analysis & Composition',
      'questions': [
        {
          'question': 'What is a metaphor?',
          'options': [
            'Direct comparison without like/as',
            'Comparison using like/as',
            'Repetition of sounds',
            'Exaggeration for effect'
          ],
          'correct': 0,
          'explanation':
              'A metaphor is a direct comparison between two unlike things without using "like" or "as".',
        },
        {
          'question': 'What is dramatic irony?',
          'options': [
            'Audience knows something characters don\'t',
            'Character says opposite of what they mean',
            'Unexpected outcome',
            'Repetition of words'
          ],
          'correct': 0,
          'explanation':
              'Dramatic irony occurs when the audience knows something that the characters in the story do not.',
        },
        {
          'question': 'What is a sonnet?',
          'options': [
            '14-line poem',
            '16-line poem',
            '12-line poem',
            '18-line poem'
          ],
          'correct': 0,
          'explanation':
              'A sonnet is a 14-line poem, typically written in iambic pentameter with a specific rhyme scheme.',
        },
        {
          'question': 'What is personification?',
          'options': [
            'Giving human qualities to non-human things',
            'Comparing two things',
            'Repetition of consonant sounds',
            'Using words that sound like what they mean'
          ],
          'correct': 0,
          'explanation':
              'Personification is giving human characteristics to non-human objects, animals, or ideas.',
        },
        {
          'question': 'What is a soliloquy?',
          'options': [
            'Character speaking alone on stage',
            'Conversation between characters',
            'Narrator\'s commentary',
            'Stage directions'
          ],
          'correct': 0,
          'explanation':
              'A soliloquy is a speech given by a character alone on stage, revealing their thoughts and feelings.',
        },
      ],
    },
    {
      'name': 'AP US History',
      'color': [Color(0xFFa8edea), Color(0xFFfed6e3)],
      'icon': Icons.history,
      'description': 'American History & Government',
      'questions': [
        {
          'question': 'In what year did Columbus first reach the Americas?',
          'options': ['1492', '1493', '1491', '1494'],
          'correct': 0,
          'explanation':
              'Christopher Columbus first reached the Americas in 1492, landing in the Bahamas.',
        },
        {
          'question':
              'What was the first permanent English settlement in North America?',
          'options': ['Jamestown', 'Plymouth', 'Roanoke', 'St. Augustine'],
          'correct': 0,
          'explanation':
              'Jamestown, Virginia, established in 1607, was the first permanent English settlement in North America.',
        },
        {
          'question':
              'In what year was the Declaration of Independence signed?',
          'options': ['1776', '1775', '1777', '1778'],
          'correct': 0,
          'explanation':
              'The Declaration of Independence was signed on July 4, 1776.',
        },
        {
          'question': 'Who was the first President of the United States?',
          'options': [
            'George Washington',
            'John Adams',
            'Thomas Jefferson',
            'Benjamin Franklin'
          ],
          'correct': 0,
          'explanation':
              'George Washington was the first President of the United States, serving from 1789 to 1797.',
        },
        {
          'question': 'What was the Louisiana Purchase?',
          'options': [
            'Land purchase from France',
            'Land purchase from Spain',
            'Land purchase from Mexico',
            'Land purchase from Britain'
          ],
          'correct': 0,
          'explanation':
              'The Louisiana Purchase was the acquisition of territory from France in 1803, doubling the size of the United States.',
        },
      ],
    },
    {
      'name': 'IB Mathematics HL',
      'color': [Color(0xFFffecd2), Color(0xFFfcb69f)],
      'icon': Icons.calculate,
      'description': 'Higher Level Mathematics',
      'questions': [
        {
          'question': 'What is the derivative of ln(x)?',
          'options': ['1/x', 'x', 'e^x', '1'],
          'correct': 0,
          'explanation':
              'The derivative of ln(x) is 1/x. This is a fundamental derivative in calculus.',
        },
        {
          'question': 'What is the integral of e^x?',
          'options': ['e^x + C', 'e^x', 'x + C', 'ln(x) + C'],
          'correct': 0,
          'explanation':
              'The integral of e^x is e^x + C. The exponential function is unique in that its derivative and integral are the same.',
        },
        {
          'question':
              'What is the limit of (1 + 1/n)^n as n approaches infinity?',
          'options': ['e', '1', '0', '∞'],
          'correct': 0,
          'explanation':
              'This is the definition of e: lim(n→∞) (1 + 1/n)^n = e ≈ 2.718.',
        },
        {
          'question':
              'What is the sum of the infinite geometric series with first term 1 and common ratio 1/2?',
          'options': ['2', '1', '1/2', '∞'],
          'correct': 0,
          'explanation': 'Sum = a/(1-r) = 1/(1-1/2) = 1/(1/2) = 2.',
        },
        {
          'question': 'What is the complex number i²?',
          'options': ['-1', '1', 'i', '0'],
          'correct': 0,
          'explanation':
              'i² = -1. This is the fundamental property of the imaginary unit i.',
        },
      ],
    },
    {
      'name': 'IB Physics HL',
      'color': [Color(0xFF667eea), Color(0xFF764ba2)],
      'icon': Icons.radio,
      'description': 'Higher Level Physics',
      'questions': [
        {
          'question': 'What is the speed of light in vacuum?',
          'options': [
            '3 × 10⁸ m/s',
            '3 × 10⁶ m/s',
            '3 × 10⁵ m/s',
            '3 × 10⁷ m/s'
          ],
          'correct': 0,
          'explanation':
              'The speed of light in vacuum is approximately 3 × 10⁸ meters per second.',
        },
        {
          'question': 'What is Planck\'s constant?',
          'options': [
            '6.63 × 10⁻³⁴ J·s',
            '6.63 × 10⁻³² J·s',
            '6.63 × 10⁻³⁶ J·s',
            '6.63 × 10⁻³⁰ J·s'
          ],
          'correct': 0,
          'explanation':
              'Planck\'s constant is approximately 6.63 × 10⁻³⁴ joule-seconds.',
        },
        {
          'question': 'What is the formula for energy-mass equivalence?',
          'options': ['E = mc²', 'E = mgh', 'E = ½mv²', 'E = Fd'],
          'correct': 0,
          'explanation':
              'Einstein\'s famous equation E = mc² relates energy and mass.',
        },
        {
          'question': 'What is the unit of electric charge?',
          'options': ['Coulomb', 'Ampere', 'Volt', 'Ohm'],
          'correct': 0,
          'explanation': 'The Coulomb (C) is the SI unit of electric charge.',
        },
        {
          'question': 'What is the principle of superposition?',
          'options': [
            'Waves can interfere',
            'Waves always cancel',
            'Waves always amplify',
            'Waves cannot interact'
          ],
          'correct': 0,
          'explanation':
              'The principle of superposition states that when two or more waves meet, the resultant displacement is the algebraic sum of the individual wave displacements.',
        },
      ],
    },
    {
      'name': 'IB Chemistry HL',
      'color': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'icon': Icons.science,
      'description': 'Higher Level Chemistry',
      'questions': [
        {
          'question': 'What is the atomic number of carbon?',
          'options': ['6', '12', '14', '8'],
          'correct': 0,
          'explanation':
              'The atomic number of carbon is 6. This means carbon has 6 protons in its nucleus.',
        },
        {
          'question': 'What is the molecular formula for water?',
          'options': ['H₂O', 'CO₂', 'NH₃', 'CH₄'],
          'correct': 0,
          'explanation':
              'Water has the molecular formula H₂O, consisting of two hydrogen atoms and one oxygen atom.',
        },
        {
          'question':
              'What type of bond is formed between sodium and chlorine in NaCl?',
          'options': ['Ionic', 'Covalent', 'Metallic', 'Hydrogen'],
          'correct': 0,
          'explanation':
              'NaCl forms an ionic bond. Sodium donates an electron to chlorine, forming Na⁺ and Cl⁻ ions.',
        },
        {
          'question': 'What is the pH of a neutral solution?',
          'options': ['7', '0', '14', '10'],
          'correct': 0,
          'explanation':
              'A neutral solution has a pH of 7. The pH scale ranges from 0 to 14.',
        },
        {
          'question': 'What is the charge of an electron?',
          'options': ['Negative', 'Positive', 'Neutral', 'Variable'],
          'correct': 0,
          'explanation':
              'An electron has a negative charge. The elementary charge of an electron is approximately -1.602 × 10⁻¹⁹ Coulombs.',
        },
      ],
    },
    {
      'name': 'IB Biology HL',
      'color': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      'icon': Icons.biotech,
      'description': 'Higher Level Biology',
      'questions': [
        {
          'question': 'What is the powerhouse of the cell?',
          'options': [
            'Mitochondria',
            'Nucleus',
            'Endoplasmic reticulum',
            'Golgi apparatus'
          ],
          'correct': 0,
          'explanation':
              'Mitochondria are called the powerhouse of the cell because they produce most of the cell\'s energy through cellular respiration.',
        },
        {
          'question':
              'What is the process by which plants make their own food?',
          'options': [
            'Photosynthesis',
            'Respiration',
            'Digestion',
            'Fermentation'
          ],
          'correct': 0,
          'explanation':
              'Photosynthesis is the process by which plants convert sunlight, carbon dioxide, and water into glucose and oxygen.',
        },
        {
          'question': 'What are the building blocks of proteins?',
          'options': [
            'Amino acids',
            'Nucleotides',
            'Fatty acids',
            'Monosaccharides'
          ],
          'correct': 0,
          'explanation':
              'Amino acids are the building blocks of proteins. There are 20 different amino acids that can be combined to form proteins.',
        },
        {
          'question': 'What is the genetic material of most organisms?',
          'options': ['DNA', 'RNA', 'Protein', 'Lipid'],
          'correct': 0,
          'explanation':
              'DNA (Deoxyribonucleic acid) is the genetic material of most organisms. It contains the instructions for building and maintaining an organism.',
        },
        {
          'question': 'What is the process of cell division called?',
          'options': ['Mitosis', 'Meiosis', 'Both A and B', 'Neither A nor B'],
          'correct': 2,
          'explanation':
              'Both mitosis and meiosis are processes of cell division. Mitosis produces two identical daughter cells, while meiosis produces four genetically different cells.',
        },
      ],
    },
    {
      'name': 'AP World History',
      'color': [Color(0xFF43e97b), Color(0xFF38f9d7)],
      'icon': Icons.public,
      'description': 'Global History & Civilizations',
      'questions': [
        {
          'question': 'What was the first civilization to develop writing?',
          'options': ['Sumerians', 'Egyptians', 'Chinese', 'Indus Valley'],
          'correct': 0,
          'explanation':
              'The Sumerians of Mesopotamia developed cuneiform writing around 3200 BCE, making them the first civilization with a writing system.',
        },
        {
          'question': 'What was the Silk Road?',
          'options': [
            'Trade route connecting East and West',
            'Military road',
            'Religious pilgrimage route',
            'Migration path'
          ],
          'correct': 0,
          'explanation':
              'The Silk Road was a network of trade routes connecting the East and West, facilitating the exchange of goods, ideas, and cultures.',
        },
        {
          'question': 'What was the Renaissance?',
          'options': [
            'Cultural rebirth in Europe',
            'Religious movement',
            'Political revolution',
            'Economic system'
          ],
          'correct': 0,
          'explanation':
              'The Renaissance was a period of cultural rebirth in Europe from the 14th to 17th centuries, marked by renewed interest in classical learning and arts.',
        },
        {
          'question': 'What was the Industrial Revolution?',
          'options': [
            'Transition to new manufacturing processes',
            'Political revolution',
            'Agricultural reform',
            'Religious movement'
          ],
          'correct': 0,
          'explanation':
              'The Industrial Revolution was the transition to new manufacturing processes in the late 18th and early 19th centuries, transforming agrarian societies into industrial ones.',
        },
        {
          'question': 'What was the Cold War?',
          'options': [
            'Political tension between US and USSR',
            'Military conflict',
            'Economic competition',
            'Cultural exchange'
          ],
          'correct': 0,
          'explanation':
              'The Cold War was a period of political tension between the United States and the Soviet Union from 1947 to 1991, characterized by ideological conflict without direct military engagement.',
        },
      ],
    },
    {
      'name': 'AP Environmental Science',
      'color': [Color(0xFFfa709a), Color(0xFFfee140)],
      'icon': Icons.eco,
      'description': 'Environmental Systems & Ecology',
      'questions': [
        {
          'question': 'What is biodiversity?',
          'options': [
            'Variety of life on Earth',
            'Number of species',
            'Genetic diversity',
            'All of the above'
          ],
          'correct': 3,
          'explanation':
              'Biodiversity refers to the variety of life on Earth, including species diversity, genetic diversity, and ecosystem diversity.',
        },
        {
          'question': 'What is the greenhouse effect?',
          'options': [
            'Trapping of heat by atmospheric gases',
            'Cooling of the Earth',
            'Ozone depletion',
            'Acid rain'
          ],
          'correct': 0,
          'explanation':
              'The greenhouse effect is the trapping of heat by atmospheric gases like carbon dioxide, which helps maintain Earth\'s temperature.',
        },
        {
          'question': 'What is sustainable development?',
          'options': [
            'Development that meets present needs without compromising future generations',
            'Economic growth only',
            'Environmental protection only',
            'Social equality only'
          ],
          'correct': 0,
          'explanation':
              'Sustainable development meets the needs of the present without compromising the ability of future generations to meet their own needs.',
        },
        {
          'question': 'What is the primary cause of climate change?',
          'options': [
            'Human activities',
            'Natural cycles',
            'Solar radiation',
            'Volcanic eruptions'
          ],
          'correct': 0,
          'explanation':
              'Human activities, particularly the burning of fossil fuels, are the primary cause of current climate change.',
        },
        {
          'question': 'What is an ecosystem?',
          'options': [
            'Community of living organisms and their environment',
            'Group of animals',
            'Plant community',
            'Water system'
          ],
          'correct': 0,
          'explanation':
              'An ecosystem is a community of living organisms interacting with their physical environment.',
        },
      ],
    },
    {
      'name': 'IB Economics HL',
      'color': [Color(0xFFa8edea), Color(0xFFfed6e3)],
      'icon': Icons.trending_up,
      'description': 'Higher Level Economics',
      'questions': [
        {
          'question': 'What is opportunity cost?',
          'options': [
            'Value of the next best alternative',
            'Total cost of production',
            'Fixed cost',
            'Variable cost'
          ],
          'correct': 0,
          'explanation':
              'Opportunity cost is the value of the next best alternative that must be forgone when making a choice.',
        },
        {
          'question': 'What is the law of supply?',
          'options': [
            'Quantity supplied increases as price increases',
            'Quantity supplied decreases as price increases',
            'Supply is always constant',
            'Supply is independent of price'
          ],
          'correct': 0,
          'explanation':
              'The law of supply states that, all else being equal, the quantity supplied of a good increases as its price increases.',
        },
        {
          'question': 'What is GDP?',
          'options': [
            'Gross Domestic Product',
            'Gross Domestic Price',
            'General Domestic Product',
            'Global Domestic Product'
          ],
          'correct': 0,
          'explanation':
              'GDP stands for Gross Domestic Product, which measures the total value of goods and services produced within a country\'s borders.',
        },
        {
          'question': 'What is inflation?',
          'options': [
            'General increase in price levels',
            'Decrease in money supply',
            'Increase in unemployment',
            'Decrease in GDP'
          ],
          'correct': 0,
          'explanation':
              'Inflation is a general increase in the price level of goods and services in an economy over time.',
        },
        {
          'question': 'What is a monopoly?',
          'options': [
            'Single seller in a market',
            'Multiple sellers',
            'Perfect competition',
            'Oligopoly'
          ],
          'correct': 0,
          'explanation':
              'A monopoly is a market structure with a single seller who has significant market power and can control prices.',
        },
      ],
    },
    {
      'name': 'IB English A HL',
      'color': [Color(0xFFffecd2), Color(0xFFfcb69f)],
      'icon': Icons.language,
      'description': 'Higher Level English Literature',
      'questions': [
        {
          'question': 'What is a simile?',
          'options': [
            'Comparison using like or as',
            'Direct comparison',
            'Repetition of sounds',
            'Exaggeration'
          ],
          'correct': 0,
          'explanation':
              'A simile is a figure of speech that compares two things using "like" or "as".',
        },
        {
          'question': 'What is alliteration?',
          'options': [
            'Repetition of initial consonant sounds',
            'Repetition of vowel sounds',
            'Repetition of words',
            'Repetition of phrases'
          ],
          'correct': 0,
          'explanation':
              'Alliteration is the repetition of initial consonant sounds in nearby words.',
        },
        {
          'question': 'What is a theme?',
          'options': [
            'Central message or meaning',
            'Character description',
            'Setting details',
            'Plot summary'
          ],
          'correct': 0,
          'explanation':
              'A theme is the central message, meaning, or insight that a literary work conveys.',
        },
        {
          'question': 'What is foreshadowing?',
          'options': [
            'Hints about future events',
            'Flashback to past events',
            'Character development',
            'Setting description'
          ],
          'correct': 0,
          'explanation':
              'Foreshadowing is a literary device that provides hints or clues about events that will occur later in the story.',
        },
        {
          'question': 'What is a protagonist?',
          'options': [
            'Main character',
            'Villain',
            'Supporting character',
            'Narrator'
          ],
          'correct': 0,
          'explanation':
              'A protagonist is the main character of a literary work, around whom the plot revolves.',
        },
      ],
    },
    {
      'name': 'IB History HL',
      'color': [Color(0xFF667eea), Color(0xFF764ba2)],
      'icon': Icons.history_edu,
      'description': 'Higher Level History',
      'questions': [
        {
          'question': 'What was the Treaty of Versailles?',
          'options': [
            'Peace treaty ending WWI',
            'Trade agreement',
            'Military alliance',
            'Economic pact'
          ],
          'correct': 0,
          'explanation':
              'The Treaty of Versailles was the peace treaty that officially ended World War I, signed in 1919.',
        },
        {
          'question': 'What was the French Revolution?',
          'options': [
            'Period of radical social and political change in France',
            'Military conquest',
            'Economic reform',
            'Religious movement'
          ],
          'correct': 0,
          'explanation':
              'The French Revolution was a period of radical social and political upheaval in France from 1789 to 1799.',
        },
        {
          'question': 'What was the Berlin Wall?',
          'options': [
            'Barrier dividing East and West Berlin',
            'Trade route',
            'Military fortification',
            'Cultural center'
          ],
          'correct': 0,
          'explanation':
              'The Berlin Wall was a barrier that divided East and West Berlin from 1961 to 1989, symbolizing the Cold War division.',
        },
        {
          'question': 'What was the Cuban Missile Crisis?',
          'options': [
            '13-day confrontation between US and USSR',
            'Trade dispute',
            'Military invasion',
            'Economic crisis'
          ],
          'correct': 0,
          'explanation':
              'The Cuban Missile Crisis was a 13-day confrontation between the United States and the Soviet Union in October 1962.',
        },
        {
          'question': 'What was the Holocaust?',
          'options': [
            'Systematic genocide of Jews by Nazi Germany',
            'Economic depression',
            'Political revolution',
            'Military conflict'
          ],
          'correct': 0,
          'explanation':
              'The Holocaust was the systematic genocide of approximately six million Jews by Nazi Germany during World War II.',
        },
      ],
    },
    {
      'name': 'IB Psychology HL',
      'color': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'icon': Icons.psychology,
      'description': 'Higher Level Psychology',
      'questions': [
        {
          'question': 'What is classical conditioning?',
          'options': [
            'Learning through association',
            'Learning through consequences',
            'Learning through observation',
            'Learning through insight'
          ],
          'correct': 0,
          'explanation':
              'Classical conditioning is a type of learning where an organism learns to associate two stimuli through repeated pairing.',
        },
        {
          'question': 'What is operant conditioning?',
          'options': [
            'Learning through consequences',
            'Learning through association',
            'Learning through observation',
            'Learning through insight'
          ],
          'correct': 0,
          'explanation':
              'Operant conditioning is a type of learning where behavior is strengthened or weakened by consequences.',
        },
        {
          'question': 'What is cognitive dissonance?',
          'options': [
            'Mental discomfort from conflicting beliefs',
            'Memory loss',
            'Anxiety disorder',
            'Depression'
          ],
          'correct': 0,
          'explanation':
              'Cognitive dissonance is the mental discomfort experienced when holding conflicting beliefs or attitudes.',
        },
        {
          'question': 'What is the placebo effect?',
          'options': [
            'Improvement due to belief in treatment',
            'Side effect of medication',
            'Natural healing',
            'Psychological disorder'
          ],
          'correct': 0,
          'explanation':
              'The placebo effect is when a person experiences improvement due to their belief in the effectiveness of a treatment.',
        },
        {
          'question': 'What is confirmation bias?',
          'options': [
            'Tendency to favor information confirming beliefs',
            'Memory distortion',
            'Attention deficit',
            'Learning disability'
          ],
          'correct': 0,
          'explanation':
              'Confirmation bias is the tendency to search for, interpret, and remember information that confirms one\'s preexisting beliefs.',
        },
      ],
    },
    {
      'name': 'Algebra 1',
      'color': [Color(0xFF667eea), Color(0xFF764ba2)],
      'icon': Icons.functions,
      'description': 'Foundational Algebra & Linear Equations',
      'questions': [
        {
          'question': 'Solve for x: 2x + 5 = 13',
          'options': ['x = 4', 'x = 6', 'x = 8', 'x = 9'],
          'correct': 0,
          'explanation':
              'Subtract 5 from both sides: 2x = 8. Then divide both sides by 2: x = 4.',
        },
        {
          'question': 'What is the slope of the line y = 3x - 2?',
          'options': ['3', '-2', '2', '-3'],
          'correct': 0,
          'explanation':
              'In the equation y = mx + b, m is the slope. So the slope is 3.',
        },
        {
          'question': 'Factor: x² + 5x + 6',
          'options': [
            '(x + 2)(x + 3)',
            '(x + 1)(x + 6)',
            '(x + 2)(x + 4)',
            '(x + 3)(x + 3)'
          ],
          'correct': 0,
          'explanation':
              'Find two numbers that multiply to 6 and add to 5: 2 and 3. So x² + 5x + 6 = (x + 2)(x + 3).',
        },
        {
          'question': 'Solve the system: y = 2x + 1 and y = -x + 4',
          'options': [
            'x = 1, y = 3',
            'x = 2, y = 5',
            'x = 0, y = 1',
            'x = 3, y = 7'
          ],
          'correct': 0,
          'explanation':
              'Set 2x + 1 = -x + 4. Add x to both sides: 3x + 1 = 4. Subtract 1: 3x = 3. Divide by 3: x = 1. Substitute: y = 2(1) + 1 = 3.',
        },
        {
          'question': 'What is the y-intercept of y = -2x + 7?',
          'options': ['7', '-2', '2', '-7'],
          'correct': 0,
          'explanation':
              'In the equation y = mx + b, b is the y-intercept. So the y-intercept is 7.',
        },
      ],
    },
    {
      'name': 'Algebra 2',
      'color': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'icon': Icons.polyline,
      'description': 'Advanced Algebra & Functions',
      'questions': [
        {
          'question': 'Solve: x² - 4x + 4 = 0',
          'options': ['x = 2', 'x = -2', 'x = 2 or x = -2', 'x = 4'],
          'correct': 0,
          'explanation':
              'This is a perfect square: x² - 4x + 4 = (x - 2)² = 0. So x - 2 = 0, therefore x = 2.',
        },
        {
          'question': 'What is the domain of f(x) = √(x - 3)?',
          'options': ['x ≥ 3', 'x > 3', 'x ≤ 3', 'All real numbers'],
          'correct': 0,
          'explanation':
              'The expression under the square root must be non-negative. So x - 3 ≥ 0, which means x ≥ 3.',
        },
        {
          'question': 'Find the inverse of f(x) = 2x + 1',
          'options': [
            'f⁻¹(x) = (x - 1)/2',
            'f⁻¹(x) = x/2 - 1',
            'f⁻¹(x) = 2x - 1',
            'f⁻¹(x) = (x + 1)/2'
          ],
          'correct': 0,
          'explanation':
              'To find the inverse, swap x and y: x = 2y + 1. Solve for y: x - 1 = 2y, so y = (x - 1)/2.',
        },
        {
          'question': 'What is the range of f(x) = x² + 2?',
          'options': ['y ≥ 2', 'y > 2', 'y ≤ 2', 'All real numbers'],
          'correct': 0,
          'explanation':
              'Since x² is always non-negative, x² + 2 is always ≥ 2. So the range is y ≥ 2.',
        },
        {
          'question': 'Solve: log₂(x) = 3',
          'options': ['x = 8', 'x = 6', 'x = 9', 'x = 5'],
          'correct': 0,
          'explanation': 'log₂(x) = 3 means 2³ = x. So x = 8.',
        },
      ],
    },
    {
      'name': 'Algebra 3',
      'color': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      'icon': Icons.trending_up,
      'description': 'Pre-Calculus & Advanced Functions',
      'questions': [
        {
          'question': 'What is the period of f(x) = sin(2x)?',
          'options': ['π', '2π', 'π/2', '4π'],
          'correct': 0,
          'explanation':
              'For sin(bx), the period is 2π/b. Here b = 2, so period = 2π/2 = π.',
        },
        {
          'question': 'Find the asymptotes of f(x) = (x + 2)/(x - 3)',
          'options': [
            'x = 3, y = 1',
            'x = -2, y = 1',
            'x = 3, y = 0',
            'x = -2, y = 0'
          ],
          'correct': 0,
          'explanation':
              'Vertical asymptote: x - 3 = 0, so x = 3. Horizontal asymptote: degree of numerator = degree of denominator, so y = 1/1 = 1.',
        },
        {
          'question': 'What is the amplitude of f(x) = 3cos(x)?',
          'options': ['3', '1', '6', '2'],
          'correct': 0,
          'explanation':
              'For acos(x), the amplitude is |a|. Here a = 3, so amplitude = 3.',
        },
        {
          'question': 'Solve: e^(2x) = 16',
          'options': ['x = ln(4)', 'x = 2ln(4)', 'x = ln(16)', 'x = 4'],
          'correct': 0,
          'explanation':
              'Take natural log of both sides: 2x = ln(16). Since 16 = 4², ln(16) = ln(4²) = 2ln(4). So 2x = 2ln(4), therefore x = ln(4).',
        },
        {
          'question': 'What is the phase shift of f(x) = sin(x - π/4)?',
          'options': [
            'π/4 to the right',
            'π/4 to the left',
            'π/2 to the right',
            'π/2 to the left'
          ],
          'correct': 0,
          'explanation':
              'For sin(x - c), the phase shift is c units to the right. Here c = π/4, so the phase shift is π/4 to the right.',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCourses();
    _loadUserPoints();

    // Initialize selectedSubject from widget if provided
    if (widget.selectedSubject != null) {
      selectedSubject = widget.selectedSubject;
      // Randomize questions for the selected subject
      _randomizeQuestions();
    }
  }

  Future<void> _initializeCourses() async {
    try {
      // Ensure database is up to date with new courses
      await _dbHelper.refreshPremadeSets();
      // Sync with premade study sets
      _syncWithPremadeStudySets();
    } catch (e) {
      debugPrint('Error initializing courses: $e');
      // Still sync with premade study sets even if database refresh fails
      _syncWithPremadeStudySets();
    }
  }

  void _randomizeQuestions() {
    if (selectedSubject != null) {
      final selectedClass =
          apClasses.firstWhere((cls) => cls['name'] == selectedSubject);
      final questions =
          List<Map<String, dynamic>>.from(selectedClass['questions']);
      questions.shuffle(); // Randomize the questions
      selectedClass['questions'] = questions;
    }
  }

  Future<void> _loadUserPoints() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    setState(() {
      currentPoints = points;
    });
  }

  void _syncWithPremadeStudySets() {
    final premadeSets = PremadeStudySetsRepository.getPremadeSets();
    debugPrint('Syncing with ${premadeSets.length} premade sets from repository');
    
    for (final set in premadeSets) {
      final alreadyExists = apClasses.any((cls) => cls['name'] == set.name);
      if (!alreadyExists) {
        debugPrint('Adding new course to MCQ manager: ${set.name}');
        apClasses.add({
          'name': set.name,
          'color': [Color(0xFF667eea), Color(0xFF764ba2)], // Default color
          'icon': Icons.functions, // Default icon
          'description': set.description,
          'questions': set.questions
              .map((q) => {
                    'question': q.questionText,
                    'options': q.options,
                    'correct': q.options.indexOf(q.correctAnswer),
                    'explanation': '',
                  })
              .toList(),
        });
      } else {
        debugPrint('Course already exists in MCQ manager: ${set.name}');
      }
    }
    
    debugPrint('Total courses in MCQ manager after sync: ${apClasses.length}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredAPClasses {
    if (_searchQuery.isEmpty) {
      return apClasses;
    }
    return apClasses.where((apClass) {
      String className = apClass['name'].toString().toLowerCase();
      String searchLower = _searchQuery.toLowerCase();
      return className.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // If selectedSubject is provided in constructor, go directly to quiz
    if (widget.selectedSubject != null) {
      return _buildQuizScreen();
    }

    // Otherwise show subject selection
    if (showAPCSChoice) {
      return _buildAPCSChoiceScreen();
    }
    if (selectedSubject != null) {
      return _buildQuizScreen();
    }
    return _buildSubjectSelectionScreen();
  }

  Widget _buildSubjectSelectionScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
        title: const Text(
          'Browse Sets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              try {
                await _dbHelper.refreshPremadeSets();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Study sets refreshed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error refreshing sets: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            tooltip: 'Refresh Study Sets',
          ),
        ],
      ),
      body: Stack(
        children: [
          const frq.SpaceBackground(),
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search sets...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withOpacity(0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                // AP Classes Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filteredAPClasses.length,
                      itemBuilder: (context, index) {
                        final apClass = filteredAPClasses[index];
                        return _buildAPClassCard(apClass);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPClassCard(Map<String, dynamic> apClass) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: apClass['color'][0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Add haptic feedback
            HapticFeedback.lightImpact();

            // Import the course for all courses without showing choice screen
            await _importMCQSet(apClass['name']);
            // The choice screen will only appear when practicing from MySets
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: apClass['color'],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      apClass['icon'],
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    apClass['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    apClass['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      apClass['name'] == 'AP Computer Science A'
                          ? '20 MCQs + 4 FRQs'
                          : '20 Questions',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final selectedClass =
        apClasses.firstWhere((cls) => cls['name'] == selectedSubject);
    // Use up to 20 questions, but not more than available
    final questions = (selectedClass['questions'] as List).take(20).toList();
    final totalQuestions = questions.length;

    // Prevent RangeError by checking bounds
    if (currentQuestionIndex >= totalQuestions) {
      return Center(
        child: Text(
          'You have completed all questions!',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
    }

    if (showResults) {
      return _buildResultsScreen(selectedClass, questions);
    }

    final currentQuestion = questions[currentQuestionIndex];
    final isSubmitted = submittedAnswers.containsKey(currentQuestionIndex);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  selectedClass['color'][0].withOpacity(0.1),
                  selectedClass['color'][1].withOpacity(0.1)
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            selectedSubject = null;
                            currentQuestionIndex = 0;
                            currentScore = 0;
                            showResults = false;
                            userAnswers.clear();
                            submittedAnswers.clear();
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selectedClass['color'][0].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Question ${currentQuestionIndex + 1}/${totalQuestions}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Points display in header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              '$currentPoints',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / totalQuestions,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          selectedClass['color'][0]),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Score and Points
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Score: $currentScore',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      // Points
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              '$currentPoints',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Question
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currentQuestion['question'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Answer options
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuestion['options'].length,
                      itemBuilder: (context, index) {
                        final option = currentQuestion['options'][index];
                        final isSelected =
                            userAnswers[currentQuestionIndex] == index;
                        final isCorrect =
                            isSubmitted && index == currentQuestion['correct'];
                        final isWrong = isSubmitted && isSelected && !isCorrect;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.2)
                                  : isWrong
                                      ? Colors.red.withOpacity(0.2)
                                      : isSelected
                                          ? selectedClass['color'][0]
                                              .withOpacity(0.2)
                                          : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCorrect
                                    ? Colors.green
                                    : isWrong
                                        ? Colors.red
                                        : isSelected
                                            ? selectedClass['color'][0]
                                            : Colors.white.withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              title: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isSubmitted
                                  ? Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : isWrong
                                              ? Icons.cancel
                                              : null,
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                    )
                                  : null,
                              onTap: isSubmitted
                                  ? null
                                  : () {
                                      setState(() {
                                        userAnswers[currentQuestionIndex] =
                                            index;
                                      });
                                    },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Navigation Buttons
                  if (!isSubmitted &&
                      userAnswers.containsKey(currentQuestionIndex))
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              final answer = userAnswers[currentQuestionIndex];
                              if (answer != null) {
                                submittedAnswers[currentQuestionIndex] = answer;
                                if (answer == currentQuestion['correct']) {
                                  currentScore++;
                                  currentPoints +=
                                      10; // Update points immediately
                                }
                              }
                            });
                            // Award 10 points for a correct answer
                            final answer = userAnswers[currentQuestionIndex];
                            if (answer != null &&
                                answer == currentQuestion['correct']) {
                              await _dbHelper.updateUserPoints(
                                  widget.username, currentPoints);
                              if (widget.onPointsUpdated != null) {
                                widget.onPointsUpdated!(currentPoints);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedClass['color'][0],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit Answer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (isSubmitted)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (currentQuestionIndex < totalQuestions - 1) {
                                currentQuestionIndex++;
                              } else {
                                showResults = true;
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                currentQuestionIndex < totalQuestions - 1
                                    ? selectedClass['color'][0]
                                    : Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            currentQuestionIndex < totalQuestions - 1
                                ? 'Next Question'
                                : 'Finish Quiz',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen(
      Map<String, dynamic> selectedClass, List questions) {
    final percentage = (currentScore / questions.length * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: selectedClass['color'][0],
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              selectedClass['color'][0].withOpacity(0.1),
              selectedClass['color'][1].withOpacity(0.1)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score Circle
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: selectedClass['color'],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: selectedClass['color'][0].withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$currentScore/${questions.length}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Points Earned
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Earned ${currentScore * 10} points!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Performance Message
                Text(
                  _getPerformanceMessage(percentage),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSubject = null;
                          currentQuestionIndex = 0;
                          currentScore = 0;
                          showResults = false;
                          userAnswers.clear();
                          submittedAnswers.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('New Quiz'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex = 0;
                          currentScore = 0;
                          showResults = false;
                          userAnswers.clear();
                          submittedAnswers.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedClass['color'][0],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPerformanceMessage(int percentage) {
    if (percentage >= 90) return 'Excellent! 🎉';
    if (percentage >= 80) return 'Great Job! 👍';
    if (percentage >= 70) return 'Good Work! 👏';
    if (percentage >= 60) return 'Not Bad! 💪';
    return 'Keep Practicing! 📚';
  }

  Widget _buildAPCSChoiceScreen() {
    final courseName = selectedSubject ?? 'Course';
    final courseData = apClasses.firstWhere(
      (cls) => cls['name'] == courseName,
      orElse: () => {
        'name': courseName,
        'color': [Color(0xFF4facfe), Color(0xFF00f2fe)],
        'icon': Icons.school,
      },
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              courseData['color'][0].withOpacity(0.8),
              courseData['color'][1].withOpacity(0.8),
              Color(0xFF1D1E33),
              Color(0xFF2A2B4A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        setState(() {
                          showAPCSChoice = false;
                          selectedSubject = null;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        courseName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: courseData['color'][0].withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          courseData['icon'],
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title with animation
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Choose Your Practice Mode',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // MCQ Button with enhanced design
                      Container(
                        width: double.infinity,
                        height: 80,
                        margin: const EdgeInsets.only(bottom: 25),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAPCSChoice = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue[600]!,
                                  Colors.blue[400]!,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.quiz,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Multiple Choice',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Test your knowledge',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // FRQ Button with enhanced design
                      Container(
                        width: double.infinity,
                        height: 80,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => frq.FRQManager(
                                  studySet: widget.studySet,
                                  username: widget.username,
                                  currentTheme: widget.currentTheme,
                                  frqCount: 4,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green[600]!,
                                  Colors.green[400]!,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Free Response',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Practice writing answers',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Decorative element
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add import functionality for MCQ sets
  Future<void> _importMCQSet(String subjectName) async {
    try {
      // Show loading state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text('Importing $subjectName...'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // The set name should match the one in PremadeStudySetsRepository
      final setName = subjectName;

      // Check if all premade sets are loaded
      final allSetsLoaded = await _dbHelper.areAllPremadeSetsLoaded();
      if (!allSetsLoaded) {
        debugPrint('Not all premade sets are loaded, refreshing database...');
        await _dbHelper.refreshPremadeSets();
      }

      // Find the set in the database
      final premadeSets = await _dbHelper.getPremadeStudySets();

      // Debug: Print all available premade sets
      debugPrint('Available premade sets in database:');
      for (var set in premadeSets) {
        debugPrint('- ${set['name']}');
      }
      debugPrint('Looking for: $setName');

      final dbSet = premadeSets.firstWhere(
        (set) => set['name'] == setName,
        orElse: () => {},
      );

      if (dbSet.isEmpty) {
        // Try refreshing premade sets first
        debugPrint('Set not found, attempting to refresh premade sets...');
        await _dbHelper.refreshPremadeSets();

        // Try again after refresh
        final refreshedSets = await _dbHelper.getPremadeStudySets();
        debugPrint('After refresh, available sets:');
        for (var set in refreshedSets) {
          debugPrint('- ${set['name']}');
        }

        final refreshedDbSet = refreshedSets.firstWhere(
          (set) => set['name'] == setName,
          orElse: () => {},
        );

        if (refreshedDbSet.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Set "$setName" not found. Please try refreshing the app.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Use the refreshed set
        final studySetId = refreshedDbSet['id'];
        await _dbHelper.importPremadeSet(widget.username, studySetId);
      } else {
        final studySetId = dbSet['id'];
        await _dbHelper.importPremadeSet(widget.username, studySetId);
      }

      // Show success message with animation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Successfully Imported!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subjectName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      // Notify parent to refresh
      widget.onSetImported?.call();
    } catch (e) {
      debugPrint('Error importing set: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Failed to import set. Please try refreshing the app.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}