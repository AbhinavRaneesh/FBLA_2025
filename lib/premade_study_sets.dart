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
        Question(
          questionText: 'What is the derivative of e^x?',
          options: ['e^x', 'xe^x', 'e^(x-1)', 'ln(x)'],
          correctAnswer: 'e^x',
        ),
        Question(
          questionText: 'What is the integral of 1/x?',
          options: ['ln|x| + C', 'x + C', '1/x² + C', 'ln(x) + C'],
          correctAnswer: 'ln|x| + C',
        ),
        Question(
          questionText: 'What is the derivative of sin(x)?',
          options: ['cos(x)', '-sin(x)', 'tan(x)', 'sec(x)'],
          correctAnswer: 'cos(x)',
        ),
        Question(
          questionText: 'What is the derivative of cos(x)?',
          options: ['-sin(x)', 'sin(x)', '-cos(x)', 'tan(x)'],
          correctAnswer: '-sin(x)',
        ),
        Question(
          questionText: 'What is the product rule formula?',
          options: [
            '(fg)\' = f\'g + fg\'',
            '(fg)\' = f\'g - fg\'',
            '(fg)\' = f\'g\'',
            '(fg)\' = fg + f\'g\''
          ],
          correctAnswer: '(fg)\' = f\'g + fg\'',
        ),
        Question(
          questionText: 'What is the quotient rule formula?',
          options: [
            '(f/g)\' = (f\'g - fg\')/g²',
            '(f/g)\' = (f\'g + fg\')/g²',
            '(f/g)\' = f\'/g\'',
            '(f/g)\' = f\'g - fg\''
          ],
          correctAnswer: '(f/g)\' = (f\'g - fg\')/g²',
        ),
        Question(
          questionText: 'What is the derivative of tan(x)?',
          options: ['sec²(x)', 'tan²(x)', 'cot(x)', 'csc(x)'],
          correctAnswer: 'sec²(x)',
        ),
        Question(
          questionText: 'What is the integral of cos(x)?',
          options: ['sin(x) + C', '-cos(x) + C', 'tan(x) + C', 'sec(x) + C'],
          correctAnswer: 'sin(x) + C',
        ),
        Question(
          questionText: 'What is the integral of sin(x)?',
          options: ['-cos(x) + C', 'cos(x) + C', 'tan(x) + C', 'cot(x) + C'],
          correctAnswer: '-cos(x) + C',
        ),
        Question(
          questionText: 'What is the derivative of x³?',
          options: ['3x²', 'x²', '3x', 'x³'],
          correctAnswer: '3x²',
        ),
        Question(
          questionText: 'What is the integral of x²?',
          options: ['x³/3 + C', 'x²/2 + C', 'x³ + C', '2x + C'],
          correctAnswer: 'x³/3 + C',
        ),
        Question(
          questionText: 'What is the limit of (1 + 1/n)^n as n approaches infinity?',
          options: ['e', '1', '0', 'infinity'],
          correctAnswer: 'e',
        ),
        Question(
          questionText: 'What is the derivative of √x?',
          options: ['1/(2√x)', '√x', '1/√x', '2√x'],
          correctAnswer: '1/(2√x)',
        ),
        Question(
          questionText: 'What is the integral of 1/√x?',
          options: ['2√x + C', '√x + C', '1/(2√x) + C', 'ln(√x) + C'],
          correctAnswer: '2√x + C',
        ),
        Question(
          questionText: 'What is the derivative of sec(x)?',
          options: ['sec(x)tan(x)', 'sec²(x)', 'tan(x)', 'csc(x)'],
          correctAnswer: 'sec(x)tan(x)',
        ),
        Question(
          questionText: 'What is the integral of sec²(x)?',
          options: ['tan(x) + C', 'sec(x) + C', 'cot(x) + C', 'csc(x) + C'],
          correctAnswer: 'tan(x) + C',
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
        Question(
          questionText: 'What is the Maclaurin series for sin(x)?',
          options: [
            'x - x³/3! + x⁵/5! - x⁷/7! + ...',
            'x + x³/3! + x⁵/5! + x⁷/7! + ...',
            '1 - x²/2! + x⁴/4! - x⁶/6! + ...',
            'x - x²/2! + x³/3! - x⁴/4! + ...'
          ],
          correctAnswer: 'x - x³/3! + x⁵/5! - x⁷/7! + ...',
        ),
        Question(
          questionText: 'What is the Maclaurin series for cos(x)?',
          options: [
            '1 - x²/2! + x⁴/4! - x⁶/6! + ...',
            'x - x³/3! + x⁵/5! - x⁷/7! + ...',
            '1 + x²/2! + x⁴/4! + x⁶/6! + ...',
            'x + x²/2! + x³/3! + x⁴/4! + ...'
          ],
          correctAnswer: '1 - x²/2! + x⁴/4! - x⁶/6! + ...',
        ),
        Question(
          questionText: 'What is the alternating series test?',
          options: [
            'If aₙ > 0, aₙ₊₁ ≤ aₙ, and lim aₙ = 0, then Σ(-1)ⁿaₙ converges',
            'If aₙ > 0 and lim aₙ = 0, then Σaₙ converges',
            'If aₙ alternates in sign, then Σaₙ converges',
            'If aₙ > 0 and decreasing, then Σaₙ converges'
          ],
          correctAnswer: 'If aₙ > 0, aₙ₊₁ ≤ aₙ, and lim aₙ = 0, then Σ(-1)ⁿaₙ converges',
        ),
        Question(
          questionText: 'What is the integral test?',
          options: [
            'If f(x) is positive, continuous, and decreasing, then Σf(n) converges if and only if ∫f(x)dx converges',
            'If f(x) is integrable, then Σf(n) converges',
            'If ∫f(x)dx converges, then Σf(n) converges',
            'If f(x) is continuous, then Σf(n) converges'
          ],
          correctAnswer: 'If f(x) is positive, continuous, and decreasing, then Σf(n) converges if and only if ∫f(x)dx converges',
        ),
        Question(
          questionText: 'What is the comparison test?',
          options: [
            'If 0 ≤ aₙ ≤ bₙ and Σbₙ converges, then Σaₙ converges',
            'If aₙ ≤ bₙ and Σbₙ converges, then Σaₙ converges',
            'If aₙ = bₙ and Σbₙ converges, then Σaₙ converges',
            'If aₙ > bₙ and Σbₙ diverges, then Σaₙ diverges'
          ],
          correctAnswer: 'If 0 ≤ aₙ ≤ bₙ and Σbₙ converges, then Σaₙ converges',
        ),
        Question(
          questionText: 'What is the limit comparison test?',
          options: [
            'If lim(aₙ/bₙ) = c > 0, then Σaₙ and Σbₙ both converge or both diverge',
            'If aₙ/bₙ approaches 0, then Σaₙ converges',
            'If aₙ/bₙ approaches infinity, then Σaₙ diverges',
            'If aₙ and bₙ are similar, then they have the same convergence'
          ],
          correctAnswer: 'If lim(aₙ/bₙ) = c > 0, then Σaₙ and Σbₙ both converge or both diverge',
        ),
        Question(
          questionText: 'What is the root test?',
          options: [
            'If limⁿ√|aₙ| < 1, the series converges absolutely',
            'If limⁿ√|aₙ| > 1, the series converges',
            'If limⁿ√|aₙ| = 1, the series always converges',
            'If limⁿ√|aₙ| exists, the series converges'
          ],
          correctAnswer: 'If limⁿ√|aₙ| < 1, the series converges absolutely',
        ),
        Question(
          questionText: 'What is the formula for the surface area of revolution?',
          options: [
            'S = 2π∫y√(1 + (dy/dx)²)dx',
            'S = π∫y²dx',
            'S = 2π∫ydx',
            'S = π∫√(1 + (dy/dx)²)dx'
          ],
          correctAnswer: 'S = 2π∫y√(1 + (dy/dx)²)dx',
        ),
        Question(
          questionText: 'What is the formula for the volume of revolution?',
          options: [
            'V = π∫y²dx',
            'V = 2π∫y²dx',
            'V = π∫ydx',
            'V = 2π∫ydx'
          ],
          correctAnswer: 'V = π∫y²dx',
        ),
        Question(
          questionText: 'What is the parametric derivative dy/dx?',
          options: [
            '(dy/dt)/(dx/dt)',
            '(dx/dt)/(dy/dt)',
            'dy/dt * dx/dt',
            'dy/dt + dx/dt'
          ],
          correctAnswer: '(dy/dt)/(dx/dt)',
        ),
        Question(
          questionText: 'What is the arc length formula for parametric curves?',
          options: [
            'L = ∫√((dx/dt)² + (dy/dt)²)dt',
            'L = ∫√(x² + y²)dt',
            'L = ∫√(dx/dt + dy/dt)dt',
            'L = ∫√((dx/dt)² - (dy/dt)²)dt'
          ],
          correctAnswer: 'L = ∫√((dx/dt)² + (dy/dt)²)dt',
        ),
        Question(
          questionText: 'What is the formula for the area between polar curves?',
          options: [
            'A = 1/2∫(r₁² - r₂²)dθ',
            'A = ∫(r₁ - r₂)dθ',
            'A = 1/2∫(r₁ + r₂)²dθ',
            'A = ∫r₁r₂dθ'
          ],
          correctAnswer: 'A = 1/2∫(r₁² - r₂²)dθ',
        ),
        Question(
          questionText: 'What is the nth term test for divergence?',
          options: [
            'If lim aₙ ≠ 0, then Σaₙ diverges',
            'If lim aₙ = 0, then Σaₙ converges',
            'If aₙ approaches infinity, then Σaₙ diverges',
            'If aₙ is bounded, then Σaₙ converges'
          ],
          correctAnswer: 'If lim aₙ ≠ 0, then Σaₙ diverges',
        ),
        Question(
          questionText: 'What is the geometric series formula?',
          options: [
            'Σarⁿ = a/(1-r) for |r| < 1',
            'Σarⁿ = a/(1+r) for |r| < 1',
            'Σarⁿ = a(1-rⁿ)/(1-r) for all r',
            'Σarⁿ = a/(1-r) for all r'
          ],
          correctAnswer: 'Σarⁿ = a/(1-r) for |r| < 1',
        ),
        Question(
          questionText: 'What is the p-series test?',
          options: [
            'Σ1/nᵖ converges if p > 1, diverges if p ≤ 1',
            'Σ1/nᵖ converges if p < 1, diverges if p ≥ 1',
            'Σ1/nᵖ converges if p = 1, diverges otherwise',
            'Σ1/nᵖ always converges'
          ],
          correctAnswer: 'Σ1/nᵖ converges if p > 1, diverges if p ≤ 1',
        ),
        Question(
          questionText: 'What is the harmonic series?',
          options: [
            'Σ1/n, which diverges',
            'Σ1/n², which converges',
            'Σ1/n³, which converges',
            'Σ1/n, which converges'
          ],
          correctAnswer: 'Σ1/n, which diverges',
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
        Question(
          questionText: 'What is a Type II error?',
          options: [
            'Failing to reject a false null hypothesis',
            'Rejecting a true null hypothesis',
            'Accepting a true alternative hypothesis',
            'Rejecting a false null hypothesis'
          ],
          correctAnswer: 'Failing to reject a false null hypothesis',
        ),
        Question(
          questionText: 'What is the power of a statistical test?',
          options: [
            'The probability of correctly rejecting a false null hypothesis',
            'The probability of rejecting a true null hypothesis',
            'The probability of accepting a true null hypothesis',
            'The probability of accepting a false null hypothesis'
          ],
          correctAnswer: 'The probability of correctly rejecting a false null hypothesis',
        ),
        Question(
          questionText: 'What is the formula for the z-score?',
          options: [
            'z = (x - μ)/σ',
            'z = (x - σ)/μ',
            'z = (μ - x)/σ',
            'z = (σ - x)/μ'
          ],
          correctAnswer: 'z = (x - μ)/σ',
        ),
        Question(
          questionText: 'What is the empirical rule (68-95-99.7 rule)?',
          options: [
            'In a normal distribution, 68% of data falls within 1σ, 95% within 2σ, 99.7% within 3σ',
            'In any distribution, 68% of data falls within 1σ, 95% within 2σ, 99.7% within 3σ',
            'In a normal distribution, 68% of data falls within 2σ, 95% within 3σ, 99.7% within 4σ',
            'In any distribution, 68% of data falls within 2σ, 95% within 3σ, 99.7% within 4σ'
          ],
          correctAnswer: 'In a normal distribution, 68% of data falls within 1σ, 95% within 2σ, 99.7% within 3σ',
        ),
        Question(
          questionText: 'What is the correlation coefficient r?',
          options: [
            'A measure of linear association between two variables, ranging from -1 to 1',
            'A measure of causation between two variables',
            'A measure of the strength of any relationship between variables',
            'A measure of the slope of the regression line'
          ],
          correctAnswer: 'A measure of linear association between two variables, ranging from -1 to 1',
        ),
        Question(
          questionText: 'What is the coefficient of determination R²?',
          options: [
            'The proportion of variance in the dependent variable explained by the independent variable',
            'The correlation coefficient squared',
            'The slope of the regression line',
            'The y-intercept of the regression line'
          ],
          correctAnswer: 'The proportion of variance in the dependent variable explained by the independent variable',
        ),
        Question(
          questionText: 'What is a residual?',
          options: [
            'The difference between observed and predicted values',
            'The difference between two observed values',
            'The standard deviation of the sample',
            'The mean of the sample'
          ],
          correctAnswer: 'The difference between observed and predicted values',
        ),
        Question(
          questionText: 'What is the chi-square test used for?',
          options: [
            'Testing for independence between categorical variables',
            'Testing for differences between means',
            'Testing for correlation between variables',
            'Testing for normality of data'
          ],
          correctAnswer: 'Testing for independence between categorical variables',
        ),
        Question(
          questionText: 'What is the t-test used for?',
          options: [
            'Comparing means when population standard deviation is unknown',
            'Comparing means when population standard deviation is known',
            'Testing for correlation',
            'Testing for independence'
          ],
          correctAnswer: 'Comparing means when population standard deviation is unknown',
        ),
        Question(
          questionText: 'What is the p-value?',
          options: [
            'The probability of obtaining a test statistic as extreme as or more extreme than the observed value, assuming the null hypothesis is true',
            'The probability that the null hypothesis is true',
            'The probability that the alternative hypothesis is true',
            'The significance level of the test'
          ],
          correctAnswer: 'The probability of obtaining a test statistic as extreme as or more extreme than the observed value, assuming the null hypothesis is true',
        ),
        Question(
          questionText: 'What is the significance level α?',
          options: [
            'The probability of rejecting a true null hypothesis (Type I error rate)',
            'The probability of accepting a false null hypothesis (Type II error rate)',
            'The p-value threshold for rejecting the null hypothesis',
            'The confidence level of the test'
          ],
          correctAnswer: 'The probability of rejecting a true null hypothesis (Type I error rate)',
        ),
        Question(
          questionText: 'What is the difference between one-tailed and two-tailed tests?',
          options: [
            'One-tailed tests look for differences in one direction, two-tailed tests look for differences in either direction',
            'One-tailed tests are more powerful than two-tailed tests',
            'Two-tailed tests are always preferred over one-tailed tests',
            'One-tailed tests are used for means, two-tailed tests for proportions'
          ],
          correctAnswer: 'One-tailed tests look for differences in one direction, two-tailed tests look for differences in either direction',
        ),
        Question(
          questionText: 'What is the standard deviation?',
          options: [
            'A measure of the spread of data around the mean',
            'The average of all data points',
            'The middle value when data is ordered',
            'The difference between the maximum and minimum values'
          ],
          correctAnswer: 'A measure of the spread of data around the mean',
        ),
        Question(
          questionText: 'What is the variance?',
          options: [
            'The square of the standard deviation',
            'The standard deviation divided by the mean',
            'The range of the data',
            'The interquartile range'
          ],
          correctAnswer: 'The square of the standard deviation',
        ),
        Question(
          questionText: 'What is the median?',
          options: [
            'The middle value when data is ordered from least to greatest',
            'The most frequently occurring value',
            'The average of all values',
            'The difference between the maximum and minimum values'
          ],
          correctAnswer: 'The middle value when data is ordered from least to greatest',
        ),
        Question(
          questionText: 'What is the mode?',
          options: [
            'The most frequently occurring value in a dataset',
            'The middle value when data is ordered',
            'The average of all values',
            'The range of the data'
          ],
          correctAnswer: 'The most frequently occurring value in a dataset',
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
        Question(
          questionText: 'What is Newton\'s Second Law?',
          options: [
            'F = ma (Force equals mass times acceleration)',
            'An object in motion stays in motion unless acted upon by an external force',
            'For every action there is an equal and opposite reaction',
            'Energy cannot be created or destroyed'
          ],
          correctAnswer: 'F = ma (Force equals mass times acceleration)',
        ),
        Question(
          questionText: 'What is Newton\'s Third Law?',
          options: [
            'For every action there is an equal and opposite reaction',
            'Force equals mass times acceleration',
            'An object in motion stays in motion unless acted upon by an external force',
            'Energy cannot be created or destroyed'
          ],
          correctAnswer: 'For every action there is an equal and opposite reaction',
        ),
        Question(
          questionText: 'What is the formula for gravitational potential energy?',
          options: ['PE = mgh', 'PE = 1/2mv²', 'PE = Fd', 'PE = ma'],
          correctAnswer: 'PE = mgh',
        ),
        Question(
          questionText: 'What is the SI unit of energy?',
          options: ['Joule', 'Newton', 'Watt', 'Pascal'],
          correctAnswer: 'Joule',
        ),
        Question(
          questionText: 'What is the formula for power?',
          options: ['P = W/t', 'P = Fd', 'P = mv', 'P = ma'],
          correctAnswer: 'P = W/t',
        ),
        Question(
          questionText: 'What is the SI unit of power?',
          options: ['Watt', 'Joule', 'Newton', 'Pascal'],
          correctAnswer: 'Watt',
        ),
        Question(
          questionText: 'What is the formula for momentum?',
          options: ['p = mv', 'p = ma', 'p = Fd', 'p = mgh'],
          correctAnswer: 'p = mv',
        ),
        Question(
          questionText: 'What is the principle of conservation of momentum?',
          options: [
            'Total momentum of a system remains constant if no external forces act on it',
            'Momentum can be created and destroyed',
            'Momentum always increases',
            'Momentum always decreases'
          ],
          correctAnswer: 'Total momentum of a system remains constant if no external forces act on it',
        ),
        Question(
          questionText: 'What is the formula for acceleration?',
          options: ['a = Δv/Δt', 'a = v/t', 'a = d/t', 'a = F/m'],
          correctAnswer: 'a = Δv/Δt',
        ),
        Question(
          questionText: 'What is the SI unit of acceleration?',
          options: ['m/s²', 'm/s', 'm', 's'],
          correctAnswer: 'm/s²',
        ),
        Question(
          questionText: 'What is the formula for velocity?',
          options: ['v = Δd/Δt', 'v = d/t', 'v = a/t', 'v = F/m'],
          correctAnswer: 'v = Δd/Δt',
        ),
        Question(
          questionText: 'What is the SI unit of velocity?',
          options: ['m/s', 'm/s²', 'm', 's'],
          correctAnswer: 'm/s',
        ),
        Question(
          questionText: 'What is the formula for displacement?',
          options: ['Δd = d_final - d_initial', 'Δd = v/t', 'Δd = a/t', 'Δd = F/m'],
          correctAnswer: 'Δd = d_final - d_initial',
        ),
        Question(
          questionText: 'What is the SI unit of displacement?',
          options: ['meter', 'second', 'm/s', 'm/s²'],
          correctAnswer: 'meter',
        ),
        Question(
          questionText: 'What is the formula for average speed?',
          options: ['v_avg = total distance/total time', 'v_avg = Δv/Δt', 'v_avg = a/t', 'v_avg = F/m'],
          correctAnswer: 'v_avg = total distance/total time',
        ),
        Question(
          questionText: 'What is the formula for average velocity?',
          options: ['v_avg = Δd/Δt', 'v_avg = total distance/total time', 'v_avg = a/t', 'v_avg = F/m'],
          correctAnswer: 'v_avg = Δd/Δt',
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
        Question(
          questionText: 'What is the second law of thermodynamics?',
          options: [
            'The entropy of an isolated system never decreases',
            'Heat always flows from hot to cold',
            'Energy cannot be created or destroyed',
            'The change in internal energy equals heat added minus work done'
          ],
          correctAnswer: 'The entropy of an isolated system never decreases',
        ),
        Question(
          questionText: 'What is the formula for electric field strength?',
          options: ['E = F/q', 'E = kq/r²', 'E = V/d', 'E = I/R'],
          correctAnswer: 'E = F/q',
        ),
        Question(
          questionText: 'What is the SI unit of electric field?',
          options: ['N/C (Newtons per Coulomb)', 'V/m (Volts per meter)', 'A/m (Amperes per meter)', 'T (Tesla)'],
          correctAnswer: 'N/C (Newtons per Coulomb)',
        ),
        Question(
          questionText: 'What is the formula for magnetic field strength?',
          options: ['B = F/qv', 'B = μ₀I/2πr', 'B = Φ/A', 'B = E/c'],
          correctAnswer: 'B = F/qv',
        ),
        Question(
          questionText: 'What is the SI unit of magnetic field?',
          options: ['Tesla (T)', 'Gauss (G)', 'Weber (Wb)', 'Henry (H)'],
          correctAnswer: 'Tesla (T)',
        ),
        Question(
          questionText: 'What is the formula for capacitance?',
          options: ['C = Q/V', 'C = ε₀A/d', 'C = 1/2CV²', 'C = I/V'],
          correctAnswer: 'C = Q/V',
        ),
        Question(
          questionText: 'What is the SI unit of capacitance?',
          options: ['Farad (F)', 'Coulomb (C)', 'Volt (V)', 'Ohm (Ω)'],
          correctAnswer: 'Farad (F)',
        ),
        Question(
          questionText: 'What is the formula for inductance?',
          options: ['L = Φ/I', 'L = -ε/(dI/dt)', 'L = 1/2LI²', 'L = V/I'],
          correctAnswer: 'L = Φ/I',
        ),
        Question(
          questionText: 'What is the SI unit of inductance?',
          options: ['Henry (H)', 'Weber (Wb)', 'Tesla (T)', 'Farad (F)'],
          correctAnswer: 'Henry (H)',
        ),
        Question(
          questionText: 'What is the formula for pressure in a fluid?',
          options: ['P = F/A', 'P = ρgh', 'P = nRT/V', 'P = mv'],
          correctAnswer: 'P = F/A',
        ),
        Question(
          questionText: 'What is the SI unit of pressure?',
          options: ['Pascal (Pa)', 'Atmosphere (atm)', 'Bar (bar)', 'Torr'],
          correctAnswer: 'Pascal (Pa)',
        ),
        Question(
          questionText: 'What is the formula for density?',
          options: ['ρ = m/V', 'ρ = F/A', 'ρ = P/RT', 'ρ = mv'],
          correctAnswer: 'ρ = m/V',
        ),
        Question(
          questionText: 'What is the SI unit of density?',
          options: ['kg/m³', 'g/cm³', 'kg/L', 'g/mL'],
          correctAnswer: 'kg/m³',
        ),
        Question(
          questionText: 'What is the formula for buoyant force?',
          options: ['F_b = ρVg', 'F_b = mg', 'F_b = PA', 'F_b = mv'],
          correctAnswer: 'F_b = ρVg',
        ),
        Question(
          questionText: 'What is the formula for heat capacity?',
          options: ['C = Q/ΔT', 'C = mc', 'C = nR', 'C = P/V'],
          correctAnswer: 'C = Q/ΔT',
        ),
        Question(
          questionText: 'What is the SI unit of heat capacity?',
          options: ['J/K', 'J/kg·K', 'J/mol·K', 'W/K'],
          correctAnswer: 'J/K',
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
        Question(
          questionText: 'What is the Arrhenius equation?',
          options: [
            'k = Ae^(-Ea/RT)',
            'k = A + Ea/RT',
            'k = A × Ea/RT',
            'k = A - Ea/RT'
          ],
          correctAnswer: 'k = Ae^(-Ea/RT)',
        ),
        Question(
          questionText: 'What is the formula for pH?',
          options: [
            'pH = -log[H⁺]',
            'pH = log[H⁺]',
            'pH = 14 - [H⁺]',
            'pH = [H⁺]/14'
          ],
          correctAnswer: 'pH = -log[H⁺]',
        ),
        Question(
          questionText: 'What is the formula for pOH?',
          options: [
            'pOH = -log[OH⁻]',
            'pOH = log[OH⁻]',
            'pOH = 14 - [OH⁻]',
            'pOH = [OH⁻]/14'
          ],
          correctAnswer: 'pOH = -log[OH⁻]',
        ),
        Question(
          questionText: 'What is the relationship between pH and pOH?',
          options: [
            'pH + pOH = 14',
            'pH - pOH = 14',
            'pH × pOH = 14',
            'pH ÷ pOH = 14'
          ],
          correctAnswer: 'pH + pOH = 14',
        ),
        Question(
          questionText: 'What is the formula for molarity?',
          options: [
            'M = moles solute/liters solution',
            'M = grams solute/liters solution',
            'M = moles solute/grams solution',
            'M = liters solute/moles solution'
          ],
          correctAnswer: 'M = moles solute/liters solution',
        ),
        Question(
          questionText: 'What is the formula for molality?',
          options: [
            'm = moles solute/kilograms solvent',
            'm = moles solute/liters solution',
            'm = grams solute/kilograms solvent',
            'm = kilograms solute/moles solvent'
          ],
          correctAnswer: 'm = moles solute/kilograms solvent',
        ),
        Question(
          questionText: 'What is the formula for mole fraction?',
          options: [
            'X = moles component/total moles',
            'X = grams component/total grams',
            'X = liters component/total liters',
            'X = moles component/grams component'
          ],
          correctAnswer: 'X = moles component/total moles',
        ),
        Question(
          questionText: 'What is the formula for percent by mass?',
          options: [
            '% mass = (mass solute/mass solution) × 100',
            '% mass = (mass solute/mass solvent) × 100',
            '% mass = (moles solute/moles solution) × 100',
            '% mass = (volume solute/volume solution) × 100'
          ],
          correctAnswer: '% mass = (mass solute/mass solution) × 100',
        ),
        Question(
          questionText: 'What is the formula for percent by volume?',
          options: [
            '% volume = (volume solute/volume solution) × 100',
            '% volume = (volume solute/volume solvent) × 100',
            '% volume = (mass solute/volume solution) × 100',
            '% volume = (moles solute/volume solution) × 100'
          ],
          correctAnswer: '% volume = (volume solute/volume solution) × 100',
        ),
        Question(
          questionText: 'What is the formula for parts per million (ppm)?',
          options: [
            'ppm = (mass solute/mass solution) × 10⁶',
            'ppm = (moles solute/moles solution) × 10⁶',
            'ppm = (volume solute/volume solution) × 10⁶',
            'ppm = (mass solute/mass solvent) × 10⁶'
          ],
          correctAnswer: 'ppm = (mass solute/mass solution) × 10⁶',
        ),
        Question(
          questionText: 'What is the formula for dilution?',
          options: [
            'M₁V₁ = M₂V₂',
            'M₁/V₁ = M₂/V₂',
            'M₁ + V₁ = M₂ + V₂',
            'M₁ × V₁ = M₂ × V₂'
          ],
          correctAnswer: 'M₁V₁ = M₂V₂',
        ),
        Question(
          questionText: 'What is the formula for osmotic pressure?',
          options: [
            'π = MRT',
            'π = P/RT',
            'π = n/V',
            'π = mRT'
          ],
          correctAnswer: 'π = MRT',
        ),
        Question(
          questionText: 'What is the formula for boiling point elevation?',
          options: [
            'ΔT_b = K_b × m',
            'ΔT_b = K_b × M',
            'ΔT_b = K_b × X',
            'ΔT_b = K_b × π'
          ],
          correctAnswer: 'ΔT_b = K_b × m',
        ),
        Question(
          questionText: 'What is the formula for freezing point depression?',
          options: [
            'ΔT_f = K_f × m',
            'ΔT_f = K_f × M',
            'ΔT_f = K_f × X',
            'ΔT_f = K_f × π'
          ],
          correctAnswer: 'ΔT_f = K_f × m',
        ),
        Question(
          questionText: 'What is the formula for vapor pressure lowering?',
          options: [
            'ΔP = X_solute × P°_solvent',
            'ΔP = m × P°_solvent',
            'ΔP = M × P°_solvent',
            'ΔP = π × P°_solvent'
          ],
          correctAnswer: 'ΔP = X_solute × P°_solvent',
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
        Question(
          questionText: 'What is the argument of a complex number?',
          options: [
            'The angle with the positive real axis in the complex plane',
            'The distance from the origin in the complex plane',
            'The real part of the number',
            'The imaginary part of the number'
          ],
          correctAnswer: 'The angle with the positive real axis in the complex plane',
        ),
        Question(
          questionText: 'What is the formula for the modulus of a complex number z = a + bi?',
          options: [
            '|z| = √(a² + b²)',
            '|z| = a + b',
            '|z| = a² + b²',
            '|z| = √(a - b)'
          ],
          correctAnswer: '|z| = √(a² + b²)',
        ),
        Question(
          questionText: 'What is Euler\'s formula?',
          options: [
            'e^(iθ) = cos θ + i sin θ',
            'e^(iθ) = cos θ - i sin θ',
            'e^(iθ) = sin θ + i cos θ',
            'e^(iθ) = sin θ - i cos θ'
          ],
          correctAnswer: 'e^(iθ) = cos θ + i sin θ',
        ),
        Question(
          questionText: 'What is the formula for the nth term of an arithmetic sequence?',
          options: [
            'aₙ = a₁ + (n-1)d',
            'aₙ = a₁rⁿ⁻¹',
            'aₙ = a₁ + nd',
            'aₙ = a₁rⁿ'
          ],
          correctAnswer: 'aₙ = a₁ + (n-1)d',
        ),
        Question(
          questionText: 'What is the sum of the first n terms of an arithmetic sequence?',
          options: [
            'Sₙ = n(a₁ + aₙ)/2',
            'Sₙ = n(a₁ + d)/2',
            'Sₙ = a₁(1-rⁿ)/(1-r)',
            'Sₙ = a₁/(1-r)'
          ],
          correctAnswer: 'Sₙ = n(a₁ + aₙ)/2',
        ),
        Question(
          questionText: 'What is the sum of the first n terms of a geometric sequence?',
          options: [
            'Sₙ = a₁(1-rⁿ)/(1-r)',
            'Sₙ = n(a₁ + aₙ)/2',
            'Sₙ = a₁/(1-r)',
            'Sₙ = a₁rⁿ⁻¹'
          ],
          correctAnswer: 'Sₙ = a₁(1-rⁿ)/(1-r)',
        ),
        Question(
          questionText: 'What is the binomial theorem?',
          options: [
            '(a + b)ⁿ = Σ(n choose k) × a^(n-k) × b^k',
            '(a + b)ⁿ = aⁿ + bⁿ',
            '(a + b)ⁿ = Σa^(n-k) × b^k',
            '(a + b)ⁿ = n(a + b)'
          ],
          correctAnswer: '(a + b)ⁿ = Σ(n choose k) × a^(n-k) × b^k',
        ),
        Question(
          questionText: 'What is the formula for (n choose k)?',
          options: [
            'n!/(k!(n-k)!)',
            'n!/(k!(n+k)!)',
            'k!/(n!(n-k)!)',
            'n!/(k!(k-n)!)'
          ],
          correctAnswer: 'n!/(k!(n-k)!)',
        ),
        Question(
          questionText: 'What is mathematical induction?',
          options: [
            'A method of mathematical proof that proves a statement for all natural numbers',
            'A method to find the derivative of a function',
            'A method to solve equations',
            'A method to find limits'
          ],
          correctAnswer: 'A method of mathematical proof that proves a statement for all natural numbers',
        ),
        Question(
          questionText: 'What is the principle of mathematical induction?',
          options: [
            'If a statement is true for n=1 and if it being true for n=k implies it is true for n=k+1, then it is true for all natural numbers',
            'If a statement is true for n=1, then it is true for all natural numbers',
            'If a statement is true for n=k, then it is true for n=k+1',
            'If a statement is true for some numbers, then it is true for all numbers'
          ],
          correctAnswer: 'If a statement is true for n=1 and if it being true for n=k implies it is true for n=k+1, then it is true for all natural numbers',
        ),
        Question(
          questionText: 'What is a vector in mathematics?',
          options: [
            'A quantity that has both magnitude and direction',
            'A quantity that has only magnitude',
            'A quantity that has only direction',
            'A quantity that has neither magnitude nor direction'
          ],
          correctAnswer: 'A quantity that has both magnitude and direction',
        ),
        Question(
          questionText: 'What is the dot product of two vectors?',
          options: [
            'A scalar quantity equal to the product of their magnitudes and the cosine of the angle between them',
            'A vector quantity perpendicular to both vectors',
            'The sum of their magnitudes',
            'The difference of their magnitudes'
          ],
          correctAnswer: 'A scalar quantity equal to the product of their magnitudes and the cosine of the angle between them',
        ),
        Question(
          questionText: 'What is the cross product of two vectors?',
          options: [
            'A vector quantity perpendicular to both vectors with magnitude equal to the product of their magnitudes and the sine of the angle between them',
            'A scalar quantity equal to the product of their magnitudes',
            'A vector quantity parallel to both vectors',
            'A scalar quantity equal to the sum of their magnitudes'
          ],
          correctAnswer: 'A vector quantity perpendicular to both vectors with magnitude equal to the product of their magnitudes and the sine of the angle between them',
        ),
        Question(
          questionText: 'What is a matrix?',
          options: [
            'A rectangular array of numbers, symbols, or expressions arranged in rows and columns',
            'A single number',
            'A vector',
            'A function'
          ],
          correctAnswer: 'A rectangular array of numbers, symbols, or expressions arranged in rows and columns',
        ),
        Question(
          questionText: 'What is the determinant of a 2x2 matrix?',
          options: [
            'ad - bc for matrix [[a,b],[c,d]]',
            'a + b + c + d for matrix [[a,b],[c,d]]',
            'ab + cd for matrix [[a,b],[c,d]]',
            'a - b - c - d for matrix [[a,b],[c,d]]'
          ],
          correctAnswer: 'ad - bc for matrix [[a,b],[c,d]]',
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
        Question(
          questionText: 'What is the formula for relativistic momentum?',
          options: ['p = γmv', 'p = mv', 'p = mc', 'p = h/λ'],
          correctAnswer: 'p = γmv',
        ),
        Question(
          questionText: 'What is the Lorentz factor γ?',
          options: [
            'γ = 1/√(1 - v²/c²)',
            'γ = 1/√(1 + v²/c²)',
            'γ = √(1 - v²/c²)',
            'γ = √(1 + v²/c²)'
          ],
          correctAnswer: 'γ = 1/√(1 - v²/c²)',
        ),
        Question(
          questionText: 'What is the formula for relativistic time dilation?',
          options: [
            'Δt = γΔt₀',
            'Δt = Δt₀/γ',
            'Δt = Δt₀ + γ',
            'Δt = Δt₀ - γ'
          ],
          correctAnswer: 'Δt = γΔt₀',
        ),
        Question(
          questionText: 'What is the formula for relativistic length contraction?',
          options: [
            'L = L₀/γ',
            'L = γL₀',
            'L = L₀ + γ',
            'L = L₀ - γ'
          ],
          correctAnswer: 'L = L₀/γ',
        ),
        Question(
          questionText: 'What is the photoelectric effect?',
          options: [
            'Emission of electrons when light shines on a metal surface',
            'Absorption of light by electrons',
            'Reflection of light from a metal surface',
            'Transmission of light through a metal'
          ],
          correctAnswer: 'Emission of electrons when light shines on a metal surface',
        ),
        Question(
          questionText: 'What is the work function?',
          options: [
            'The minimum energy required to remove an electron from a metal surface',
            'The energy of a photon',
            'The kinetic energy of an emitted electron',
            'The potential energy of an electron'
          ],
          correctAnswer: 'The minimum energy required to remove an electron from a metal surface',
        ),
        Question(
          questionText: 'What is the formula for the energy of a photon?',
          options: ['E = hf', 'E = mc²', 'E = 1/2mv²', 'E = pv'],
          correctAnswer: 'E = hf',
        ),
        Question(
          questionText: 'What is Planck\'s constant?',
          options: [
            'h = 6.626 × 10⁻³⁴ J·s',
            'h = 6.626 × 10⁻³⁴ m/s',
            'h = 6.626 × 10⁻³⁴ kg·m²/s',
            'h = 6.626 × 10⁻³⁴ N·m'
          ],
          correctAnswer: 'h = 6.626 × 10⁻³⁴ J·s',
        ),
        Question(
          questionText: 'What is the speed of light in vacuum?',
          options: [
            'c = 3.00 × 10⁸ m/s',
            'c = 3.00 × 10⁸ km/s',
            'c = 3.00 × 10⁵ m/s',
            'c = 3.00 × 10¹⁰ m/s'
          ],
          correctAnswer: 'c = 3.00 × 10⁸ m/s',
        ),
        Question(
          questionText: 'What is the formula for the kinetic energy of a relativistic particle?',
          options: [
            'KE = (γ - 1)mc²',
            'KE = γmc²',
            'KE = 1/2γmv²',
            'KE = mc²'
          ],
          correctAnswer: 'KE = (γ - 1)mc²',
        ),
        Question(
          questionText: 'What is the principle of superposition in quantum mechanics?',
          options: [
            'A quantum system can exist in multiple states simultaneously',
            'Quantum particles can only exist in one state at a time',
            'Quantum states are always definite',
            'Quantum particles cannot be in superposition'
          ],
          correctAnswer: 'A quantum system can exist in multiple states simultaneously',
        ),
        Question(
          questionText: 'What is the Schrödinger equation?',
          options: [
            'A fundamental equation describing how quantum systems evolve over time',
            'An equation for classical mechanics',
            'An equation for thermodynamics',
            'An equation for electromagnetism'
          ],
          correctAnswer: 'A fundamental equation describing how quantum systems evolve over time',
        ),
        Question(
          questionText: 'What is the Pauli exclusion principle?',
          options: [
            'No two identical fermions can occupy the same quantum state simultaneously',
            'All particles can occupy the same quantum state',
            'Only bosons can occupy the same quantum state',
            'Particles can share quantum states freely'
          ],
          correctAnswer: 'No two identical fermions can occupy the same quantum state simultaneously',
        ),
        Question(
          questionText: 'What is the formula for the Compton wavelength?',
          options: [
            'λ_c = h/(mc)',
            'λ_c = h/m',
            'λ_c = mc/h',
            'λ_c = hc/m'
          ],
          correctAnswer: 'λ_c = h/(mc)',
        ),
        Question(
          questionText: 'What is the uncertainty principle for energy and time?',
          options: [
            'ΔEΔt ≥ ℏ/2',
            'ΔEΔt ≤ ℏ/2',
            'ΔEΔt = ℏ/2',
            'ΔEΔt = 0'
          ],
          correctAnswer: 'ΔEΔt ≥ ℏ/2',
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
        Question(
          questionText: 'What is Markovnikov\'s rule?',
          options: [
            'In addition reactions, the hydrogen atom adds to the carbon with more hydrogen atoms',
            'In elimination reactions, the hydrogen atom is removed from the carbon with fewer hydrogen atoms',
            'In substitution reactions, the leaving group is replaced by the nucleophile',
            'In oxidation reactions, the most oxidized product is formed'
          ],
          correctAnswer: 'In addition reactions, the hydrogen atom adds to the carbon with more hydrogen atoms',
        ),
        Question(
          questionText: 'What is Zaitsev\'s rule?',
          options: [
            'In elimination reactions, the major product is the more substituted alkene',
            'In addition reactions, the major product is the more substituted alkane',
            'In substitution reactions, the major product is the more substituted compound',
            'In oxidation reactions, the major product is the most oxidized compound'
          ],
          correctAnswer: 'In elimination reactions, the major product is the more substituted alkene',
        ),
        Question(
          questionText: 'What is the difference between cis and trans isomers?',
          options: [
            'Cis has substituents on the same side, trans has substituents on opposite sides',
            'Cis has substituents on opposite sides, trans has substituents on the same side',
            'Cis is more stable than trans',
            'Cis is less stable than trans'
          ],
          correctAnswer: 'Cis has substituents on the same side, trans has substituents on opposite sides',
        ),
        Question(
          questionText: 'What is the difference between E and Z isomers?',
          options: [
            'E has higher priority groups on opposite sides, Z has higher priority groups on the same side',
            'E has higher priority groups on the same side, Z has higher priority groups on opposite sides',
            'E is more stable than Z',
            'E is less stable than Z'
          ],
          correctAnswer: 'E has higher priority groups on opposite sides, Z has higher priority groups on the same side',
        ),
        Question(
          questionText: 'What is the Cahn-Ingold-Prelog priority system?',
          options: [
            'A system for assigning priorities to substituents based on atomic number',
            'A system for naming organic compounds',
            'A system for determining reaction mechanisms',
            'A system for calculating molecular weights'
          ],
          correctAnswer: 'A system for assigning priorities to substituents based on atomic number',
        ),
        Question(
          questionText: 'What is the difference between a chiral and achiral molecule?',
          options: [
            'A chiral molecule is not superimposable on its mirror image, an achiral molecule is',
            'A chiral molecule is superimposable on its mirror image, an achiral molecule is not',
            'A chiral molecule has a plane of symmetry, an achiral molecule does not',
            'A chiral molecule has no plane of symmetry, an achiral molecule has one'
          ],
          correctAnswer: 'A chiral molecule is not superimposable on its mirror image, an achiral molecule is',
        ),
        Question(
          questionText: 'What is an enantiomer?',
          options: [
            'A pair of molecules that are non-superimposable mirror images of each other',
            'A pair of molecules that are identical',
            'A pair of molecules that are constitutional isomers',
            'A pair of molecules that are diastereomers'
          ],
          correctAnswer: 'A pair of molecules that are non-superimposable mirror images of each other',
        ),
        Question(
          questionText: 'What is a diastereomer?',
          options: [
            'Stereoisomers that are not mirror images of each other',
            'Stereoisomers that are mirror images of each other',
            'Constitutional isomers',
            'Identical molecules'
          ],
          correctAnswer: 'Stereoisomers that are not mirror images of each other',
        ),
        Question(
          questionText: 'What is optical activity?',
          options: [
            'The ability of a compound to rotate plane-polarized light',
            'The ability of a compound to absorb light',
            'The ability of a compound to emit light',
            'The ability of a compound to reflect light'
          ],
          correctAnswer: 'The ability of a compound to rotate plane-polarized light',
        ),
        Question(
          questionText: 'What is specific rotation?',
          options: [
            'The rotation of plane-polarized light per unit concentration and path length',
            'The total rotation of plane-polarized light',
            'The rotation of plane-polarized light per unit mass',
            'The rotation of plane-polarized light per unit volume'
          ],
          correctAnswer: 'The rotation of plane-polarized light per unit concentration and path length',
        ),
        Question(
          questionText: 'What is a racemic mixture?',
          options: [
            'A 1:1 mixture of enantiomers',
            'A mixture of diastereomers',
            'A mixture of constitutional isomers',
            'A pure enantiomer'
          ],
          correctAnswer: 'A 1:1 mixture of enantiomers',
        ),
        Question(
          questionText: 'What is the difference between a meso compound and a racemic mixture?',
          options: [
            'A meso compound is achiral despite having chiral centers, a racemic mixture contains equal amounts of enantiomers',
            'A meso compound is chiral, a racemic mixture is achiral',
            'A meso compound has no chiral centers, a racemic mixture has chiral centers',
            'A meso compound is optically active, a racemic mixture is not'
          ],
          correctAnswer: 'A meso compound is achiral despite having chiral centers, a racemic mixture contains equal amounts of enantiomers',
        ),
        Question(
          questionText: 'What is the difference between a Fischer projection and a Haworth projection?',
          options: [
            'Fischer projection shows linear structure, Haworth projection shows cyclic structure',
            'Fischer projection shows cyclic structure, Haworth projection shows linear structure',
            'Fischer projection is for carbohydrates only, Haworth projection is for all compounds',
            'Fischer projection is for all compounds, Haworth projection is for carbohydrates only'
          ],
          correctAnswer: 'Fischer projection shows linear structure, Haworth projection shows cyclic structure',
        ),
        Question(
          questionText: 'What is the difference between α and β anomers?',
          options: [
            'α has the OH group below the ring, β has the OH group above the ring',
            'α has the OH group above the ring, β has the OH group below the ring',
            'α is more stable than β',
            'α is less stable than β'
          ],
          correctAnswer: 'α has the OH group below the ring, β has the OH group above the ring',
        ),
        Question(
          questionText: 'What is the difference between a reducing and non-reducing sugar?',
          options: [
            'A reducing sugar has a free aldehyde or ketone group, a non-reducing sugar does not',
            'A reducing sugar has no free aldehyde or ketone group, a non-reducing sugar does',
            'A reducing sugar is always a monosaccharide, a non-reducing sugar is always a disaccharide',
            'A reducing sugar is always a disaccharide, a non-reducing sugar is always a monosaccharide'
          ],
          correctAnswer: 'A reducing sugar has a free aldehyde or ketone group, a non-reducing sugar does not',
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
        Question(
          questionText: 'What is encapsulation in Java?',
          options: [
            'The bundling of data and methods that operate on that data within a single unit',
            'The process of creating multiple instances of a class',
            'The technique of hiding implementation details',
            'The method of organizing code into packages'
          ],
          correctAnswer: 'The bundling of data and methods that operate on that data within a single unit',
        ),
        Question(
          questionText: 'What is abstraction in Java?',
          options: [
            'The process of hiding complex implementation details and showing only necessary features',
            'The process of creating multiple instances of a class',
            'The technique of bundling data and methods',
            'The method of organizing code into packages'
          ],
          correctAnswer: 'The process of hiding complex implementation details and showing only necessary features',
        ),
        Question(
          questionText: 'What is method overriding in Java?',
          options: [
            'Providing a specific implementation of a method in a subclass that is already defined in the parent class',
            'Creating a new method with the same name in the same class',
            'Calling a method from another class',
            'Defining a method in an interface'
          ],
          correctAnswer: 'Providing a specific implementation of a method in a subclass that is already defined in the parent class',
        ),
        Question(
          questionText: 'What is method overloading in Java?',
          options: [
            'Having multiple methods with the same name but different parameters in the same class',
            'Providing a specific implementation of a method in a subclass',
            'Calling a method from another class',
            'Defining a method in an interface'
          ],
          correctAnswer: 'Having multiple methods with the same name but different parameters in the same class',
        ),
        Question(
          questionText: 'What is a constructor in Java?',
          options: [
            'A special method that is called when an object is created',
            'A method that returns a value',
            'A method that takes parameters',
            'A method that is called when an object is destroyed'
          ],
          correctAnswer: 'A special method that is called when an object is created',
        ),
        Question(
          questionText: 'What is the difference between public, private, and protected access modifiers?',
          options: [
            'Public: accessible everywhere, Private: accessible only within the class, Protected: accessible within package and subclasses',
            'Public: accessible only within the class, Private: accessible everywhere, Protected: accessible within package only',
            'Public: accessible within package only, Private: accessible everywhere, Protected: accessible within class only',
            'Public: accessible within class only, Private: accessible within package, Protected: accessible everywhere'
          ],
          correctAnswer: 'Public: accessible everywhere, Private: accessible only within the class, Protected: accessible within package and subclasses',
        ),
        Question(
          questionText: 'What is a static method in Java?',
          options: [
            'A method that belongs to the class rather than an instance of the class',
            'A method that cannot be overridden',
            'A method that is called automatically',
            'A method that returns a static value'
          ],
          correctAnswer: 'A method that belongs to the class rather than an instance of the class',
        ),
        Question(
          questionText: 'What is the difference between a primitive type and a reference type in Java?',
          options: [
            'Primitive types store values directly, reference types store references to objects',
            'Primitive types are objects, reference types are not',
            'Primitive types can be null, reference types cannot',
            'Primitive types are always larger than reference types'
          ],
          correctAnswer: 'Primitive types store values directly, reference types store references to objects',
        ),
        Question(
          questionText: 'What is the difference between a HashMap and a TreeMap?',
          options: [
            'HashMap has O(1) average time complexity, TreeMap maintains sorted order with O(log n) operations',
            'HashMap maintains sorted order, TreeMap has O(1) average time complexity',
            'HashMap can only store strings, TreeMap can store any type',
            'HashMap is slower than TreeMap'
          ],
          correctAnswer: 'HashMap has O(1) average time complexity, TreeMap maintains sorted order with O(log n) operations',
        ),
        Question(
          questionText: 'What is the difference between a HashSet and a TreeSet?',
          options: [
            'HashSet has O(1) average time complexity, TreeSet maintains sorted order with O(log n) operations',
            'HashSet maintains sorted order, TreeSet has O(1) average time complexity',
            'HashSet can only store integers, TreeSet can store any type',
            'HashSet is slower than TreeSet'
          ],
          correctAnswer: 'HashSet has O(1) average time complexity, TreeSet maintains sorted order with O(log n) operations',
        ),
        Question(
          questionText: 'What is the difference between checked and unchecked exceptions?',
          options: [
            'Checked exceptions must be handled or declared, unchecked exceptions do not',
            'Checked exceptions are runtime exceptions, unchecked exceptions are compile-time exceptions',
            'Checked exceptions are always fatal, unchecked exceptions are not',
            'Checked exceptions can be ignored, unchecked exceptions cannot'
          ],
          correctAnswer: 'Checked exceptions must be handled or declared, unchecked exceptions do not',
        ),
        Question(
          questionText: 'What is the difference between a final class and a final method?',
          options: [
            'Final class cannot be inherited, final method cannot be overridden',
            'Final class cannot be overridden, final method cannot be inherited',
            'Final class is immutable, final method is static',
            'Final class is abstract, final method is concrete'
          ],
          correctAnswer: 'Final class cannot be inherited, final method cannot be overridden',
        ),
        Question(
          questionText: 'What is the difference between an abstract class and an interface?',
          options: [
            'Abstract class can have constructors and instance variables, interface cannot',
            'Interface can have constructors and instance variables, abstract class cannot',
            'Abstract class can only have abstract methods, interface can have concrete methods',
            'Interface can only have static methods, abstract class can have instance methods'
          ],
          correctAnswer: 'Abstract class can have constructors and instance variables, interface cannot',
        ),
        Question(
          questionText: 'What is the difference between a shallow copy and a deep copy?',
          options: [
            'Shallow copy copies references, deep copy copies the actual objects',
            'Shallow copy copies the actual objects, deep copy copies references',
            'Shallow copy is faster, deep copy is slower',
            'Shallow copy is for primitives, deep copy is for objects'
          ],
          correctAnswer: 'Shallow copy copies references, deep copy copies the actual objects',
        ),
        Question(
          questionText: 'What is the difference between a StringBuilder and a String?',
          options: [
            'StringBuilder is mutable, String is immutable',
            'StringBuilder is immutable, String is mutable',
            'StringBuilder is faster for concatenation, String is slower',
            'StringBuilder can only store characters, String can store any type'
          ],
          correctAnswer: 'StringBuilder is mutable, String is immutable',
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
        Question(
          questionText: 'What is computational thinking?',
          options: [
            'A problem-solving process that includes decomposition, pattern recognition, abstraction, and algorithm design',
            'A way to write computer programs',
            'A method to debug code',
            'A technique to optimize algorithms'
          ],
          correctAnswer: 'A problem-solving process that includes decomposition, pattern recognition, abstraction, and algorithm design',
        ),
        Question(
          questionText: 'What is decomposition in computational thinking?',
          options: [
            'Breaking down a complex problem into smaller, manageable parts',
            'Combining multiple solutions into one',
            'Analyzing the efficiency of an algorithm',
            'Testing a program for bugs'
          ],
          correctAnswer: 'Breaking down a complex problem into smaller, manageable parts',
        ),
        Question(
          questionText: 'What is pattern recognition in computational thinking?',
          options: [
            'Identifying similarities and differences in problems to make connections',
            'Finding bugs in code',
            'Optimizing algorithm performance',
            'Writing documentation'
          ],
          correctAnswer: 'Identifying similarities and differences in problems to make connections',
        ),
        Question(
          questionText: 'What is the difference between the internet and the World Wide Web?',
          options: [
            'The internet is the infrastructure, the World Wide Web is a service that runs on it',
            'The World Wide Web is the infrastructure, the internet is a service that runs on it',
            'They are exactly the same thing',
            'The internet is for email, the World Wide Web is for websites'
          ],
          correctAnswer: 'The internet is the infrastructure, the World Wide Web is a service that runs on it',
        ),
        Question(
          questionText: 'What is the purpose of DNS (Domain Name System)?',
          options: [
            'To translate domain names into IP addresses',
            'To encrypt internet traffic',
            'To store website data',
            'To create secure connections'
          ],
          correctAnswer: 'To translate domain names into IP addresses',
        ),
        Question(
          questionText: 'What is the difference between symmetric and asymmetric encryption?',
          options: [
            'Symmetric uses the same key for encryption and decryption, asymmetric uses different keys',
            'Symmetric uses different keys for encryption and decryption, asymmetric uses the same key',
            'Symmetric is faster, asymmetric is slower',
            'Symmetric is for text, asymmetric is for images'
          ],
          correctAnswer: 'Symmetric uses the same key for encryption and decryption, asymmetric uses different keys',
        ),
        Question(
          questionText: 'What is the purpose of a digital certificate?',
          options: [
            'To verify the identity of a website or organization',
            'To encrypt data transmission',
            'To store user passwords',
            'To speed up website loading'
          ],
          correctAnswer: 'To verify the identity of a website or organization',
        ),
        Question(
          questionText: 'What is the difference between lossy and lossless compression?',
          options: [
            'Lossy compression permanently removes data, lossless compression preserves all data',
            'Lossless compression permanently removes data, lossy compression preserves all data',
            'Lossy compression is faster, lossless compression is slower',
            'Lossy compression is for images, lossless compression is for text'
          ],
          correctAnswer: 'Lossy compression permanently removes data, lossless compression preserves all data',
        ),
        Question(
          questionText: 'What is the purpose of a database?',
          options: [
            'To store and organize large amounts of data efficiently',
            'To create websites',
            'To encrypt information',
            'To connect to the internet'
          ],
          correctAnswer: 'To store and organize large amounts of data efficiently',
        ),
        Question(
          questionText: 'What is the difference between a relational and non-relational database?',
          options: [
            'Relational databases use tables with relationships, non-relational databases use other structures',
            'Non-relational databases use tables with relationships, relational databases use other structures',
            'Relational databases are faster, non-relational databases are slower',
            'Relational databases are for small data, non-relational databases are for large data'
          ],
          correctAnswer: 'Relational databases use tables with relationships, non-relational databases use other structures',
        ),
        Question(
          questionText: 'What is the purpose of an API (Application Programming Interface)?',
          options: [
            'To allow different software applications to communicate with each other',
            'To create user interfaces',
            'To store data',
            'To encrypt information'
          ],
          correctAnswer: 'To allow different software applications to communicate with each other',
        ),
        Question(
          questionText: 'What is the difference between open source and proprietary software?',
          options: [
            'Open source code is publicly available, proprietary code is privately owned',
            'Proprietary code is publicly available, open source code is privately owned',
            'Open source software is free, proprietary software costs money',
            'Open source software is slower, proprietary software is faster'
          ],
          correctAnswer: 'Open source code is publicly available, proprietary code is privately owned',
        ),
        Question(
          questionText: 'What is the purpose of version control?',
          options: [
            'To track changes to code and collaborate with others',
            'To encrypt source code',
            'To optimize program performance',
            'To create backups'
          ],
          correctAnswer: 'To track changes to code and collaborate with others',
        ),
        Question(
          questionText: 'What is the difference between a client and a server?',
          options: [
            'A client requests services, a server provides services',
            'A server requests services, a client provides services',
            'A client is always a computer, a server is always a program',
            'A client is always a program, a server is always a computer'
          ],
          correctAnswer: 'A client requests services, a server provides services',
        ),
        Question(
          questionText: 'What is the purpose of a cache?',
          options: [
            'To store frequently accessed data for faster retrieval',
            'To encrypt data',
            'To compress files',
            'To create backups'
          ],
          correctAnswer: 'To store frequently accessed data for faster retrieval',
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
        Question(
          questionText: 'What is the carbon cycle?',
          options: [
            'The movement of carbon through the Earth\'s systems',
            'The process of photosynthesis',
            'The burning of fossil fuels',
            'The formation of carbon dioxide'
          ],
          correctAnswer: 'The movement of carbon through the Earth\'s systems',
        ),
        Question(
          questionText: 'What is the nitrogen cycle?',
          options: [
            'The movement of nitrogen through the Earth\'s systems',
            'The process of nitrogen fixation',
            'The formation of nitrates',
            'The decomposition of organic matter'
          ],
          correctAnswer: 'The movement of nitrogen through the Earth\'s systems',
        ),
        Question(
          questionText: 'What is the water cycle?',
          options: [
            'The continuous movement of water on, above, and below the Earth\'s surface',
            'The process of evaporation',
            'The formation of clouds',
            'The flow of rivers'
          ],
          correctAnswer: 'The continuous movement of water on, above, and below the Earth\'s surface',
        ),
        Question(
          questionText: 'What is the phosphorus cycle?',
          options: [
            'The movement of phosphorus through the Earth\'s systems',
            'The process of phosphate formation',
            'The weathering of rocks',
            'The uptake by plants'
          ],
          correctAnswer: 'The movement of phosphorus through the Earth\'s systems',
        ),
        Question(
          questionText: 'What is the sulfur cycle?',
          options: [
            'The movement of sulfur through the Earth\'s systems',
            'The formation of sulfuric acid',
            'The burning of fossil fuels',
            'The weathering of rocks'
          ],
          correctAnswer: 'The movement of sulfur through the Earth\'s systems',
        ),
        Question(
          questionText: 'What is acid rain?',
          options: [
            'Rain with a pH below 5.6 due to atmospheric pollution',
            'Rain with high mineral content',
            'Rain during thunderstorms',
            'Rain in polluted areas'
          ],
          correctAnswer: 'Rain with a pH below 5.6 due to atmospheric pollution',
        ),
        Question(
          questionText: 'What is ozone depletion?',
          options: [
            'The thinning of the ozone layer in the stratosphere',
            'The formation of ozone at ground level',
            'The increase in ozone concentration',
            'The movement of ozone molecules'
          ],
          correctAnswer: 'The thinning of the ozone layer in the stratosphere',
        ),
        Question(
          questionText: 'What is eutrophication?',
          options: [
            'The excessive growth of algae due to nutrient enrichment',
            'The natural aging of lakes',
            'The formation of oxygen in water',
            'The process of water purification'
          ],
          correctAnswer: 'The excessive growth of algae due to nutrient enrichment',
        ),
        Question(
          questionText: 'What is biomagnification?',
          options: [
            'The increase in concentration of toxins as they move up the food chain',
            'The magnification of biological organisms',
            'The increase in population size',
            'The growth of microorganisms'
          ],
          correctAnswer: 'The increase in concentration of toxins as they move up the food chain',
        ),
        Question(
          questionText: 'What is habitat fragmentation?',
          options: [
            'The breaking up of large habitats into smaller, isolated patches',
            'The destruction of all habitats',
            'The creation of new habitats',
            'The movement of species between habitats'
          ],
          correctAnswer: 'The breaking up of large habitats into smaller, isolated patches',
        ),
        Question(
          questionText: 'What is invasive species?',
          options: [
            'Non-native species that cause harm to the environment',
            'All non-native species',
            'Species that are endangered',
            'Species that are beneficial to the environment'
          ],
          correctAnswer: 'Non-native species that cause harm to the environment',
        ),
        Question(
          questionText: 'What is the tragedy of the commons?',
          options: [
            'The overuse of shared resources due to individual self-interest',
            'The sharing of resources among communities',
            'The conservation of natural resources',
            'The management of public lands'
          ],
          correctAnswer: 'The overuse of shared resources due to individual self-interest',
        ),
        Question(
          questionText: 'What is carrying capacity?',
          options: [
            'The maximum population size an environment can sustain',
            'The current population size',
            'The minimum population size needed for survival',
            'The rate of population growth'
          ],
          correctAnswer: 'The maximum population size an environment can sustain',
        ),
        Question(
          questionText: 'What is ecological footprint?',
          options: [
            'The amount of land and resources needed to support a population',
            'The size of an organism\'s feet',
            'The area of land used for agriculture',
            'The amount of waste produced'
          ],
          correctAnswer: 'The amount of land and resources needed to support a population',
        ),
        Question(
          questionText: 'What is renewable energy?',
          options: [
            'Energy from sources that are naturally replenished',
            'Energy that is free',
            'Energy that is clean',
            'Energy that is efficient'
          ],
          correctAnswer: 'Energy from sources that are naturally replenished',
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
      final normalized = name.trim().toLowerCase();
      return _premadeSets.firstWhere(
        (set) => set.name.trim().toLowerCase() == normalized,
      );
    } catch (e) {
      debugPrint('Error finding premade set: $e');
      return null;
    }
  }
}