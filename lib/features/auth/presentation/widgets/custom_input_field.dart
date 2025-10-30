import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final String hintText;
  final String iconPath;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField>
    with SingleTickerProviderStateMixin {
  late bool _obscureText;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _offsetAnimation;
  late TextEditingController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _isInitialized = true;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus || _controller.text.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {});
  }

  void _handleTextChange() {
    if (_controller.text.isNotEmpty && !_animationController.isAnimating) {
      _animationController.forward();
    } else if (_controller.text.isEmpty && _focusNode.hasFocus == false) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    _animationController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    final isWeb = MediaQuery.of(context).size.width > 600;

    return Stack(
      children: [
        TextField(
          focusNode: _focusNode,
          controller: _controller,
          obscureText: widget.isPassword ? _obscureText : false,
          style: TextStyle(fontSize: isWeb ? 16 : 11, color: Colors.black),
          decoration: InputDecoration(
            hintText: '',
            fillColor: Colors.transparent,
            filled: true,
            contentPadding: isWeb
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 20)
                : const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            prefixIcon: Padding(
              padding: isWeb
                  ? const EdgeInsets.all(20.0)
                  : const EdgeInsets.all(12.0),
              child: Image.asset(
                widget.iconPath,
                width: isWeb ? 28 : 20,
                height: isWeb ? 28 : 20,
              ),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Image.asset(
                      _obscureText
                          ? 'assets/icon/eye-off-icon.png'
                          : 'assets/icon/eye-on-icon.png',
                      width: isWeb ? 28 : 20,
                      height: isWeb ? 28 : 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Color(0XFF6D717F),
                width: isWeb ? 2.0 : 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0XFF6D717F),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0XFF6D717F),
                width: 2.0,
              ),
            ),
          ),
        ),
        // Animated Hint Text
        Positioned(
          left: isWeb ? 70 : 50,
          top: isWeb ? 14 : 14,
          child: AnimatedBuilder(
            animation: _offsetAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _offsetAnimation.value),
                child: Text(
                  widget.hintText,
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
