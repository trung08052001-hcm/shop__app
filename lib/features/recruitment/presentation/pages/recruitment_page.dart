import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/network/dio_client.dart';
import 'package:shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shop_app/l10n/app_localizations.dart';

class JobDescription {
  final String title;
  final String description;
  final String requirements;

  JobDescription({
    required this.title,
    required this.description,
    required this.requirements,
  });
}

class RecruitmentPage extends StatefulWidget {
  const RecruitmentPage({super.key});

  @override
  State<RecruitmentPage> createState() => _RecruitmentPageState();
}

class _RecruitmentPageState extends State<RecruitmentPage> {
  final List<JobDescription> _jobs = [
    JobDescription(
      title: 'Frontend Developer',
      description: 'Phát triển giao diện người dùng cho các dự án Web sử dụng React/Next.js.',
      requirements: 'Yêu cầu: 1 năm kinh nghiệm với React, HTML, CSS.',
    ),
    JobDescription(
      title: 'Backend Developer',
      description: 'Xây dựng và tối ưu API cho hệ thống thương mại điện tử bằng Node.js.',
      requirements: 'Yêu cầu: 1 năm kinh nghiệm với Node.js, Express, MongoDB.',
    ),
    JobDescription(
      title: 'Mobile Developer',
      description: 'Phát triển ứng dụng di động đa nền tảng bằng Flutter cho dự án Shop App.',
      requirements: 'Yêu cầu: 1 năm kinh nghiệm với Flutter, Dart, Bloc.',
    ),
  ];

  bool _isUploading = false;

  Future<void> _applyForJob(BuildContext context, String jobTitle) async {
    final authState = context.read<AuthBloc>().state;
    String userEmail = '';
    if (authState is AuthSuccess) {
      userEmail = authState.user.email;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để ứng tuyển.')),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isUploading = true;
        });

        File file = File(result.files.single.path!);
        String filename = result.files.single.name; // Get direct name from picker
        
        final dio = getIt<DioClient>().dio;
        
        FormData formData = FormData.fromMap({
          'userEmail': userEmail,
          'jobTitle': jobTitle,
          'cvFile': await MultipartFile.fromFile(
            file.path,
            filename: filename,
            contentType: DioMediaType('application', 'pdf'), // Specify PDF type
          ),
        });

        debugPrint('Uploading CV: $filename to /recruitment/apply');
        
        final response = await dio.post(
          '/recruitment/apply',
          data: formData,
        );

        setState(() {
          _isUploading = false;
        });

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ứng tuyển thành công! CV của bạn đã được gửi.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } on DioException catch (e) {
      setState(() {
        _isUploading = false;
      });
      debugPrint('Dio Error: ${e.type} - ${e.message}');
      debugPrint('Response Data: ${e.response?.data}');
      if (mounted) {
        String errorMsg = 'Lỗi kết nối server';
        if (e.response?.data != null && e.response?.data is Map) {
          errorMsg = e.response?.data['message'] ?? errorMsg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi ứng tuyển: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      debugPrint('General Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recruitment),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: _jobs.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final job = _jobs[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        job.description,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        job.requirements,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _applyForJob(context, job.title),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Ứng tuyển ngay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
