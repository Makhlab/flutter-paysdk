import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:badges/badges.dart' as badges;

/// This file contains example UI components built with the various
/// UI libraries installed in this project.
/// These can be used as building blocks for enhancing the payment UI.

class PaymentExamples extends StatelessWidget {
  const PaymentExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment UI Examples',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: badges.Badge(
              badgeContent: const Text(
                '3',
                style: TextStyle(color: Colors.white),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
              ),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title with Google Fonts
            Text(
              'Beautiful UI Components',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2c3e50),
              ),
            ),
            SizedBox(height: 24.h),
            
            // Animated Card Input Example
            FadeInDown(
              preferences: const AnimationPreferences(
                duration: Duration(milliseconds: 400),
              ),
              child: _buildCreditCardInput(),
            ),
            SizedBox(height: 24.h),
            
            // Shimmer Loading Effect Example
            Text(
              'Loading States',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2c3e50),
              ),
            ),
            SizedBox(height: 12.h),
            _buildShimmerLoading(),
            SizedBox(height: 24.h),
            
            // SpinKit Loaders Example
            Text(
              'Loading Indicators',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2c3e50),
              ),
            ),
            SizedBox(height: 12.h),
            _buildLoadingIndicators(),
            SizedBox(height: 24.h),
            
            // Beautiful Payment Button
            Text(
              'Payment Buttons',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2c3e50),
              ),
            ),
            SizedBox(height: 12.h),
            _buildPaymentButtons(),
          ],
        ),
      ),
    );
  }
  
  // Credit Card Input Example
  Widget _buildCreditCardInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Information',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Card Number Input
          TextField(
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '0000 0000 0000 0000',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          
          // Expiry Date & CVV Inputs
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Shimmer Loading Example
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: 200.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        ],
      ),
    );
  }
  
  // SpinKit Loading Indicators Example
  Widget _buildLoadingIndicators() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Choose a loading style for your app',
            style: GoogleFonts.poppins(fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Circular loading indicator
              Column(
                children: [
                  const SpinKitDoubleBounce(
                    color: Color(0xFF8ccc52),
                    size: 40.0,
                  ),
                  SizedBox(height: 8.h),
                  Text('Double Bounce', style: GoogleFonts.poppins(fontSize: 12.sp)),
                ],
              ),
              
              // Pulse loading indicator
              Column(
                children: [
                  const SpinKitPulse(
                    color: Color(0xFF8ccc52),
                    size: 40.0,
                  ),
                  SizedBox(height: 8.h),
                  Text('Pulse', style: GoogleFonts.poppins(fontSize: 12.sp)),
                ],
              ),
              
              // Wave loading indicator
              Column(
                children: [
                  const SpinKitWave(
                    color: Color(0xFF8ccc52),
                    size: 40.0,
                    type: SpinKitWaveType.center,
                  ),
                  SizedBox(height: 8.h),
                  Text('Wave', style: GoogleFonts.poppins(fontSize: 12.sp)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Beautiful Payment Buttons Example
  Widget _buildPaymentButtons() {
    return Column(
      children: [
        // Primary Payment Button
        ZoomIn(
          preferences: const AnimationPreferences(
            duration: Duration(milliseconds: 300),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8ccc52), Color(0xFF4a7c2a)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8ccc52).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Pay Now \$50.00',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        
        // Alternative Payment Methods
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodButton('Apple Pay', Icons.apple),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildPaymentMethodButton('Google Pay', Icons.g_mobiledata),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPaymentMethodButton(String text, IconData icon) {
    return FadeInUp(
      preferences: const AnimationPreferences(
        duration: Duration(milliseconds: 500),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(icon),
          label: Text(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ),
    );
  }
} 