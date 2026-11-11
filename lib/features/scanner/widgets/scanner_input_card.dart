import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/scanner_controller.dart';
import '../models/scanner_report_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ScannerInputCard extends StatelessWidget {
  final ScannerController controller;

  const ScannerInputCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Tab Selector
          _buildInputTabs(),
          const SizedBox(height: 20),

          // Active Input Field
          Obx(() {
            switch (controller.selectedInputType.value) {
              case ScannerInputType.url:
                return _buildUrlInput();
              case ScannerInputType.text:
                return _buildJobDescriptionInput();
              case ScannerInputType.document:
                return _buildDocumentUploadInput();
            }
          }),

          const SizedBox(height: 16),

          // Inline Validation / Helper Text
          Obx(() {
            final msg = controller.currentValidationMessage;
            if (msg == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      msg,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Demo Test Fixture Presets for quick evaluation
          _buildDemoPresets(),
          const SizedBox(height: 20),

          // Primary CTA Button
          Obx(() {
            final isValid = controller.isValidInput;
            final isAnalyzing = controller.isAnalyzing.value;

            return SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid ? AppColors.primary : AppColors.outlineVariant,
                  foregroundColor: Colors.white,
                  elevation: isValid ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: (isValid && !isAnalyzing)
                    ? () => controller.startAnalysis()
                    : null,
                child: isAnalyzing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Analyzing Internship...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Analyze Internship',
                            style: AppTextStyles.labelMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),

          const SizedBox(height: 14),

          // Transparent Privacy Note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline,
                size: 15,
                color: AppColors.outline.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Your information is used to assess potential warning signs. Avoid uploading sensitive personal information.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.outline,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputTabs() {
    return Obx(() {
      final currentType = controller.selectedInputType.value;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildTabItem(
              type: ScannerInputType.url,
              label: 'URL',
              icon: Icons.link,
              isSelected: currentType == ScannerInputType.url,
            ),
            _buildTabItem(
              type: ScannerInputType.text,
              label: 'Description',
              icon: Icons.description_outlined,
              isSelected: currentType == ScannerInputType.text,
            ),
            _buildTabItem(
              type: ScannerInputType.document,
              label: 'Upload',
              icon: Icons.upload_file_outlined,
              isSelected: currentType == ScannerInputType.document,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem({
    required ScannerInputType type,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setInputType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paste internship URL',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Option 1',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the link to an internship listing.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.urlController,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'https://example.com/internship-posting',
            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
            prefixIcon: const Icon(Icons.link, color: AppColors.primary),
            suffixIcon: controller.urlText.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => controller.urlController.clear(),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Note: A syntactically valid URL does not verify whether an opportunity is authentic.',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.outline,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildJobDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paste job description',
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data != null && data.text != null) {
                  controller.descriptionController.text = data.text!;
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.content_paste, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Paste from clipboard',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Copy the offer details, requirements and stipend.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.descriptionController,
          maxLines: 6,
          minLines: 4,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: 'Paste the complete job post, company name, requirements, stipend, application process, and contact information...',
            hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
            filled: true,
            fillColor: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Missing details will be noted as observations rather than automatic fraud.',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.outline,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Obx(() => Text(
                  '${controller.descriptionText.value.length} chars',
                  style: AppTextStyles.labelSm.copyWith(
                    color: controller.descriptionText.value.length >= 20
                        ? AppColors.secondary
                        : AppColors.outline,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentUploadInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload offer or screenshot',
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Submit an internship poster, offer letter or screenshot for analysis.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),

        Obx(() {
          final file = controller.selectedFile.value;

          if (file == null) {
            return GestureDetector(
              onTap: () => controller.pickDocument(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to browse files',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supported formats: PDF, PNG, JPG, JPEG (Max 10MB)',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // File is selected: show preview card
          final sizeKb = (controller.selectedFileSize.value / 1024).toStringAsFixed(1);
          final previewBytes = controller.filePreviewBytes.value;
          final isImage = previewBytes != null;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                // Thumbnail or Icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: Colors.white,
                    child: isImage
                        ? Image.memory(previewBytes, fit: BoxFit.cover)
                        : const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 28),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Size
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedFileName.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$sizeKb KB • Ready for scan',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions: Replace or Remove
                IconButton(
                  tooltip: 'Replace file',
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                  onPressed: () => controller.pickDocument(),
                ),
                IconButton(
                  tooltip: 'Remove file',
                  icon: const Icon(Icons.close, size: 20, color: AppColors.error),
                  onPressed: () => controller.removeSelectedFile(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDemoPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.science_outlined, size: 14, color: AppColors.outline),
            const SizedBox(width: 4),
            Text(
              'Evaluation Test Fixtures',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ActionChip(
              avatar: const Icon(Icons.warning_amber, size: 14, color: Color(0xFFBA1A1A)),
              label: Text(
                'Scam Offer Sample',
                style: AppTextStyles.labelSm.copyWith(
                  color: const Color(0xFFBA1A1A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFFFFDAD6).withValues(alpha: 0.6),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              onPressed: () => controller.loadDemoScamOffer(),
            ),
            ActionChip(
              avatar: const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
              label: Text(
                'Legitimate Offer Sample',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.surfaceContainerLow,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              onPressed: () => controller.loadDemoLegitimateOffer(),
            ),
            ActionChip(
              avatar: const Icon(Icons.help_outline, size: 14, color: Color(0xFF784B00)),
              label: Text(
                'Inconclusive Sample',
                style: AppTextStyles.labelSm.copyWith(
                  color: const Color(0xFF784B00),
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFFFEF3C7),
              side: const BorderSide(color: Color(0xFFFCD34D)),
              onPressed: () => controller.loadDemoInconclusiveOffer(),
            ),
          ],
        ),
      ],
    );
  }
}
