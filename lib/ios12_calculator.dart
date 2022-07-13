import 'package:flutter/material.dart';
// import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'dart:math' as Math;

import 'custom_button.dart';

double? width, height, displayHeight;
final fontSize32 = 32.0;
final fontSize36 = 36.0;
const MAX_FRACTION_DIGITS = 6;
final NumberFormat formatter = new NumberFormat("#,###.######")
  ..maximumFractionDigits = 6;
const PADDING = 13.5; //The spacing/padding around buttons
const OPERATOR_FONT_FAMILY =
    "courier new"; // Using monospace font for operator.

var calculatorOperations = {
  '/': (prevValue, nextValue) => prevValue / nextValue,
  '*': (prevValue, nextValue) => prevValue * nextValue,
  '+': (prevValue, nextValue) => prevValue + nextValue,
  '-': (prevValue, nextValue) => prevValue - nextValue,
  '=': (prevValue, nextValue) => nextValue
};

class Calculator extends StatefulWidget {
  @override
  CalculatorState createState() {
    return new CalculatorState();
  }
}

class CalculatorState extends State<Calculator> {
  var value;
  var displayValue = '0';
  var operator;
  var waitingForOperand = false;

  clearAll() {
    this.setState(() {
      value = null;
      displayValue = '0';
      operator = null;
      waitingForOperand = false;
    });
  }

  clearDisplay() {
    this.setState(() {
      displayValue = '0';
    });
  }

  toggleSign() {
    var newValue = double.parse(displayValue) * -1;

    this.setState(() {
      displayValue = formatter.format(newValue).toString();
    });
  }

  inputPercent() {
    var currentValue = double.parse(displayValue);

    if (currentValue == 0) return;

    var fixedDigits = displayValue.replaceAll(new RegExp(r"^-?\d*\.?"), '');
    var newValue = double.parse(displayValue) / 100;

    this.setState(() {
      displayValue =
          formatter.format(newValue.toStringAsFixed(fixedDigits.length + 2));
    });
  }

  inputDot() {
    if (!(new RegExp(r"\.")).hasMatch(displayValue)) {
      this.setState(() {
        displayValue = displayValue + '.';
        waitingForOperand = false;
      });
    }
  }

  inputDigit(digit) {
    if (waitingForOperand) {
      this.setState(() {
        displayValue = digit.toString();
        waitingForOperand = false;
      });
    } else {
      this.setState(() {
        displayValue = displayValue == '0'
            ? digit.toString()
            : formatter.format(double.parse(
                (displayValue + digit.toString()).replaceAll(",", "")));
      });
    }
  }

  performOperation(nextOperator) {
    var inputValue = double.parse(displayValue.replaceAll(",", ""));

    if (value == null) {
      this.setState(() {
        value = inputValue;
      });
    } else if (operator != null) {
      var currentValue = value ?? 0;
      var newValue = calculatorOperations[operator]!(currentValue, inputValue);

      this.setState(() {
        value = newValue;
        displayValue = formatter.format(newValue).toString();
      });
    }

    this.setState(() {
      waitingForOperand = true;
      operator = nextOperator;
    });
  }

  Widget get toggleKey => FunctionKey(text: "±", onPress: toggleSign);
  Widget get clearKey => FunctionKey(
        text: displayValue != '0' ? 'C' : 'AC',
        onPress: () =>
            displayValue != '0' ? this.clearDisplay() : this.clearAll(),
      );
  Widget get percentageKey => FunctionKey(text: "%", onPress: inputPercent);
  Widget get dotKey => DigitKey(text: ".", onPress: inputDot);

  Widget get divideOp =>
      OperatorKey(text: "÷", onPress: () => this.performOperation('/'));
  Widget get multiplyOp =>
      OperatorKey(text: "×", onPress: () => this.performOperation('*'));
  Widget get subtractOp =>
      OperatorKey(text: "-", onPress: () => this.performOperation('-'));
  Widget get addOp =>
      OperatorKey(text: "+", onPress: () => this.performOperation('+'));
  Widget get equalOp =>
      OperatorKey(text: "=", onPress: () => this.performOperation('='));

  Widget get dummyKey => digit(1);

  Widget digit(int num) {
    return DigitKey(text: num.toString(), onPress: () => this.inputDigit(num));
  }

  Widget row1(bool compact) {
    return Flexible(
      child: Row(
          children: compact
              ? [
                  clearKey,
                  toggleKey,
                  percentageKey,
                  divideOp,
                ]
              : [
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  clearKey,
                  toggleKey,
                  percentageKey,
                  divideOp,
                ]),
    );
  }

  Widget row2(bool compact) {
    return Flexible(
      child: Row(
          children: compact
              ? [
                  digit(7),
                  digit(8),
                  digit(9),
                  multiplyOp,
                ]
              : [
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  digit(7),
                  digit(8),
                  digit(9),
                  multiplyOp,
                ]),
    );
  }

  Widget row3(bool compact) {
    return Flexible(
      child: Row(
          children: compact
              ? [
                  digit(4),
                  digit(5),
                  digit(6),
                  subtractOp,
                ]
              : [
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  digit(4),
                  digit(5),
                  digit(6),
                  subtractOp,
                ]),
    );
  }

  Widget row4(bool compact) {
    return Flexible(
      child: Row(
          children: compact
              ? [
                  digit(1),
                  digit(2),
                  digit(3),
                  addOp,
                ]
              : [
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  digit(1),
                  digit(2),
                  digit(3),
                  addOp,
                ]),
    );
  }

  Widget row5(bool compact) {
    return Flexible(
      child: Row(
          children: compact
              ? [
                  digit(0),
                  dotKey,
                  equalOp,
                ]
              : [
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  dummyKey,
                  digit(0),
                  dotKey,
                  equalOp,
                ]),
    );
  }

  Widget content(bool isCompact) {
    final padding = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;

    width = size.width - padding.horizontal;
    height = size.height - padding.top;
    //calculate the display height based on the screen size. Reduce the height based on one button size
    //since the rows and columns are not even. Add the value for the container left padding
    displayHeight = Math.max(
        height! - width! - width! / 5.0 + PADDING, fontSize32 + PADDING);

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.only(left: PADDING),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CalculatorDisplay(value: displayValue),
            row1(isCompact),
            row2(isCompact),
            row3(isCompact),
            row4(isCompact),
            row5(isCompact),
          ],
        ),
      ),
    );
  }

  Widget get compact => content(true);
  Widget get full => content(false);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 600) {
        return full;
      } else {
        return compact;
      }
    });
  }
}

class CalculatorDisplay extends StatelessWidget {
  final value;

  const CalculatorDisplay({Key? key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: displayHeight! + 150,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(right: PADDING * 1.5, top: 15.0),
        child: Align(
          alignment: Alignment.bottomRight,
          child: AutoSizeText(
            value,
            style: TextStyle(
              fontSize: 130,
              color: Colors.white,
            ),
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}

class CalculatorKey extends StatelessWidget {
  final String? text;
  final Function? onPress;
  final Color? backgroundColor;
  final TextStyle? style;
  final bool isZeroKey;

  CalculatorKey(
      {Key? key, this.text, this.onPress, this.style, this.backgroundColor})
      : isZeroKey = text == '0',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: isZeroKey ? 2 : 1,
      child: Container(
        padding: EdgeInsets.only(right: PADDING, bottom: PADDING),
        child: ClipRRect(
          borderRadius: new BorderRadius.circular(width! / 1.0),
          child: CustomButton(
            padding: EdgeInsets.all(0),
            color: backgroundColor,
            highlightColor: Color.alphaBlend(
                Colors.white.withOpacity(0.5), backgroundColor!),
            onPressed: onPress as void Function()?,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                      top: BorderSide(color: new Color(0xFF777777)),
                      right: BorderSide(color: new Color(0xFF666666)))),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(right: isZeroKey ? width! / 4 : 0),
                  child: Text(
                    text!,
                    style: style,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FunctionKey extends StatelessWidget {
  final text;
  final onPress;

  const FunctionKey({Key? key, this.text, this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalculatorKey(
      text: text,
      onPress: onPress,
      backgroundColor: Color.fromARGB(240, 202, 202, 204),
      style: TextStyle(color: Colors.black, fontSize: fontSize32),
    );
  }
}

class OperatorKey extends StatelessWidget {
  final text;
  final onPress;

  const OperatorKey({Key? key, this.text, this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalculatorKey(
      text: text,
      onPress: onPress,
      backgroundColor: Colors.orangeAccent,
      style: TextStyle(
          color: Colors.white,
          fontSize: fontSize36,
          fontFamily: OPERATOR_FONT_FAMILY,
          fontWeight: FontWeight.bold),
    );
  }
}

class DigitKey extends StatelessWidget {
  final text;
  final onPress;
  final fontSize;

  const DigitKey({Key? key, this.text, this.onPress, this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalculatorKey(
      text: text,
      onPress: onPress,
      backgroundColor: new Color(0xFF322f32),
      style: TextStyle(color: Colors.white, fontSize: fontSize ?? fontSize32),
    );
  }
}
