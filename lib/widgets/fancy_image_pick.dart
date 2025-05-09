// import 'dart:typed_data';
// import 'dart:html' as html;
// import 'package:flutter/material.dart';

// class FancyImagePick extends StatefulWidget {
//   final void Function(Uint8List?)? onImagePicked;

//   const FancyImagePick({super.key, this.onImagePicked});

//   @override
//   State<FancyImagePick> createState() => _FancyImagePickState();
// }

// class _FancyImagePickState extends State<FancyImagePick> {
//   Uint8List? _imageBytes;

//   Future<void> _pickImage() async {
//     final uploadInput = html.FileUploadInputElement();
//     uploadInput.accept = 'image/*';
//     uploadInput.click();

//     uploadInput.onChange.listen((event) {
//       final file = uploadInput.files?.first;
//       if (file != null) {
//         final reader = html.FileReader();
//         reader.readAsArrayBuffer(file);
//         reader.onLoadEnd.listen((event) {
//           final bytes = reader.result as Uint8List?;
//           if (bytes != null) {
//             setState(() {
//               _imageBytes = bytes;
//             });
//             if (widget.onImagePicked != null) {
//               widget.onImagePicked!(bytes);
//             }
//           }
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         height: 150,
//         width: 150,
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(75),
//           border: Border.all(color: Colors.grey),
//           image:
//               _imageBytes != null
//                   ? DecorationImage(
//                     image: MemoryImage(_imageBytes!),
//                     fit: BoxFit.cover,
//                   )
//                   : null,
//         ),
//         child:
//             _imageBytes == null
//                 ? const Center(
//                   child: Icon(Icons.camera_alt, size: 40, color: Colors.grey),
//                 )
//                 : null,
//       ),
//     );
//   }
// }
