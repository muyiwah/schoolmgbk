// import 'dart:typed_data';
// import 'dart:html' as html;
// import 'package:flutter/material.dart';

// class ImagePickerWidget extends StatefulWidget {
//   final void Function(Uint8List?)? onImagePicked;

//   const ImagePickerWidget({super.key, this.onImagePicked});

//   @override
//   State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
// }

// class _ImagePickerWidgetState extends State<ImagePickerWidget> {
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

//             // Send the picked image bytes to parent if needed
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
//     return Column(
//       children: [
//         _imageBytes != null
//             ? ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.memory(
//                 _imageBytes!,
//                 height: 150,
//                 width: 150,
//                 fit: BoxFit.cover,
//               ),
//             )
//             : Container(
//               height: 150,
//               width: 150,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey),
//               ),
//               child: Icon(Icons.person, size: 50, color: Colors.grey),
//             ),
//         const SizedBox(height: 10),
//         ElevatedButton(onPressed: _pickImage, child: const Text('Pick Image')),
//       ],
//     );
//   }
// }
