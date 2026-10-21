import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/scanner_finding_model.dart';
import '../models/scanner_report_model.dart';

class InternshipAnalysisService {
  static const Uuid _uuid = Uuid();

  /// Analyzes pasted job description text or extracted document text
  Future<ScannerReportModel> analyzeText({
    required String text,
    String? documentName,
    ScannerInputType submissionType = ScannerInputType.text,
    String? studentId,
  }) async {
    // Artificial small delay to allow natural UI rendering and avoid flickering
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanText = text.trim();
    final lowerText = cleanText.toLowerCase();

    // If input is extremely short (< 40 characters), mark as insufficient information
    if (cleanText.length < 40) {
      return ScannerReportModel(
        id: _uuid.v4(),
        studentId: studentId,
        submissionType: submissionType,
        rawInput: cleanText,
        documentName: documentName,
        assessmentCategory: AssessmentCategory.insufficientInformation,
        assessmentHeadline: 'Insufficient information to assess',
        overallExplanation:
            'The submitted information is too short to reliably evaluate risk factors or verify employer details.',
        findings: [
          ScannerFindingModel(
            id: _uuid.v4(),
            title: 'Very brief submission',
            type: FindingType.unknownInconclusive,
            severity: FindingSeverity.low,
            explanation:
                'Only a few words or lines were provided. Legitimate internship listings typically provide detailed role descriptions, eligibility criteria, and official contact channels.',
            evidence: cleanText.length > 80 ? '${cleanText.substring(0, 80)}...' : cleanText,
            suggestedAction:
                'Paste the complete job post, including company name, stipend, requirements, and application instructions.',
            ruleName: 'MINIMUM_LENGTH_CHECK',
          ),
        ],
        recommendedNextSteps: [
          'Request a formal written job description or offer letter from the recruiter.',
          'Ask for the official corporate website and verifiable company email address.',
          'Rescan the internship once you obtain the comprehensive job description.',
        ],
        analysisMethod: 'Rule-based heuristic scanner v1.0 - Preliminary automated assessment',
        createdAt: DateTime.now(),
        limitations:
            'Text length (${cleanText.length} characters) is below the minimum threshold required for structural risk pattern detection.',
      );
    }

    final findings = <ScannerFindingModel>[];

    // 1. Upfront Payment / Fee Checks (High Risk)
    _checkUpfrontPayment(cleanText, lowerText, findings);

    // 2. Sensitive Personal Data / Financial Details Request (High Risk)
    _checkSensitiveInformation(cleanText, lowerText, findings);

    // 3. Pressure Tactics & Urgency (Medium Risk)
    _checkUrgencyAndPressure(cleanText, lowerText, findings);

    // 4. Guaranteed Selection / Unrealistic Promises (Medium/High Risk)
    _checkUnrealisticPromises(cleanText, lowerText, findings);

    // 5. Contact Channels & Free Email Recruiter (Medium Risk)
    _checkContactChannels(cleanText, lowerText, findings);

    // 6. Company Identity & Registration Transparency (Info/Medium Risk)
    _checkCompanyIdentity(cleanText, lowerText, findings);

    // 7. Job Responsibilities & Requirements (Positive or Inconclusive)
    _checkResponsibilities(cleanText, lowerText, findings);

    // Categorize overall assessment based on findings
    final hasHighRisk = findings.any((f) => f.type == FindingType.warning && f.severity == FindingSeverity.high);
    final hasMediumRisk = findings.any((f) => f.type == FindingType.warning && f.severity == FindingSeverity.medium);
    final hasAnyWarning = findings.any((f) => f.type == FindingType.warning);

    final AssessmentCategory category;
    final String headline;
    final String overallExplanation;

    if (hasHighRisk) {
      category = AssessmentCategory.redFlagsDetected;
      headline = 'Significant warning signs detected';
      overallExplanation =
          'This automated assessment detected serious warning signs commonly associated with deceptive or non-standard internship offers. Exercise extreme caution.';
    } else if (hasMediumRisk || hasAnyWarning) {
      category = AssessmentCategory.furtherVerificationRecommended;
      headline = 'Further verification recommended';
      overallExplanation =
          'This assessment identifies warning signs or ambiguous details. It does not establish that the offer is fraudulent, but independent verification is strongly advised before proceeding.';
    } else if (cleanText.length > 120) {
      category = AssessmentCategory.noObviousWarningSigns;
      headline = 'No obvious warning signs detected';
      overallExplanation =
          'Based on the provided text, no recognized scam patterns or payment demands were found. Note: static analysis cannot guarantee employer legitimacy. Always verify through official channels.';
    } else {
      category = AssessmentCategory.insufficientInformation;
      headline = 'Limited details available';
      overallExplanation =
          'The provided text did not trigger specific red flags, but contained limited structural information. Confirm all terms directly with the organization.';
    }

    final recommendedSteps = _generateRecommendedSteps(category, findings);

    return ScannerReportModel(
      id: _uuid.v4(),
      studentId: studentId,
      submissionType: submissionType,
      rawInput: cleanText,
      documentName: documentName,
      assessmentCategory: category,
      assessmentHeadline: headline,
      overallExplanation: overallExplanation,
      findings: findings,
      recommendedNextSteps: recommendedSteps,
      analysisMethod: 'Rule-based heuristic scanner v1.0 - Preliminary automated assessment',
      createdAt: DateTime.now(),
      limitations:
          'Automated rule-based heuristic check. This tool does not perform criminal background investigations or independently inspect corporate bank accounts.',
    );
  }

  /// Analyzes a submitted internship URL
  Future<ScannerReportModel> analyzeUrl({
    required String rawUrl,
    String? studentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final trimmedUrl = rawUrl.trim();
    final uri = Uri.tryParse(trimmedUrl);

    if (uri == null || (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://'))) {
      return ScannerReportModel(
        id: _uuid.v4(),
        studentId: studentId,
        submissionType: ScannerInputType.url,
        rawInput: trimmedUrl,
        assessmentCategory: AssessmentCategory.insufficientInformation,
        assessmentHeadline: 'Invalid or unsupported URL',
        overallExplanation:
            'The URL provided could not be parsed as a valid web link. Please ensure it starts with https:// or http://.',
        findings: [
          ScannerFindingModel(
            id: _uuid.v4(),
            title: 'Malformed URL format',
            type: FindingType.unknownInconclusive,
            severity: FindingSeverity.low,
            explanation: 'The entered link does not match standard web address conventions.',
            evidence: trimmedUrl,
            suggestedAction: 'Double-check the web address copied from your browser and try again.',
            ruleName: 'URL_SYNTAX_VALIDATOR',
          ),
        ],
        recommendedNextSteps: [
          'Ensure the URL begins with https://',
          'Alternatively, copy and paste the full job description text into the Job Description tab for a deep scan.',
        ],
        analysisMethod: 'URL structural assessment v1.0 - Preliminary automated assessment',
        createdAt: DateTime.now(),
        limitations: 'Malformed web link; domain analysis could not proceed.',
      );
    }

    final findings = <ScannerFindingModel>[];
    final host = uri.host.toLowerCase();
    final isHttps = uri.isScheme('https');

    // Check 1: HTTPS protocol check
    if (!isHttps) {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Unencrypted HTTP protocol used',
          type: FindingType.warning,
          severity: FindingSeverity.medium,
          explanation:
              'The website does not use HTTPS encryption. Legitimate corporate recruiting and application portals use HTTPS to protect your privacy.',
          evidence: 'Scheme: ${uri.scheme}://${uri.host}',
          suggestedAction: 'Avoid entering any personal information, resumes, or login credentials on unencrypted sites.',
          ruleName: 'URL_HTTPS_CHECK',
        ),
      );
    } else {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Secure HTTPS protocol detected',
          type: FindingType.verifiedFact,
          severity: FindingSeverity.info,
          explanation:
              'The link uses encrypted transport (HTTPS). While HTTPS secures the connection, it does not guarantee that the content on the website is genuine.',
          evidence: uri.toString(),
          suggestedAction: 'Verify that the domain matches the official corporate identity.',
          ruleName: 'URL_HTTPS_CHECK',
        ),
      );
    }

    // Check 2: Suspicious Top-Level Domains or Free Hosting Platforms
    final suspiciousTlds = ['.xyz', '.top', '.tk', '.ga', '.cf', '.gq', '.ml', '.work', '.click', '.buzz'];
    final matchedTld = suspiciousTlds.firstWhere((tld) => host.endsWith(tld), orElse: () => '');
    if (matchedTld.isNotEmpty) {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Uncommon or high-risk domain extension ($matchedTld)',
          type: FindingType.warning,
          severity: FindingSeverity.medium,
          explanation:
              'The domain uses a high-churn or discount top-level domain ($matchedTld) frequently leveraged by temporary scam portals rather than reputable commercial entities.',
          evidence: 'Domain host: $host',
          suggestedAction: 'Verify whether the parent company actually maintains this domain or if an official .com / .in / .org domain exists.',
          ruleName: 'SUSPICIOUS_TLD_CHECK',
        ),
      );
    }

    // Check 3: Free blog/site builders or form links
    final freeHosters = ['forms.gle', 'docs.google.com', 'typeform.com', 'notion.site', 'wixsite.com', 'weebly.com', 'blogspot.com', 'wordpress.com'];
    final matchedHoster = freeHosters.firstWhere((fh) => host.contains(fh), orElse: () => '');
    if (matchedHoster.isNotEmpty) {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Hosted on a free public form or site builder ($matchedHoster)',
          type: FindingType.warning,
          severity: FindingSeverity.medium,
          explanation:
              'The internship link points to an open public form or free site ($matchedHoster). While small startups occasionally use Google Forms, large companies and legitimate employers use dedicated applicant tracking systems (ATS).',
          evidence: uri.toString(),
          suggestedAction: 'Cross-reference this application form with the company’s official LinkedIn page or careers portal.',
          ruleName: 'FREE_HOSTING_CHECK',
        ),
      );
    }

    // Check 4: Known Trusted Job Boards (Informational)
    final trustedPlatforms = ['linkedin.com', 'internshala.com', 'naukri.com', 'indeed.com', 'wellfound.com', 'unstop.com', 'glassdoor.com'];
    final matchedPlatform = trustedPlatforms.firstWhere((p) => host.contains(p), orElse: () => '');
    if (matchedPlatform.isNotEmpty) {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Listed on known job platform ($matchedPlatform)',
          type: FindingType.info,
          severity: FindingSeverity.info,
          explanation:
              'The link is hosted on a recognized employment marketplace ($matchedPlatform). While these platforms enforce basic filters, fraudulent employers can still occasionally post listings before being banned.',
          evidence: uri.host,
          suggestedAction: 'Copy the job description text and analyze it using the Job Description tab for detailed content vetting.',
          ruleName: 'TRUSTED_PORTAL_OBSERVATION',
        ),
      );
    }

    // Check 5: URL shorteners
    final shorteners = ['bit.ly', 'tinyurl.com', 'cutt.ly', 'rb.gy', 't.co', 'is.gd'];
    if (shorteners.any((s) => host == s || host.endsWith('.$s'))) {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Shortened or masked URL detected',
          type: FindingType.warning,
          severity: FindingSeverity.medium,
          explanation:
              'The link uses an anonymized URL shortener ($host), concealing the actual destination domain until clicked.',
          evidence: uri.toString(),
          suggestedAction: 'Do not click shortened links from unknown recruiters. Inspect the expanded URL before visiting.',
          ruleName: 'URL_SHORTENER_CHECK',
        ),
      );
    }

    // Determine category
    final hasWarnings = findings.any((f) => f.type == FindingType.warning);
    final AssessmentCategory category = hasWarnings
        ? AssessmentCategory.furtherVerificationRecommended
        : AssessmentCategory.furtherVerificationRecommended;

    final recommendedSteps = [
      'Copy the full job description text and run a scan under the "Job Description" tab for in-depth lexical checks.',
      'Check if the official website has an active SSL certificate matching the corporate name.',
      'Confirm the job opening on the company’s verified LinkedIn page or official /careers page.',
    ];

    return ScannerReportModel(
      id: _uuid.v4(),
      studentId: studentId,
      submissionType: ScannerInputType.url,
      rawInput: trimmedUrl,
      assessmentCategory: category,
      assessmentHeadline: hasWarnings ? 'Link requires further verification' : 'URL analyzed - Content scan advised',
      overallExplanation:
          'Static URL inspection analyzed the protocol, domain structure, and platform type. Client-side scanners cannot safely bypass logins, cookies, or dynamic content behind external websites. Paste the job post text directly for comprehensive evaluation.',
      findings: findings,
      recommendedNextSteps: recommendedSteps,
      analysisMethod: 'URL structural assessment v1.0 - Preliminary automated assessment',
      createdAt: DateTime.now(),
      limitations:
          'URL assessment does not spider dynamic web content behind login walls, CAPTCHAs, or client-rendered single page applications.',
    );
  }

  // ==========================================
  // HELPER DETECTION RULES
  // ==========================================

  void _checkUpfrontPayment(String text, String lower, List<ScannerFindingModel> findings) {
    // Contextual patterns indicating fees requested from applicants
    final feePatterns = [
      RegExp(r'(registration|processing|application|training|document|security|onboarding|interview)\s+(fee|charge|cost|deposit|payment|amount)', caseSensitive: false),
      RegExp(r'(pay|deposit|transfer|send)\s+(rs\.?|inr|₹|\$)\s*\d+', caseSensitive: false),
      RegExp(r'(refundable|non-refundable)\s+(deposit|security|fee|charge)', caseSensitive: false),
      RegExp(r'(candidate|applicant|student)\s+must\s+(pay|deposit|submit)\s+(a|the)?\s*(fee|amount|charge)?', caseSensitive: false),
      RegExp(r'(gpay|phonepe|paytm|upi\s*id|qr\s*code|bank\s*transfer)\s+for\s+(registration|confirmation|seat|slot)', caseSensitive: false),
    ];

    // Negative exceptions: e.g. "no fee", "zero registration fee", "free of cost", "we do not charge"
    final negativePhrases = [
      'no registration fee',
      'no fee',
      'without any fee',
      'free of cost',
      'no charge',
      'we do not charge',
      'never ask for money',
      'no deposit',
      'free internship',
    ];

    for (final pattern in feePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final matchedExcerpt = match.group(0)!;
        final snippet = _extractSentence(text, match.start, match.end);

        // Check if the snippet contains an explicit negative exception
        final isNegative = negativePhrases.any((neg) => snippet.toLowerCase().contains(neg));
        if (!isNegative) {
          findings.add(
            ScannerFindingModel(
              id: _uuid.v4(),
              title: 'Upfront payment requested',
              type: FindingType.warning,
              severity: FindingSeverity.high,
              explanation:
                  'The offer asks for an upfront fee, deposit, or payment. Legitimate internships pay stipends to students and never charge fees for training, registration, or placement.',
              evidence: snippet.isNotEmpty ? snippet : matchedExcerpt,
              suggestedAction:
                  'Do not pay any requested fee under any circumstances until you have thoroughly checked the opportunity and independently confirmed the employer\'s identity through official channels.',
              ruleName: 'UPFRONT_PAYMENT_DETECTION',
            ),
          );
          break; // Avoid duplicate fee findings
        }
      }
    }
  }

  void _checkSensitiveInformation(String text, String lower, List<ScannerFindingModel> findings) {
    final sensitivePatterns = [
      RegExp(r'(send|submit|share)\s+(your\s+)?(bank\s+account|debit\s+card|credit\s+card|cvv|atm\s+pin|netbanking|otp)', caseSensitive: false),
      RegExp(r'(original|blank)\s+(cheque|check|documents|certificates)', caseSensitive: false),
      RegExp(r'(aadhaar|pan\s*card|passport)\s+otp', caseSensitive: false),
    ];

    for (final pattern in sensitivePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final snippet = _extractSentence(text, match.start, match.end);
        findings.add(
          ScannerFindingModel(
            id: _uuid.v4(),
            title: 'Request for sensitive financial or identification data',
            type: FindingType.warning,
            severity: FindingSeverity.high,
            explanation:
                'The posting asks for sensitive banking details, card numbers, or OTP credentials upfront. Real companies only request standard payroll information after an official contract is signed.',
            evidence: snippet,
            suggestedAction: 'Never share OTPs, PINs, card numbers, or blank cheques with prospective recruiters.',
            ruleName: 'SENSITIVE_DATA_DETECTION',
          ),
        );
        break;
      }
    }
  }

  void _checkUrgencyAndPressure(String text, String lower, List<ScannerFindingModel> findings) {
    final pressurePatterns = [
      RegExp(r'(hurry|limited\s+slots?|only\s+\d+\s+seats?\s+left|urgent\s+hiring\s+today|offer\s+expires\s+in\s+\d+\s+hours?)', caseSensitive: false),
      RegExp(r'(pay\s+within|confirm\s+within)\s+\d+\s+(hours?|mins?|minutes?)', caseSensitive: false),
      RegExp(r'immediate\s+joining\s+mandatory\s+today', caseSensitive: false),
    ];

    for (final pattern in pressurePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final snippet = _extractSentence(text, match.start, match.end);
        findings.add(
          ScannerFindingModel(
            id: _uuid.v4(),
            title: 'High-pressure urgency tactics detected',
            type: FindingType.warning,
            severity: FindingSeverity.medium,
            explanation:
                'The offer uses high-pressure artificial urgency (e.g. limited slots, expiring in hours). Scammers frequently use manufactured deadlines to rush victims into paying fees without due diligence.',
            evidence: snippet,
            suggestedAction: 'Take your time to thoroughly research the company. Do not let artificial countdowns dictate your decisions.',
            ruleName: 'PRESSURE_TACTIC_DETECTION',
          ),
        );
        break;
      }
    }
  }

  void _checkUnrealisticPromises(String text, String lower, List<ScannerFindingModel> findings) {
    final promisePatterns = [
      RegExp(r'(100%|guaranteed)\s+(selection|placement|job|hiring)', caseSensitive: false),
      RegExp(r'(no\s+interview|direct\s+selection|without\s+any\s+test\s+or\s+interview)', caseSensitive: false),
      RegExp(r'earn\s+(up\s+to\s+)?(rs\.?|inr|₹|\$)\s*[5-9]\d{4,}\s*(per\s+day|daily|weekly)', caseSensitive: false),
      RegExp(r'(simple\s+copy\s+paste|data\s+entry\s+earn\s+huge|part\s*time\s*sms\s*sending)', caseSensitive: false),
    ];

    for (final pattern in promisePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final snippet = _extractSentence(text, match.start, match.end);
        findings.add(
          ScannerFindingModel(
            id: _uuid.v4(),
            title: 'Guaranteed selection or disproportionate compensation claims',
            type: FindingType.warning,
            severity: FindingSeverity.medium,
            explanation:
                'The post promises guaranteed placement without technical evaluation, or advertises an abnormally high stipend for generic entry-level tasks.',
            evidence: snippet,
            suggestedAction: 'Be skeptical of promises that seem too good to be true. Legitimate internships require skills assessment.',
            ruleName: 'UNREALISTIC_PROMISES_DETECTION',
          ),
        );
        break;
      }
    }
  }

  void _checkContactChannels(String text, String lower, List<ScannerFindingModel> findings) {
    // Check for exclusively informal chat contact (Telegram / WhatsApp only)
    final chatOnlyPatterns = [
      RegExp(r'(dm\s+on\s+telegram|contact\s+(only\s+)?on\s+whatsapp|whatsapp\s+us\s+at\s+\+?\d+)', caseSensitive: false),
      RegExp(r't\.me\/[a-zA-Z0-9_]+', caseSensitive: false),
    ];

    for (final pattern in chatOnlyPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final snippet = _extractSentence(text, match.start, match.end);
        findings.add(
          ScannerFindingModel(
            id: _uuid.v4(),
            title: 'Exclusive messaging app recruitment channel',
            type: FindingType.warning,
            severity: FindingSeverity.medium,
            explanation:
                'The listing directs candidates to conduct recruitment solely through WhatsApp or Telegram. Reputable corporate recruiters communicate via official company domain emails and verified job board portals.',
            evidence: snippet,
            suggestedAction: 'Ask the recruiter for their official company email address and verified corporate website before engaging.',
            ruleName: 'MESSAGING_APP_ONLY_DETECTION',
          ),
        );
        break;
      }
    }

    // Check for free public email addresses (gmail, yahoo, etc.)
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@(gmail|yahoo|hotmail|outlook|rediffmail)\.com', caseSensitive: false);
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      final email = emailMatch.group(0)!;
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Free generic email domain used ($email)',
          type: FindingType.warning,
          severity: FindingSeverity.low,
          explanation:
              'The recruiter provided a free public email address ($email) rather than a company domain email (e.g., name@company.com). While early-stage solo founders occasionally use Gmail, established companies always have corporate domains.',
          evidence: email,
          suggestedAction: 'Check if the recruiter can contact you from a corporate domain email matching the company name.',
          ruleName: 'FREE_EMAIL_DOMAIN_DETECTION',
        ),
      );
    }
  }

  void _checkCompanyIdentity(String text, String lower, List<ScannerFindingModel> findings) {
    // Check if company identity is intentionally anonymous / vague
    final vagueCompanyPatterns = [
      RegExp(r'(a\s+leading\s+mnc|reputed\s+tech\s+firm|top\s+startup\s+in\s+city|leading\s+software\s+company)\b(?!.*\b(ltd|inc|technologies|pvt|corp)\b)', caseSensitive: false),
      RegExp(r'confidential\s+company\s+hiring', caseSensitive: false),
    ];

    for (final pattern in vagueCompanyPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final snippet = _extractSentence(text, match.start, match.end);
        findings.add(
          ScannerFindingModel(
            id: _uuid.v4(),
            title: 'Company identity not clearly specified',
            type: FindingType.unknownInconclusive,
            severity: FindingSeverity.medium,
            explanation:
                'The post does not provide an official registered company name, corporate website, or verifiable physical address.',
            evidence: snippet,
            suggestedAction: 'Request the exact registered business name and official corporate website before submitting your resume.',
            ruleName: 'VAGUE_COMPANY_IDENTITY',
          ),
        );
        break;
      }
    }
  }

  void _checkResponsibilities(String text, String lower, List<ScannerFindingModel> findings) {
    final responsibilityKeywords = ['responsibilities', 'requirements', 'qualifications', 'eligibility', 'skills', 'day-to-day', 'what you will do'];
    final matchedKeyword = responsibilityKeywords.firstWhere((kw) => lower.contains(kw), orElse: () => '');

    if (matchedKeyword.isNotEmpty) {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Job responsibilities and criteria described',
          type: FindingType.info,
          severity: FindingSeverity.info,
          explanation:
              'The role and its requirements are documented in the listing. Having clear expectations is a positive indicator, though it does not alone establish employer legitimacy.',
          evidence: 'Identified section: "$matchedKeyword"',
          suggestedAction: 'Review the technical criteria and prepare questions regarding mentorship and daily workflow.',
          ruleName: 'JOB_DESCRIPTION_AVAILABLE',
        ),
      );
    } else {
      findings.add(
        ScannerFindingModel(
          id: _uuid.v4(),
          title: 'Vague responsibilities or missing eligibility details',
          type: FindingType.unknownInconclusive,
          severity: FindingSeverity.low,
          explanation:
              'The posting does not detail key duties, required skill sets, or mentor supervision. Genuine internships clearly define learning outcomes.',
          evidence: 'No standard sections such as "Responsibilities" or "Requirements" detected.',
          suggestedAction: 'Inquire about specific projects, day-to-day deliverables, and who will oversee your work during the internship.',
          ruleName: 'MISSING_RESPONSIBILITIES_CHECK',
        ),
      );
    }
  }

  List<String> _generateRecommendedSteps(AssessmentCategory category, List<ScannerFindingModel> findings) {
    final steps = <String>[];

    // Fee step
    if (findings.any((f) => f.ruleName == 'UPFRONT_PAYMENT_DETECTION')) {
      steps.add('Do not pay any requested fee until the opportunity has been thoroughly checked.');
    }

    steps.add('Find the employer’s official website and independently sourced contact details.');
    steps.add('Confirm the opening with the employer through an official channel (e.g. verified LinkedIn or official HR email).');
    steps.add('Review the original job description and check whether the responsibilities, eligibility, stipend, and application process are clearly explained.');

    if (findings.any((f) => f.ruleName == 'MESSAGING_APP_ONLY_DETECTION' || f.ruleName == 'FREE_EMAIL_DOMAIN_DETECTION')) {
      steps.add('Do not conduct business exclusively on messaging apps; insist on corporate email confirmation.');
    }

    return steps;
  }

  String _extractSentence(String text, int matchStart, int matchEnd) {
    if (text.isEmpty) return '';

    // Search backwards for start of sentence or line
    int start = matchStart;
    while (start > 0 && text[start - 1] != '.' && text[start - 1] != '\n' && text[start - 1] != '?' && text[start - 1] != '!') {
      start--;
      if (matchStart - start > 100) break; // limit sentence length backwards
    }

    // Search forwards for end of sentence or line
    int end = matchEnd;
    while (end < text.length && text[end] != '.' && text[end] != '\n' && text[end] != '?' && text[end] != '!') {
      end++;
      if (end - matchEnd > 120) break; // limit sentence length forwards
    }

    // Add punctuation if at end of sentence
    if (end < text.length && (text[end] == '.' || text[end] == '?' || text[end] == '!')) {
      end++;
    }

    final snippet = text.substring(start, min(end, text.length)).trim();
    return snippet.isNotEmpty ? snippet : text.substring(matchStart, min(matchEnd + 30, text.length)).trim();
  }
}
