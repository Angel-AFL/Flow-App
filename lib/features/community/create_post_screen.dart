import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'repositories/community_repository.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  bool _isPublishing = false;
  
  final TextEditingController _captionController = TextEditingController();
  final CommunityRepository _repository = CommunityRepository();
  
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _selectedLocation;

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() => _selectedImage = pickedFile);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al seleccionar imagen: $e')));
    }
  }

  Future<void> _addLocationDialog() async {
    String locationText = '';
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Añadir ubicación', style: TextStyle(color: Colors.white)),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ej. Opichén, Yucatán', 
            hintStyle: TextStyle(color: Colors.grey)
          ),
          onChanged: (value) => locationText = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() => _selectedLocation = locationText.trim().isEmpty ? null : locationText.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('Aceptar', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _publishPost() async {
    if (_captionController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega una foto o un comentario', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      await _repository.createNewPost(_captionController.text.trim(), _selectedImage, _selectedLocation);
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Publicación creada!', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isPublishing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceElevated,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nueva publicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (_isPublishing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2))),
            )
          else
            TextButton(
              onPressed: _publishPost,
              child: const Text('Compartir', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _pickMedia(ImageSource.gallery),
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        image: _selectedImage != null ? const DecorationImage(image: AssetImage('assets/images/grid_pattern.png'), fit: BoxFit.cover) : null,
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: const Icon(Icons.check_circle, color: AppColors.secondary, size: 40),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, color: AppColors.secondary),
                                SizedBox(height: 4),
                                Text('Foto', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold))
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un pie de foto...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white),
              title: const Text('Seleccionar de Galería', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
              onTap: () => _pickMedia(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              title: const Text('Tomar Foto', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
              onTap: () => _pickMedia(ImageSource.camera),
            ),
            const Divider(color: Colors.white10, height: 1),
            
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: Colors.white),
              title: Text(_selectedLocation ?? 'Añadir ubicación', style: TextStyle(color: _selectedLocation != null ? AppColors.secondary : Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
              onTap: _addLocationDialog,
            ),
            ListTile(
              leading: const Icon(Icons.person_add_outlined, color: Colors.white),
              title: const Text('Etiquetar personas', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las etiquetas estarán disponibles pronto'))),
            ),
            
            const Divider(color: Colors.white10, height: 1),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: Colors.white),
              title: const Text('Enlazar diagrama', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Selecciona de tu inventario', style: TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Se enlazará automáticamente tu diagrama activo'))),
            ),
          ],
        ),
      ),
    );
  }
}