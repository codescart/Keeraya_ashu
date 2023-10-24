import 'dart:io';

import 'package:keeraya/screens/color_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//* deleted >>> deprecated
// import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:provider/provider.dart';

import '../helpers/current_user.dart';
import '../models/product_image.dart';
import '../providers/languages.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(List<File> pickedImages) imagePickFn;
  final void Function(int index) deleteImageFn;
  final netImage;
  List<ProductImage> imagesList = [];

  UserImagePicker({
    this.imagePickFn,
    this.deleteImageFn,
    this.netImage,
    this.imagesList,
  });

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  List<File> _pickedImageFile;

  void _pickImage() async {
    // For chosing both camera and gallery choice, need to implement a dialog
    // final pickedAssets = await MultiImagePicker.pickImages(
    //   // source: ImageSource.gallery,
    //   maxImages: 5,

    //   // Lowing the image quality to save storage
    //   // imageQuality: 50,
    //   // maxWidth: 150,
    // );

    FilePickerResult result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image
            // type: FileType.custom,
            // allowedExtensions: [
            //   'jpg',
            //   'jpeg',
            //   'png',
            //   'tif',
            //   'tiff',
            //   'bmp',
            //   'BMPF',
            //   'HEIC'
            // ],
            );
    //  FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
    } else {
      // User canceled the picker
    }

    List<File> pickedImages = [];
    if (result != null) {
      pickedImages = result.paths.map((path) => File(path)).toList();
    } else {
      // User canceled the picker
    }

    // for (int i = 0; i < pickedAssets.length; i++) {
    //   var path =
    //       await FlutterAbsolutePath.getAbsolutePath(pickedAssets[i].identifier);
    //   print(path);
    //   pickedImages.add(File(path));
    // }
    setState(() {
      // _pickedImageFile = pickedImage;
    });
    widget.imagePickFn(pickedImages);
  }

  _deleteImage(index) {
    setState(() {
      widget.deleteImageFn(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    return Column(
      children: [
        if (widget.imagesList.length > 0)
          GridView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: widget.imagesList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, i) {
              return Stack(
                  fit: StackFit.passthrough,
                  alignment: Alignment.center,
                  children: [
                    if (widget.imagesList[i].isLocal)
                      Image.file(
                        widget.imagesList[i].file,
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                      ),
                    if (!widget.imagesList[i].isLocal)
                      Image.network(
                        widget.imagesList[i].urlPrefix +
                            widget.imagesList[i].url,
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                      ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        color: Colors.white70,
                        child: IconButton(
                          onPressed: () {
                            _deleteImage(i);
                          },
                          icon: Icon(Icons.close),
                          color: Colors.grey[800],
                          //color: Colors.transparent,
                          iconSize: 25,
                          constraints: BoxConstraints(maxHeight: 30),
                          padding: EdgeInsets.all(0),
                        ),
                      ),
                    ),
                  ]);
              // return Container();
            },
          ),
        SizedBox(
          height: 15,
        ),
        TextButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(HexColor()),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text(
            langPack['ADD PHOTO'],
            textDirection: CurrentUser.textDirection,
          ),
        ),
      ],
    );
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     CircleAvatar(
    //       backgroundColor: Colors.grey[300],
    //       radius: 40,
    //       backgroundImage: _pickedImageFile != null
    //           ? FileImage(_pickedImageFile)
    //           : widget.netImage != null
    //               ? NetworkImage(widget.netImage)
    //               : null,
    //     ),
    //     SizedBox(
    //       width: 10,
    //     ),
    //     TextButton.icon(
    //       onPressed: _pickImage,
    //       style: ButtonStyle(
    //         backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
    //         foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    //       ),
    //       icon: Icon(Icons.image),
    //       label: Text(langPack['ADD PHOTO']),
    //     ),
    //   ],
    // );
  }
}
