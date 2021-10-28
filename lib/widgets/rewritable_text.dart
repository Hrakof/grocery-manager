import 'package:flutter/material.dart';




class RewritableText extends StatefulWidget {

  final Text text;
  final String labelText;
  final Function(String) onTextEdited;

  const RewritableText({required this.text, required this.onTextEdited, required this.labelText, Key? key, }) : super(key: key);


  @override
  _RewritableTextState createState() => _RewritableTextState();
}
class _RewritableTextState extends State<RewritableText> {
  bool editing = false;
  String newText = '';


  @override
  Widget build(BuildContext context) {
    if (editing) {
      return _editingRow();
    }
    else {
      return _defaultRow();
    }
  }

  Widget _editingRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: widget.labelText,
            ),
            onChanged: (text){
              newText = text;
            },
          ),
        ),
        IconButton(
            onPressed: () {
              widget.onTextEdited(newText);
              _resetState();
            },
            icon: const Icon(Icons.done)),
        IconButton(
            onPressed: () => _resetState(),
            icon: const Icon(Icons.close)),
      ],
    );
  }

  void _resetState(){
    setState(() {
      editing = false;
      newText = '';
    });
  }

  Widget _defaultRow() {
    return Row(
      children: [
        widget.text,
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            setState(() {
              editing = true;
            });
          },
        ),
      ],
    );
  }
}