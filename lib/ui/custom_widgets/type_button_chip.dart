import 'package:flutter/material.dart';

class TypeButtonChip extends StatelessWidget {
 final String name;
 const TypeButtonChip({super.key,required this.name});

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 11.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        )        
      ),

      child: Center(
        child:Text(name,
        style: TextStyle( fontSize: 12,color: Colors.white),)
      )
    );
    
    }
}