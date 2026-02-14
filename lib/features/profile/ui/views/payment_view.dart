// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  int _selectedPaymentMethod = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'Credit Card',
      'icon': Icons.credit_card,
      'subtitle': 'Visa, MasterCard, American Express',
    },
    {
      'title': 'PayPal',
      'icon': Icons.paypal,
      'subtitle': 'Pay with your PayPal account',
    },
    {
      'title': 'Apple Pay',
      'icon': Icons.apple,
      'subtitle': 'Pay with Touch ID or Face ID',
    },
    {
      'title': 'Google Pay',
      'icon': Icons.apple,
      'subtitle': 'Pay with your Google account',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Hide navigation bar when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setNavBarVisible(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: CustomAppBar(
        title: 'Payment',
        onBackPressed: () {
          context.setNavBarVisible(true);
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Current Balance Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0961F5), Color(0xFF2F98D7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '\$2,548.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available Credits',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              '25 Credits',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Payment Methods Section
                  Text(
                    'Payment Methods',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Payment Methods List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentMethodTile(index);
                    },
                  ),

                  SizedBox(height: 30.h),

                  // Add New Payment Method Button
                  Container(
                    width: double.infinity,
                    height: 55.h,
                    margin: EdgeInsets.only(bottom: 15.h),
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle add new payment method
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0961F5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: const Color(0xFF0961F5),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Add New Payment Method',
                            style: TextStyle(
                              color: const Color(0xFF0961F5),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle save
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0961F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(int index) {
    final method = _paymentMethods[index];
    final isSelected = _selectedPaymentMethod == index;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF0961F5) : Colors.grey[300]!,
          width: isSelected ? 2.w : 1.w,
        ),
        borderRadius: BorderRadius.circular(16.r),
        color: isSelected ? const Color(0xFFF0F8FF) : Colors.grey[50],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0961F5) : Colors.grey[400],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(method['icon'], color: Colors.white, size: 24.sp),
        ),
        title: Text(
          method['title'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          method['subtitle'],
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        trailing: Radio<int>(
          value: index,
          groupValue: _selectedPaymentMethod,
          onChanged: (int? value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
          activeColor: const Color(0xFF0961F5),
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = index;
          });
        },
      ),
    );
  }
}
